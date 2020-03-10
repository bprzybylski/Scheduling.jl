"""
    P__Cmax_MR!(J::Vector{Job}, M::Vector{Machine})

An approximation approach to the online version of the P||Cmax problem proposed by Fleischer and Wahl (2000, p. 345). This algorithm works on original `J` and `M` vectors which are also returned with the resulting schedule. In order to use copies, see `P__Cmax_MR`.

This algorithm is based on the following job parameters: `p` (processing time).

# References
* R. Fleischer and M. Wahl, On-line scheduling revisited, Journal of Scheduling, 3:343–353 (2000), doi: 10.1002/1099-1425(200011/12)3:6<343::AID-JOS54>3.0.CO;2-2
"""
function P__Cmax_MR!(J::Vector{Job}, M::Vector{Machine})
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
    ml = Vector{Scheduling.MachineLoad}()
    for i in 1:m
        push!(ml, Scheduling.MachineLoad(UInt(i), Rational{UInt}(0)))
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
        if !flat() || J[i].params.p + ml[mr_I].load > mr_C * sum(j -> j.params.p, J) / m
            push!(A, JobAssignment(J[i], M[ml[m].index], ml[m].load, ml[m].load + J[i].params.p))
            ml[m].load = ml[m].load + J[i].params.p
        else
            push!(A, JobAssignment(J[i], M[ml[mr_I].index], ml[mr_I].load, ml[mr_I].load + J[i].params.p))
            ml[mr_I].load = ml[mr_I].load + J[i].params.p
        end

        # Make sure that the ml vector is sorted after the change
        sort!(ml, by = X -> X.load, rev=true)
    end

    return Schedule(J, M, A)
end

"""
    P__Cmax_MR(J::Vector{Job}, M::Vector{Machine})

The same as `P__Cmax_MR!`, but it copies the input vectors before the algorithm starts.
"""
function P__Cmax_MR(J::Vector{Job}, M::Vector{Machine})
    J = Base.copy(J)
    M = Base.copy(M)
    P__Cmax_MR!(J, M)
end
