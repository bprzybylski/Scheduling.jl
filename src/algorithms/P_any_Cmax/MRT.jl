# Mounié, G., Rapine, C., & Trystram, D. (2007). 
# A $\frac32$‐Approximation Algorithm for Scheduling Independent Monotonic Malleable Tasks. 
# SIAM Journal on Computing, 37(2), 401–412. 
# http://doi.org/10.1137/S0097539701385995

using JuMP
using GLPK

struct Allotment
    task_id::Int64
    start_time::Float64
    p_time::Float64
    start_proc::Int64
    nproc::Int64
end

# a struct for updating Sets 0,1,2
mutable struct MRTAllotment
    task_id::Int64
    nb_procs::Int64
    ptime::Float64
end

mutable struct MRTMachineLoad
    mach_idx::Int64
    load::Float64
    start_time::Float64
end

function get_canonical_nb_procs_and_ptime(p::Array{Float64}, m::Int64, time_bound::Float64)
    nb_procs = -1
    ptime    = 0
    for i in 1:m
        if p[i] <= time_bound
            nb_procs = i
            ptime    = p[i]
            break
        end
    end
    nb_procs, ptime
end

function get_lower_bound(n::Int64, m::Int64, p::Array{Float64})
    psum = 0.0
    for i in 1:n
        psum += p[i,1]
    end
    psum/m
end

function get_upper_bound(n::Int64, m::Int64, p::Array{Float64})
    psum = 0.0
    for i in 1:n
        psum += p[i,1]
    end
    psum
end

function solve_knapsack(n::Int64, m::Int64, p::Array{Float64}, d::Float64, can_nb_d::Array{Int64}, can_nb_d2::Array{Int64}, can_work_d::Array{Float64}, can_work_d2::Array{Float64})
    
    mod = Model(GLPK.Optimizer)
    #set_optimizer_attribute(mod, "OutputFlag", 0)
    
    @variable(mod, x[1:n], Bin )
    @variable(mod, profit >= 0 )
    #@variable(mod, work   >= 0 )
    @objective(mod, Max, profit)

    @constraint(mod, profit <= sum( x[i] * (can_work_d2[i] - can_work_d[i]) for i=1:n ) )

    @constraint(mod, sum( x[i] * can_nb_d[i] for i=1:n ) <= m )
    
    for i in 1:n
        if can_nb_d2[i] == -1
            println("force idx $(i) into S1")
            # here we cannot use set S2
            # we need to force this task into S1
            @constraint(mod, x[i] == 1 )
        end
    end

     optimize!(mod)    
     status = termination_status(mod)
    
    if status != MOI.OPTIMAL
        nothing
    else

        profit = objective_value(mod)
        println("profit: ", profit)

        x = value.(x)
        println("x: $(x)")
        
        set_1 = findall( x -> x == 1, x )

        set_1
    end
end

function try_reducing_procs_of_tasks_in_s1(m::Int64, d::Float64, a_set_0::Array{Tuple{MRTAllotment,MRTAllotment}}, a_set_1::Array{MRTAllotment}, a_set_2::Array{MRTAllotment}, p::Array{Float64})
    changed = false
    
    remove_procs_task_idx = -1
    for i in 1:length(a_set_1)
        if a_set_1[i].nb_procs > 1 && a_set_1[i].ptime <= 3/4*d                    
            remove_procs_task_idx = i
            break
        end
    end
    
    if remove_procs_task_idx != -1
        
        old_allot    = a_set_1[remove_procs_task_idx]
        task_id      = old_allot.task_id
        new_nb_procs = old_allot.nb_procs-1
        new_ptime    = p[task_id,new_nb_procs] 
        
        
        tup = ( MRTAllotment(task_id, new_nb_procs, new_ptime), MRTAllotment(-1,-1,0.0) )
        push!(a_set_0, tup)
        a_set_1 = filter(x->x != old_allot, a_set_1)    
        
        changed = true
    end
    
    changed, a_set_0, a_set_1, a_set_2
end

