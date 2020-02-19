using Scheduling

export cmax

"""
    cmax(S::Schedule)

Returns the maximum completion time in schedule `S`.
"""
function cmax(S::Schedule)
    if length(S.assignments) == 0
        return 0
    end
    return maximum(A->A.C, S.assignments)
end
