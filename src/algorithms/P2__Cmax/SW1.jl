
# Schuurman, P., & Woeginger, G. J. (2001). 
# Approximation schemes-a tutorial. Lectures on Scheduling.

# Copright (c) 2021, sahu

function SW1(J::Array{Job}, M::Vector{Machine}; eps = 1//10)::Schedule

    if length(M) != 2
        # return empty schedule
        return Schedule()
    end

    makespan = 0.0 
    bestsched = [0.0, 0.0]
    
    psum = sum(map(x -> x.params.p, J))
    pmax = maximum(map(x -> x.params.p, J))
    
    L = max(psum/2, pmax)
    
    bound = eps * L
    
    print("\nepsilon=$(eps)\n")
    print("L=$(L)\n")
    print("bound=$(bound)\n")
    
    idx_small = findall( x -> x.params.p <= bound, J )
    #app_psmall = p[idx_small]
    
    idx_large = findall( x -> x.params.p > bound, J )
    #app_plarge = sum(map(x -> x.params.p, J[idx_large]))
    
    print("n large: $(length(idx_large))\n")
    print("n small: $(length(idx_small))\n")
    
    S = 0
    if length(idx_small) > 0
        S = sum(map(x -> x.params.p, J[idx_small]))
    end

    print("S=$(S)\n")
    print("S/(eps*L)=$(S/(eps*L))\n")
    nchunks = floor(Int64, S/(eps*L))
    print("⌊S/(eps*L)⌋=$(nchunks)\n")
    
    ntasks = length(idx_large) + nchunks
    print("n tasks in simplified instance: $(ntasks)\n")
    
    sum_large = 0
    if length(idx_large) > 0
        sum_large = sum(map(x -> x.params.p, J[idx_large]))
    end
    app_psum = sum_large + nchunks * bound
    print("total ptime in I : $(psum)\n")
    print("total ptime in I#: $(app_psum)\n")
        
    # create a simplified instance
    # create a copy of the large tasks
    Jsim = Job[]
    for i=1:length(idx_large)
        push!(Jsim, deepcopy(J[idx_large[i]]))
    end
    # create dummy tasks
    for i=1:nchunks
        dj = Job("dummy" * string(i), ClassicalJobParams(p=bound))
        push!(Jsim, dj)
    end

    #simp_instance = vcat(app_plarge, fill(bound, nchunks))
    println("simplified instance: $(Jsim)")
    
    sched = Algorithms.P__Cmax_IP(Jsim, M)

    #solution = solve_p_cmax(simp_instance, length(simp_instance), 2)
    println("solution=$(sched)")
    
    # translate it back
    # lets get the large tasks first
    approx_jobass = JobAssignment[]
    mach_times = [0, 0]
    s1 = 0.0   # total sum of small jobs on machine 1
    
    for i in 1:length(sched.assignments)
        jobass = sched.assignments[i]
        mach_idx = findfirst(x -> x == jobass.P.M, M)
        if mach_idx == 1
            if jobass.J.params.p <= bound
                s1 += jobass.J.params.p
            else
                # add large job to mach 1
                push!(approx_jobass, jobass)
                mach_times[1] += jobass.J.params.p
            end
        else
            if jobass.J.params.p > bound
                # add large job to mach 2
                push!(approx_jobass, jobass)
                mach_times[2] += jobass.J.params.p
            end
        end
    end
    
    bound_m1 = s1 + 2*eps*L
    stack_m1 = 0.0
    # fill small jobs up to this bound on machine 1
    filled_m1 = false
    println("bound_m1: $(bound_m1)")
    
    for i in 1:length(idx_small)
        if filled_m1 == false
            if stack_m1 + J[idx_small[i]].params.p <= bound_m1
                stack_m1 += J[idx_small[i]].params.p
                push!(approx_jobass, 
                    JobAssignment(
                        J[idx_small[i]],
                        M[1],
                        mach_times[1],
                        mach_times[1] + J[idx_small[i]].params.p
                    )
                )
                mach_times[1] += J[idx_small[i]].params.p
            else
                filled_m1 = true
            end
        end
        if filled_m1 == true
            push!(approx_jobass, 
                JobAssignment(
                    J[idx_small[i]],
                    M[2],
                    mach_times[2],
                    mach_times[2] + J[idx_small[i]].params.p
                )
            )
            mach_times[2] += J[idx_small[i]].params.p
        end
    end
    
    Schedule(J, M, approx_jobass)
end    