function try_stacking_tasks_from_s1(m::Int64, d::Float64, a_set_0::Array{Tuple{MRTAllotment,MRTAllotment}}, a_set_1::Array{MRTAllotment}, a_set_2::Array{MRTAllotment})
    changed = false
    
    stack_task_idx_1 = -1
    stack_task_idx_2 = -1
    for i in 1:length(a_set_1)
        if a_set_1[i].nb_procs == 1 && a_set_1[i].ptime <= 3/4*d
            if stack_task_idx_1 == -1                 
                stack_task_idx_1 = i
            else
                stack_task_idx_2 = i
                break
            end
        end
    end
    
    if stack_task_idx_1 != -1 && stack_task_idx_2 != -2
        allot1 = a_set_1[stack_task_idx_1]
        allot2 = a_set_1[stack_task_idx_2]
        push!(a_set_0, (allot1, allot2))
        a_set_1 = filter(x->x != allot1, a_set_1)
        a_set_1 = filter(x->x != allot2, a_set_1)        
        changed = true
        println("stacked tasks $(allot1.task_id) and $(allot2.task_id)")
    end
    
    changed, a_set_0, a_set_1, a_set_2
end

function try_moving_tasks_from_s2_to_s1(m::Int64, d::Float64, a_set_0::Array{Tuple{MRTAllotment,MRTAllotment}}, a_set_1::Array{MRTAllotment}, a_set_2::Array{MRTAllotment}, p::Array{Float64})
    changed = false
    
    # find empty processors in S1
    # m - sum(procs in S0) - sum(proc in S1)
    procs_used_s0 = 0
    for i in 1:length(a_set_0)
        tup = a_set_0[i]
        if tup[2].task_id != -1
            # in this case, stacks are stacked, and tasks must have only one proc
            if tup[1].nb_procs > 1 || tup[1].nb_procs > 1
                @warn "tasks $(tup[1].task_id) and $(tup[2].task_id) not properly stacked"
            end
        end
        procs_used_s0 += tup[1].nb_procs
    end
    
    procs_used_s1 = 0
    if length(a_set_1) > 1
        procs_used_s1 = mapreduce(x -> x.nb_procs, +, a_set_1)
    end
    
    procs_free_s1 = m - procs_used_s0 - procs_used_s1
    println("procs_free_s1: $(procs_free_s1)")
    
    if procs_free_s1 > 0        
        for i in 1:length(a_set_2)
            nb_procs, ptime = get_canonical_nb_procs_and_ptime(p[a_set_2[i].task_id,:], procs_free_s1, 3/2*d)
            if nb_procs >= 1 && nb_procs <= procs_free_s1
                allot = a_set_2[i]
                new_allot= MRTAllotment(allot.task_id, nb_procs, ptime)
                push!(a_set_1, new_allot)
                a_set_2 = filter(x->x != allot, a_set_2)
                changed = true
                println("moved task $(allot.task_id) from S2 to S1")
                break
            end
        end
    end
    
    
    changed, a_set_0, a_set_1, a_set_2
end

function is_feasible(m::Int64, d::Float64, a_set_0::Array{Tuple{MRTAllotment,MRTAllotment}}, a_set_1::Array{MRTAllotment}, a_set_2::Array{MRTAllotment})
    feasible = true

    procs_used_s0 = 0
    for i in 1:length(a_set_0)
        tup = a_set_0[i]
        println("TUPLE: $(tup)")
        if tup[2].task_id != -1
            # in this case, stacks are stacked, and tasks must have only one proc
            if tup[1].nb_procs > 1 || tup[1].nb_procs > 1
                @warn "tasks $(tup[1].task_id) and $(tup[2].task_id) not properly stacked"
            end
        end
        procs_used_s0 += tup[1].nb_procs
    end
    
    procs_used_s1 = 0
    if length(a_set_1) > 1
        procs_used_s1 = mapreduce(x -> x.nb_procs, +, a_set_1)
    end
    
    procs_used_s2 = 0
    if length(a_set_2) > 1
        procs_used_s2 = mapreduce(x -> x.nb_procs, +, a_set_2)
    end

    println("procs_used_s0: $(procs_used_s0)")
    println("procs_used_s1: $(procs_used_s1)")
    println("procs_used_s2: $(procs_used_s2)")

    if procs_used_s0 + procs_used_s1 > m
        feasible = false
        @warn "too many procs in S0 and S1"
    elseif procs_used_s0 + procs_used_s2 > m
        feasible = false
        @warn "too many procs in S0 and S2"
    end        
    
    feasible
end

