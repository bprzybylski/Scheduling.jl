using Scheduling

export lmax

"""
    lmax(S::Schedule)

Returns the maximum lateness in schedule `S`. If the schedule is empty, then the function returns `-Inf`.
"""
function lmax(S::Schedule)
    if length(S.assignments) == 0
        return -Inf
    end
    # If a single job has more than one assignment, then
    # the maximum lateness of this job is the lateness
    # of its last part. Thus, the maximum lateness in
    # a schedule is the maximum lateness from all assignments.
    return maximum(A->(Rational{Int}(A.P.C) - A.J.params.d), S.assignments)
end
