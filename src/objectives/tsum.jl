using Scheduling

export tsum, wtsum

"""
    tsum(S::Schedule; weighted = false)

Returns the total tardiness of these jobs in schedule `S` which are referenced in the `S.jobs` vector. If `weighted` is set to `true`, then the result will be weighted.
"""
function tsum(S::Schedule; weighted = false)
    T = []
    for J in S.jobs
        X = filter(A -> A.J === J, S.assignments)
        if length(X) > 0
            push!(T, max(maximum(A -> Rational{Int}(A.C), X) - J.params.d, 0)*(weighted ? J.params.w : 1))
        end
    end
    if length(T) == 0
        return 0
    end
    return sum(T)
end

"""
    wtsum(S::Schedule)

Returns the total tardiness of these jobs in schedule `S` which are referenced in the `S.jobs` vector. It is an alias for `tsum(S::Schedule, weighted = true)`.
"""
wtsum(S::Schedule) = tsum(S; weighted = true)