function MRT(n::Int64, m::Int64, p::Array{Float64})
    schedule = Array{Allotment,1}()
    makespan = 0.0
    
    upper_bound = get_upper_bound(n, m, p)
    lower_bound = get_lower_bound(n, m, p)
    println("bounds $(lower_bound) $(upper_bound)")

    
    sol_set_small = nothing
    sol_set_1     = nothing
    sol_set_2     = nothing
    sol_d         = nothing
    
    while upper_bound/lower_bound > 1.01

        d = lower_bound + (upper_bound-lower_bound)/2
        println("current d: $(d)")

        # these are all tasks smaller than d/2 with p[1]
        set_small = findall( x -> x <= d/2, p[:,1] )
        # these are all tasks larger than d/2 with p[1]
        set_t = findall( x -> x > d/2, p[:,1] )
        println("set_t: $(set_t)")
        
        println("set_small: $(set_small)")
        Ws = sum(p[set_small,1])
        println("Ws: $(Ws)")
        
        p_t = p[set_t,:]
        #println("p_t: $(p_t)")
        n_t = length(set_t)
        
        can_nb_d  = Array{Int64}(undef, n_t)
        can_nb_d2 = Array{Int64}(undef, n_t)

        can_work_d  = Array{Float64}(undef, n_t)
        can_work_d2 = Array{Float64}(undef, n_t)
        
        
        invalid_d = false
        # force_in_set_1 = Array{Int64,1}()
        # force_in_set_1_indexes = Array{Int64,1}()
        # force_in_set_1_nb_procs = 0
        for i in 1:n_t
            pi = p_t[i,:]
    #        println("pi", pi)
            nprocs, ptime = get_canonical_nb_procs_and_ptime(pi, m, d)
            can_nb_d[i] = nprocs
            can_work_d[i] = ptime * nprocs
            
            nprocs, ptime = get_canonical_nb_procs_and_ptime(pi, m, d/2)
            can_nb_d2[i] = nprocs
            can_work_d2[i] = ptime * nprocs
            if can_nb_d[i] == -1
                # if this task cannot even make the bound d, no chance to complete schedule
                invalid_d = true
            # elseif can_nb_d2[i] == -1
            #     # if this task can make the bound d but not bound d/2, we need to force it
            #     # into S1 and remove it from the knapsack
            #     push!(force_in_set_1, set_t[i])
            #     #push!(force_in_set_1_indexes, i)
            #     force_in_set_1_nb_procs += can_nb_d[i]
            end
        end
        
        # println("old set_t: $(set_t)")
        # set_t = setdiff(set_t, force_in_set_1)
        # 
        # println("force into set1: $(force_in_set_1)")
        # println("new set_t: $(set_t)")
        
        if invalid_d == true
            lower_bound = d            
        else    
        
            println("d : $(can_nb_d) $(can_work_d)")
            println("d2: $(can_nb_d2) $(can_work_d2)")

            local_set_s1 = solve_knapsack(n_t, m, p_t, d, can_nb_d, can_nb_d2, can_work_d, can_work_d2)
            
            if local_set_s1 === nothing
                lower_bound = d
            else            
                # this task_set_s1 is indexing p_t 
                # translate back to set_t
                tasks_set_s1 = set_t[local_set_s1]        
                tasks_set_s2 = setdiff(set_t, tasks_set_s1)
                
                println("tasks_set_s1 $(tasks_set_s1)")
                println("tasks_set_s2 $(tasks_set_s2)")
                
                W = 0.0
                for i in 1:n_t
                    task_id = set_t[i]
                    if findfirst(x -> x==task_id, tasks_set_s1) != nothing
                        W += can_work_d[i]
                    else
                        W += can_work_d2[i]                
                    end
                end
                Wbound = m*d - Ws
                if W > Wbound
                    # impossible bound, i.e., no space for small tasks left
                    # invalid guess 'd', 'd' too small
                    lower_bound = d
                else
                    upper_bound = d
                    
                    sol_d = d
                    sol_set_1 = deepcopy(tasks_set_s1)
                    sol_set_2 = deepcopy(tasks_set_s2)
                    sol_set_small = deepcopy(set_small)
                end    
            end            
        end
    end
    
    if sol_d !== nothing
        println("building solution..")
        # create 3 allotment sets S0, S1, S2 (as in paper)
        
        # in set S0 we could stack two tasks
        a_set_0 = Array{Tuple{MRTAllotment,MRTAllotment},1}()
        a_set_1 = Array{MRTAllotment,1}()
        a_set_2 = Array{MRTAllotment,1}()
        
        # fill sets S1 (bound d) and S2 (bound d/2)
        for i in 1:length(sol_set_1)
            nb_procs, ptime = get_canonical_nb_procs_and_ptime(p[sol_set_1[i],:], m, sol_d)
            allot = MRTAllotment(sol_set_1[i], nb_procs, ptime)
            push!(a_set_1, allot)
        end
        for i in 1:length(sol_set_2)
            nb_procs, ptime = get_canonical_nb_procs_and_ptime(p[sol_set_2[i],:], m, sol_d/2)
            allot = MRTAllotment(sol_set_2[i], nb_procs, ptime)
            push!(a_set_2, allot)
        end
        
        
        test_cnt = 0
        while ! is_feasible(m, sol_d, a_set_0, a_set_1, a_set_2)        
            println("set 0: $(a_set_0)")
            println("set 1: $(a_set_1)")
            println("set 2: $(a_set_2)")
            
            @warn "schedule infeasible"
            
            transformed, a_set_0, a_set_1, a_set_2 = try_reducing_procs_of_tasks_in_s1(m, sol_d, a_set_0, a_set_1, a_set_2, p)
            transformed, a_set_0, a_set_1, a_set_2 = try_stacking_tasks_from_s1(m, sol_d, a_set_0, a_set_1, a_set_2)
            transformed, a_set_0, a_set_1, a_set_2 = try_moving_tasks_from_s2_to_s1(m, sol_d, a_set_0, a_set_1, a_set_2, p)
                
            # this is only for debugging purposes            
            test_cnt += 1
            if test_cnt > 100
                break
            end
        end
        
        println("now adding small tasks..") 
        # but first start building schedule
        # put all tasks of S0 in to schedule, starting from time 0
        starting_machine_s0 = 1
        
        # remember machine load (we need the least loaded machine later)
        machine_load = Array{MRTMachineLoad}(undef, m)
        for i in 1:m
            machine_load[i] = MRTMachineLoad(i, 0.0, 0.0)
        end
        
        for i in 1:length(a_set_0)
            tup = a_set_0[i]
            allot = Allotment(tup[1].task_id, 0.0, tup[1].ptime, starting_machine_s0, tup[1].nb_procs)
            push!(schedule, allot)
            
            for j in 1:(tup[1].nb_procs)
                machine_load[starting_machine_s0+j-1].load       += tup[1].ptime
                machine_load[starting_machine_s0+j-1].start_time  = tup[1].ptime
            end
            if tup[2].task_id != -1
                # we stack here on top of task from tup[1]
                allot = Allotment(tup[2].task_id, tup[1].ptime, tup[2].ptime, starting_machine_s0, tup[2].nb_procs)
                push!(schedule, allot)
                
                # in this case, we need to change the start_time and the load of this one machine
                machine_load[starting_machine_s0].load       += tup[2].ptime
                machine_load[starting_machine_s0].start_time += tup[2].ptime                
            end            
            starting_machine_s0 += tup[1].nb_procs
        end
        
        starting_machine_s1 = starting_machine_s0
        println("starting_machine_s1: $starting_machine_s1")
        for i in 1:length(a_set_1)
            allot = Allotment(a_set_1[i].task_id, 0.0, a_set_1[i].ptime, starting_machine_s1, a_set_1[i].nb_procs)
            push!(schedule, allot)

            for j in 1:(a_set_1[i].nb_procs)
                machine_load[starting_machine_s1+j-1].load       += a_set_1[i].ptime
                machine_load[starting_machine_s1+j-1].start_time  = a_set_1[i].ptime
            end
            starting_machine_s1 += a_set_1[i].nb_procs
        end
        
        # these tasks we glue to the end of the schedule at time 3/2d
        starting_machine_s2 = starting_machine_s0
        println("starting_machine_s2: $starting_machine_s2")
        for i in 1:length(a_set_2)
            allot = Allotment(a_set_2[i].task_id, 3/2*sol_d-a_set_2[i].ptime, a_set_2[i].ptime, starting_machine_s2, a_set_2[i].nb_procs)
            push!(schedule, allot)
            
            for j in 1:(a_set_2[i].nb_procs)
                println("add set 2 load to mach ", starting_machine_s2+j-1)
                machine_load[starting_machine_s2+j-1].load += a_set_2[i].ptime
            end
            
            starting_machine_s2 += a_set_2[i].nb_procs
        end
        
        println("machine_load: $(machine_load)")
        # now it's easy
        # for each small task find machine with lowest load and map it there
        for i in 1:length(sol_set_small)
            task_id = sol_set_small[i]
            ptime   = p[task_id, 1]
            min_load = mapreduce(x->x.load, min, machine_load)
            mach_idx = findfirst(x->x.load == min_load, machine_load)
            println("min load has machine $(mach_idx)")
            allot = Allotment(task_id, machine_load[mach_idx].start_time, ptime, mach_idx, 1)
            push!(schedule, allot)
            machine_load[mach_idx].load       += ptime
            machine_load[mach_idx].start_time += ptime
        end
        
    end
    
    3/2*sol_d, schedule
end
