using Logging

mutable struct P2__Cmax_SW3_cell
    # Current load of machine
    load::Real 
    # Remember job ids on each machine
    job_id::Vector{Int64}
end

"""
    P2__Cmax_SW3(J::Vector{Job}, M::Vector{Machine}; eps = 1//10)

This is an FPTAS algorithm for the P2||Cmax problem.

# References
* Schuurman, P., & Woeginger, G. J. (2001), Approximation schemes-a tutorial. Lectures on Scheduling.
"""
function P2__Cmax_SW3(J::Vector{Job}, M::Vector{Machine}; eps = 1//10)
    J = Base.copy(J)
    M = Base.copy(M)

    if length(M) != 2
        # Return an empty schedule
        return Schedule()
    end

    if length(J) <= 0J
        return Schedule()
    end

    n = length(J)
    m = length(M)

    psum = sum(map(x -> x.params.p, J))
    pmax = maximum(map(x -> x.params.p, J))

    delta = 1+eps/(2*n)
    @info "delta=$(delta)"
    
    VS = [ [ 
        [ P2__Cmax_SW3_cell( 0, []  ), P2__Cmax_SW3_cell( J[1].params.p[1], [1]  ) ],
        [ P2__Cmax_SW3_cell( J[1].params.p[1], [1]  ),  P2__Cmax_SW3_cell( 0, []  ) ]
        ] ]
    
    # Create L^2 cells
    L = floor(Int, log(psum)/log(delta))
    @info "L=$(L)"
    
    for k=2:n
        #println("round $(k)")
        cells = falses(L,L)
        newvs = Array{P2__Cmax_SW3_cell,1}[]
        oldvs = VS[k-1]

        for i in 1:length(oldvs)
            ovs = oldvs[i]

            cp_cell1 = deepcopy(ovs[1])
            cp_cell2 = deepcopy(ovs[2])

            new_cell1 = cp_cell1
            #println(typeof(new_cell1))
            new_cell1.load += J[k].params.p
            push!(new_cell1.job_id, k)

            nvs1 = [ new_cell1, ovs[2] ]
            
            if nvs1[1].load == 0
                idx1 = 1
            else
                idx1 = floor(Int, log(nvs1[1].load)/log(delta))
                if idx1 < 1
                    idx1 = 1
                end
            end
            if nvs1[2].load == 0
                idx2 = 1
            else
                idx2 = floor(Int, log(nvs1[2].load)/log(delta))
                if idx2 < 1
                    idx2 = 1
                end
            end
            #println(idx1, idx2)
            if cells[idx1, idx2] == false
                cells[idx1, idx2] = true
                push!(newvs, nvs1)
            end
            

            new_cell2 = cp_cell2
            new_cell2.load += J[k].params.p
            push!(new_cell2.job_id, k)

            nvs2 = [ ovs[1] , new_cell2 ]
            if nvs2[1].load == 0
                idx1 = 1
            else
                idx1 = floor(Int, log(nvs2[1].load)/log(delta))
                if idx1 < 1
                    idx1 = 1
                end
            end
            if nvs2[2].load == 0
                idx2 = 1
            else
                idx2 = floor(Int, log(nvs2[2].load)/log(delta))
                if idx2 < 1
                   idx2 = 1
                end
            end
            if cells[idx1, idx2] == false
                cells[idx1, idx2] = true
                push!(newvs, nvs2)
            end
        end
        
        push!(VS, newvs)
    end
    
    #for i=1:length(p)
    #    println(VS[i])    
    #    println("length VS($(i))=$(length(VS[i]))")
    #end
    
    @info "length VS($(n))=$(length(VS[n]))"
    
    makespan = Rational(typemax(Int64))
    lastvs = VS[n]
    bestsched = nothing
    
    for i=1:length(lastvs)
        #print(".")
        #println(lastvs[i])
        current_cmax = max( lastvs[i][1].load, lastvs[i][2].load )
        #println("curcmax: $(Float64(current_cmax))")
        if current_cmax < makespan
            makespan  = current_cmax
            bestsched = lastvs[i]
        end
    end

    ret_schedule = Schedule() # dummy schedule in case of error
    
    @debug "bestsched: $(bestsched)"

    if ! isnothing(bestsched)

        jobass = JobAssignment[]

        m1_load = 0
        for i = 1:length(bestsched[1].job_id)
            ja = JobAssignment(
                J[bestsched[1].job_id[i]],
                M[1],
                m1_load,
                m1_load + J[bestsched[1].job_id[i]].params.p
            )
            m1_load += J[bestsched[1].job_id[i]].params.p
            push!(jobass, ja)
        end

        m2_load = 0
        for i = 1:length(bestsched[2].job_id)
            ja = JobAssignment(
                J[bestsched[2].job_id[i]],
                M[2],
                m2_load,
                m2_load + J[bestsched[2].job_id[i]].params.p
            )
            m2_load += J[bestsched[2].job_id[i]].params.p
            push!(jobass, ja)
        end

        ret_schedule = Schedule(J, M, jobass)
    end
    #print("Cmax=$(makespan)\n")
    #print("sched=$(bestsched)\n")
    
    ret_schedule
    
end
