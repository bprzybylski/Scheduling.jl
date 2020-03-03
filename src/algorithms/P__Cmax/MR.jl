"""
    P__Cmax_MR(J::Vector{Job}, M::Vector{Machine}; copy = false)

An approximation approach to the online version of the P||Cmax problem proposed by Fleischer and Wahl (2000, p. 345). If `copy` is set to true, then the returned structure will refer to the copies of the input vectors.

# References
* R. Fleischer and M. Wahl, On-line scheduling revisited, Journal of Scheduling, 3:343–353 (2000), doi: 10.1002/1099-1425(200011/12)3:6<343::AID-JOS54>3.0.CO;2-2
"""
function P__Cmax_MR(J::Vector{Job}, M::Vector{Machine}; copy = false)
    if copy
        J = Base.copy(J)
        M = Base.copy(M)
    end

    # Generate an empty job assignments list
    A = JobAssignments()

    # Get the number of jobs
    n = length(J)
    # Get the number of machines
    m = length(M)

    if m < 5
        error("The algorithm requires at least five machines")
    end

    # All the machines are allocated zero load at the beginning
    ml = Vector{MachineLoad}()
    for i in 1:m
        push!(ml, MachineLoad(UInt(i), Rational{UInt}(0)))
    end

    # Set the parameters
    mr_C = 1 + sqrt((1 + log(2))/2)
    mr_I = Int(ceil(m*(5*mr_C - 2*mr_C*mr_C - 1)/mr_C) - 1)
    mr_K = 2*mr_I - m

    D(j) = sum(l -> l.load, ml[j:m]) * (1/(m-j+1))
    flat() = ml[mr_K].load < D(mr_I + 1) * 2 * (mr_C - 1) / (2*mr_C - 3)

    # Schedule jobs one at a time
    for i in 1:n
        # Select a machine
        if !flat() || J[i].p + ml[mr_I].load > mr_C * sum(j -> j.p, J) / m
            push!(A, JobAssignment(J[i], M[ml[m].index], ml[m].load, ml[m].load + J[i].p))
            ml[m].load = ml[m].load + J[i].p
        else
            push!(A, JobAssignment(J[i], M[ml[mr_I].index], ml[mr_I].load, ml[mr_I].load + J[i].p))
            ml[mr_I].load = ml[mr_I].load + J[i].p
        end

        # Make sure that the ml vector is sorted after the change
        sort!(ml, by = X -> X.load, rev=true)
    end

    return Schedule(J, M, A)
end
