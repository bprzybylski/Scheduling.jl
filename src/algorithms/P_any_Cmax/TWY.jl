using Scheduling, Scheduling.Objectives

# J. Turek, J. L. Wolf, and P. S. Yu. 
# “Approximate Algorithms Scheduling Parallelizable Tasks”. 
# In: SPAA. ACM, 1992, pp. 323–332. DOI: 10.1145/140901.141909.

function TWY(J::Array{Job}, M::Vector{Machine})::Schedule    
    best_schedule = nothing
    best_makespan = typemax(Int64)

    for allot in gf(J, M)
        
        println("allotment: $(allot)")
        
        schedule = ltf_c(J, M, allot)

        makespan = cmax(schedule)
        
        if makespan < best_makespan
            best_makespan = makespan
            best_schedule = schedule
        end
        
    end

    best_schedule
end


#
# GF algorithm
# 

# returns all possible allotments
function gf(J::Array{Job}, M::Vector{Machine})
    allotments = Array{Array{Int64,1},1}()
    
    n = length(J)
    m = length(M)

    # first candidate is with min work
    allotment = Array{Int64}(undef, n)
    for i in 1:n
        best_j = argmin(map(x -> J[i].params.p[x]*x, 1:m))
        #println("best_j=$(best_j)")
        allotment[i] = best_j
    end
    # remember first allotment
    push!(allotments, allotment)
    
    done = false
    cur_allotment = allotment
    while !done
        #println("cur_allotment: $(cur_allotment)")
        # index with largest runtime
        cur_proctime = map(x-> J[x].params.p[cur_allotment[x]], 1:n)
        #println("cur_proctime: $(cur_proctime)")
        i_idx = argmax(cur_proctime)
        if cur_allotment[i_idx] == m
            done = true
            break
        end
        
        
        work_of_allocs = map(x -> J[i_idx].params.p[x]*x, (cur_allotment[i_idx]+1):m)
        #println("work_of_allocs: ", work_of_allocs)
        #println("argmin(work_of_allocs): ", argmin(work_of_allocs))
        nprocs = cur_allotment[i_idx] + argmin(work_of_allocs)
        new_allotment = copy(cur_allotment)
        new_allotment[i_idx] = nprocs
        #println("allot task $(i_idx) $(nprocs) processors")
        #println(typeof(new_allotment))
        push!(allotments, new_allotment)
        cur_allotment = new_allotment
        
    end
    
    #println(allotments)
    allotments        
end



# LTF-C algorithm

# Coffman, E. G., Jr, Garey, M. R., Johnson, D. S., & Tarjan, R. E. (1980). 
# Performance Bounds for Level-Oriented Two-Dimensional Packing Algorithms. 
# SIAM J. Comput., 9(4), 808–826. http://doi.org/10.1137/0209062
#
# called it Next-Fit Decreasing Height (NFDH) algorithm
# tight bound 3 * OPT(L) for all lists L

function ltf_c(J::Array{Job}, M::Vector{Machine}, allot::Vector{Int64})
    
    n = length(J)
    m = length(M)

    job_ids = collect(1:n)

    sort!(job_ids, by = x -> J[x].params.p[allot[x]], rev=true)

    print("sorted: ", job_ids)
    
    shelf_start = 0.0
    used_nproc_in_shelf = 0
    shelf_height = J[job_ids[1]].params.p[allot[job_ids[1]]]
    
    jobass = Vector{JobAssignment}()
    
    for i in 1:n
        if used_nproc_in_shelf + allot[job_ids[i]] <= m
            # still fits in shelf

            #println("shelf_start:", shelf_start)

            jass = JobAssignment(
                J[job_ids[i]],  # take the job at this position,
                M[ (used_nproc_in_shelf+1):(used_nproc_in_shelf+allot[job_ids[i]]) ],  # select a range of machines
                shelf_start, 
                shelf_start + J[job_ids[i]].params.p[allot[job_ids[i]]],  # finish time
            )

            used_nproc_in_shelf += allot[job_ids[i]]

            push!(jobass, jass)
        else
            # start new shelf
            shelf_start += shelf_height
            shelf_height = J[job_ids[i]].params.p[allot[job_ids[i]]]

            used_nproc_in_shelf = 0

            jass = JobAssignment(
                J[job_ids[i]],  # take the job at this position,
                M[ (used_nproc_in_shelf+1):(used_nproc_in_shelf+allot[job_ids[i]]) ],  # select a range of machines
                shelf_start, 
                shelf_start + J[job_ids[i]].params.p[allot[job_ids[i]]],  # finish time
            )

            used_nproc_in_shelf = allot[job_ids[i]]

            push!(jobass, jass)
        end
    end
        
        
    Schedule(J, M, jobass)
end
