using Scheduling
using DataStructures: PriorityQueue, peek

"""
    list(J::Vector{Job}, M::Vector{Machine}; copy = false)

Schedules jobs in the order of their appearance in the `J` vector. If more than one machine can be selected, it selects the machine which is first in the `M` vector. If `copy` is set to true, then the returned structure will refer to the copies of the input vectors.
"""
function list(J::Vector{Job}, M::Vector{Machine}; copy = false)
    if copy
        J = copy(J)
        M = copy(M)
    end

    for j in J
        if j.r != 0
            @warn "The ready time $(j.r) of job $(j.name) assumed to be 0."
        end
        if j.D != Inf
            @warn "The deadline $(j.D) of job $(j.name) assumed to be Inf."
        end
    end

    for m in M
        if m.s != 1
            @warn "The speed $(m.s) of machine $(m.name) assumed to be 1."
        end
    end

    # Generate an empty job assignments list
    A = JobAssignments()

    # All the machines are allocated zero load at the beginning
    pq = PriorityQueue{UInt, Scheduling.MachineLoad}()
    map(mi -> pq[mi] = Scheduling.MachineLoad(UInt(mi), Rational{UInt}(0)), 1:length(M))

    for j in J
        # Find a machine that has the minimum load
        mi, ml = peek(pq)
        # Push an assignment to the list
        push!(A, JobAssignment(j, M[mi], ml.load, ml.load + j.p))
        # Update the load
        pq[mi] = Scheduling.MachineLoad(pq[mi].index, pq[mi].load + j.p)
    end

    return Schedule(J, M, A)
end

"""
    spt(J::Vector{Job}, M::Vector{Machine}; weighted = false, copy = false)

Schedules jobs in the order of their processing times, starting with the shortest one. If `weighted` is set to `true`, then the sorting will be weighted. If `copy` is set to true, then the returned structure will refer to the copies of the input vectors.
"""
function spt(J::Vector{Job}, M::Vector{Machine}; weighted = false, copy = false)
    if copy
        J = copy(J)
        M = copy(M)
    end

    # Sort the jobs vector by the p ratios
    sort!(J, by = j -> (weighted ? (j.p // j.w) : j.p))

    return list(J, M)
end

"""
    wspt(J::Vector{Job}, M::Vector{Machine}; copy = false)

Schedules jobs in the order of their processing times to weight ratios, starting with the lowest one. If `copy` is set to true, then the returned structure will refer to the copies of the input vectors.
"""
wspt(J::Vector{Job}, M::Vector{Machine}; copy = false) = spt(J, M; weighted = true, copy = copy)

"""
    lpt(J::Vector{Job}, M::Vector{Machine}; weighted = false, copy = false)

Schedules jobs in the order of their processing times, starting with the largest one. If `weighted` is set to `true`, then the sorting will be weighted. If `copy` is set to true, then the returned structure will refer to the copies of the input vectors.
"""
function lpt(J::Vector{Job}, M::Vector{Machine}; weighted = false, copy = false)
    if copy
        J = copy(J)
        M = copy(M)
    end

    # Sort the jobs vector by the p ratios
    sort!(J, by = j -> (weighted ? (j.p // j.w) : j.p), rev = true)

    return list(J, M)
end

"""
    wlpt(J::Vector{Job}, M::Vector{Machine}; copy = false)

Schedules jobs in the order of their processing times to weight ratios, starting with the highest one. If `copy` is set to true, then the returned structure will refer to the copies of the input vectors.
"""
wlpt(J::Vector{Job}, M::Vector{Machine}; copy = false) = lpt(J, M; weighted = true, copy = copy)
