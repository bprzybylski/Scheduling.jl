using Scheduling

export csum, wcsum

"""
    csum(S::Schedule; weighted = false)

Returns the total completion time of these jobs in schedule `S` which are referenced in the `S.jobs` vector. If `weighted` is set to `true`, then the result will be weighted.
"""
function csum(S::Schedule; weighted = false)
    C = []
    for J in S.jobs
        X = filter(A -> A.J === J, S.assignments)
        if length(X) > 0
            push!(C, maximum(A -> Rational{Int}(A.P.C), X)*(weighted ? J.params.w : 1))
        end
    end
    if length(C) == 0
        return 0
    end
    return sum(C)
end

"""
    wcsum(S::Schedule)

Returns the total weighted completion time of these jobs in schedule `S` which are referenced in the `S.jobs` vector. It is an alias for `csum(S::Schedule, weighted = true)`.
"""
wcsum(S::Schedule) = csum(S; weighted = true)
