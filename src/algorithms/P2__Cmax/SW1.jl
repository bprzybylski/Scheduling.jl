using Logging

"""
    P2__Cmax_SW1(J::Vector{Job}, M::Vector{Machine}; eps = 1//10)

This is a (1 + eps)-approximation algorithm for the P2||Cmax problem.

# References
* Schuurman, P., & Woeginger, G. J. (2001), Approximation schemes-a tutorial. Lectures on Scheduling.
"""
function P2__Cmax_SW1(J::Vector{Job}, M::Vector{Machine}; eps = 1//10)
    J = Base.copy(J)
    M = Base.copy(M)

    if length(M) != 2
        # Return an empty schedule
        return Schedule()
    end

    # The algorithm is (1 + 3eps)-approximation, so divide by three to get the desired precision
    eps /= 3

    makespan = 0.0 
    bestsched = [0.0, 0.0]
    
    psum = sum(map(x -> x.params.p, J))
    pmax = maximum(map(x -> x.params.p, J))
    
    L = max(psum/2, pmax)
    
    bound = eps * L
    
    @info "epsilon=$(eps)"
    @info "L=$(L)"
    @info "bound=$(bound)"
    
    idx_small = findall( x -> x.params.p <= bound, J )
    #app_psmall = p[idx_small]
    
    idx_large = findall( x -> x.params.p > bound, J )
    #app_plarge = sum(map(x -> x.params.p, J[idx_large]))
    
    @info "n large: $(length(idx_large))\n"
    @info "n small: $(length(idx_small))\n"
    
    S = 0
    if length(idx_small) > 0
        S = sum(map(x -> x.params.p, J[idx_small]))
    end

    @info "S=$(S)"
    @info "S/(eps*L)=$(S/(eps*L))"
    nchunks = floor(Int64, S/(eps*L))
    @info "⌊S/(eps*L)⌋=$(nchunks)"
    
    ntasks = length(idx_large) + nchunks
    @info "n tasks in simplified instance: $(ntasks)"
    
    sum_large = 0
    if length(idx_large) > 0
        sum_large = sum(map(x -> x.params.p, J[idx_large]))
    end
    app_psum = sum_large + nchunks * bound
    @info "total ptime in I : $(psum)"
    @info "total ptime in I#: $(app_psum)"
        
    # Create a simplified instance
    # Create a copy of the large tasks
    Jsim = Job[]
    for i=1:length(idx_large)
        push!(Jsim, deepcopy(J[idx_large[i]]))
    end
    # Create dummy tasks
    for i=1:nchunks
        dj = Job("dummy" * string(i), ClassicalJobParams(p=bound))
        push!(Jsim, dj)
    end

    #simp_instance = vcat(app_plarge, fill(bound, nchunks))
    @debug "simplified instance: $(Jsim)"
    
    sched = Algorithms.P__Cmax_IP(Jsim, M)

    #solution = solve_p_cmax(simp_instance, length(simp_instance), 2)
    @debug "solution=$(sched)"
    
    # Translate it back
    # Lets get the large tasks first
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
    # Fill small jobs up to this bound on machine 1
    filled_m1 = false
    @debug "bound_m1: $(bound_m1)"
    
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