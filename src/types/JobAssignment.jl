export JobAssignment, JobAssignments

mutable struct JobAssignment
    J::Job
    M::Machine
    S::Rational{UInt}     # starting time
    C::Rational{UInt}     # completion time
    function JobAssignment(J::Job, M::Machine, S, C)
        if S >= C
            error("The execution time must be positive.")
        end
        return new(J, M, S, C)
    end
end

function Base.show(io::IO, A::JobAssignment)
    function rtos(r::Rational)
        if r == Inf
            return "∞"
        elseif denominator(r) == 1
            return string(numerator(r))
        end
        return string(numerator(r), "//", denominator(r))
    end

    printstyled(io, "$(A.J.name)"; bold = true, color = :light_blue)
    print(io, " → ")
    printstyled(io, "$(A.M.name)"; bold = true, color = :light_yellow)
    print(io, "[$(rtos(A.S)), $(rtos(A.C)))")
end

function Base.show(io::IO, ::MIME"text/plain", S::Vector{JobAssignment})
    print("A set of $(size(S)[1]) assignment(s):")
    for A in S
        print(io, "\n\t")
        show(io, A)
    end
end

"""
    JobAssignments()

Generates an empty vector of `JobAssignment` elements.
"""
function JobAssignments()
    return Vector{JobAssignment}()
end
