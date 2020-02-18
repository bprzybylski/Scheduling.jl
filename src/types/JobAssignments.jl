export JobAssignments

function Base.show(io::IO, ::MIME"text/plain", S::Vector{JobAssignment})
    print("A set of $(size(S)[1]) assignment(s):")
    for A in S
        print(io, "\n\t")
        show(io, A)
    end
end

"""
    function JobAssignments()

Generates an empty vector of `JobAssignment` elements.
"""
function JobAssignments()
    return Vector{JobAssignment}()
end
