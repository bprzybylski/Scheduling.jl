using Scheduling
using DataStructures: PriorityQueue, peek

"""
    list!(J::Vector{Job}, M::Vector{Machine})

Schedules jobs in the order of their appearance in the `J` vector. If more than one machine can be selected, it selects the machine which is first in the `M` vector. This algorithm works on original `J` and `M` vectors which are also returned with the resulting schedule. In order to use copies, see `list`.

This algorithm is based on the following job parameters: `p` (processing time).
"""
function list!(J::Vector{Job}, M::Vector{Machine})
    # Generate an empty job assignments list
    A = JobAssignments()

    # All the machines are allocated zero load at the beginning
    pq = PriorityQueue{UInt, Scheduling.MachineLoad}()
    map(mi -> pq[mi] = Scheduling.MachineLoad(UInt(mi), Rational{UInt}(0)), 1:length(M))

    for j in J
        # Find a machine that has the minimum load
        mi, ml = peek(pq)
        # Push an assignment to the list
        push!(A, JobAssignment(j, M[mi], ml.load, ml.load + j.params.p))
        # Update the load
        pq[mi] = Scheduling.MachineLoad(pq[mi].index, pq[mi].load + j.params.p)
    end

    return Schedule(J, M, A)
end

"""
    list(J::Vector{Job}, M::Vector{Machine})

The same as `list!`, but it copies the input vectors before the algorithm starts.
"""
function list(J::Vector{Job}, M::Vector{Machine})
    J = Base.copy(J)
    M = Base.copy(M)
    list!(J, M)
end

"""
    spt!(J::Vector{Job}, M::Vector{Machine}; weighted = false)

Schedules jobs in the order of their processing times, starting with the shortest one. If `weighted` is set to `true`, then the sorting will be weighted. This algorithm works on original `J` and `M` vectors which are also returned with the resulting schedule. In order to use copies, see `spt`.

This algorithm is based on the following job parameters: `p` (processing time), `w` (weight).
"""
function spt!(J::Vector{Job}, M::Vector{Machine}; weighted = false)
    # Sort the jobs vector by the p ratios
    sort!(J, by = j -> (weighted ? (j.params.p // j.params.w) : j.params.p))

    return list(J, M)
end

"""
    spt(J::Vector{Job}, M::Vector{Machine}; weighted = false)

The same as `spt!`, but it copies the input vectors before the algorithm starts.
"""
function spt(J::Vector{Job}, M::Vector{Machine}; weighted = false)
    J = Base.copy(J)
    M = Base.copy(M)
    spt!(J, M; weighted = weighted)
end

"""
    wspt!(J::Vector{Job}, M::Vector{Machine})

Schedules jobs in the order of their processing times to weight ratios, starting with the lowest one. This algorithm works on original `J` and `M` vectors which are also returned with the resulting schedule. In order to use copies, see `wspt`.

This algorithm is based on the following job parameters: `p` (processing time), `w` (weight).
"""
wspt!(J::Vector{Job}, M::Vector{Machine}) = spt!(J, M; weighted = true)

"""
    wspt(J::Vector{Job}, M::Vector{Machine})

The same as `wspt!`, but it copies the input vectors before the algorithm starts.
"""
function wspt(J::Vector{Job}, M::Vector{Machine})
    J = Base.copy(J)
    M = Base.copy(M)
    wspt!(J, M)
end

"""
    lpt!(J::Vector{Job}, M::Vector{Machine}; weighted = false)

Schedules jobs in the order of their processing times, starting with the largest one. If `weighted` is set to `true`, then the sorting will be weighted. This algorithm works on original `J` and `M` vectors which are also returned with the resulting schedule. In order to use copies, see `lpt`.

This algorithm is based on the following job parameters: `p` (processing time), `w` (weight).
"""
function lpt!(J::Vector{Job}, M::Vector{Machine}; weighted = false)
    # Sort the jobs vector by the p ratios
    sort!(J, by = j -> (weighted ? (j.params.p // j.params.w) : j.params.p), rev = true)

    return list(J, M)
end

"""
    lpt(J::Vector{Job}, M::Vector{Machine}; weighted = false)

The same as `lpt!`, but it copies the input vectors before the algorithm starts.
"""
function lpt(J::Vector{Job}, M::Vector{Machine}; weighted = false)
    J = Base.copy(J)
    M = Base.copy(M)
    lpt!(J, M; weighted = weighted)
end

"""
    wlpt!(J::Vector{Job}, M::Vector{Machine}; copy = false)

Schedules jobs in the order of their processing times to weight ratios, starting with the highest one. This algorithm works on original `J` and `M` vectors which are also returned with the resulting schedule. In order to use copies, see `wlpt`.

This algorithm is based on the following job parameters: `p` (processing time), `w` (weight).
"""
wlpt!(J::Vector{Job}, M::Vector{Machine}) = lpt!(J, M; weighted = true)

"""
    wlpt(J::Vector{Job}, M::Vector{Machine})

The same as `wlpt!`, but it copies the input vectors before the algorithm starts.
"""
function wlpt(J::Vector{Job}, M::Vector{Machine})
    J = Base.copy(J)
    M = Base.copy(M)
    wlpt!(J, M)
end
