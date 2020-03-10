using Scheduling

export nt, wnt

"""
    nt(S::Schedule; weighted = false)

Returns the number of tardy jobs in schedule `S` which are referenced in the `S.jobs` vector. If `weighted` is set to `true`, then the result will be weighted.
"""
function nt(S::Schedule; weighted = false)
    T = []
    for J in S.jobs
        X = filter(A -> A.J === J, S.assignments)
        if length(X) > 0 && (maximum(A -> A.C, X) > J.params.d)
            push!(T, (weighted ? J.params.w : 1))
        end
    end
    if length(T) == 0
        return 0
    end
    return sum(T)
end

"""
    wnt(S::Schedule)

Returns the number of tardy jobs in schedule `S` which are referenced in the `S.jobs` vector. It is an alias for `nt(S::Schedule, weighted = true)`.
"""
wnt(S::Schedule) = nt(S; weighted = true)
