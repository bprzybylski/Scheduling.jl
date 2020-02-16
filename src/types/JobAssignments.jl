const JobAssignments = Vector{JobAssignment}

function Base.show(io::IO, ::MIME"text/plain", S::JobAssignments)
    print("A set of $(size(S)[1]) assignment(s):")
    for A in S
        print(io, "\n\t")
        show(io, A)
    end
end
