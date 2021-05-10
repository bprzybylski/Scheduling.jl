export JobAssignment, JobAssignments

# export ClassicalJobAssignmentProperties, ParallelJobAssignmentProperties

abstract type JobAssignmentProperties end

struct ClassicalJobAssignmentProperties <: JobAssignmentProperties
    M::Machine
    S::Rational{UInt}     # starting time
    C::Rational{UInt}     # completion time
    function ClassicalJobAssignmentProperties(M, S, C)
        return new(M, S, C)
    end
end

struct ParallelJobAssignmentProperties <: JobAssignmentProperties
    M::Vector{Machine}
    S::Float64        # starting time
    C::Float64        # completion time
    function ParallelJobAssignmentProperties(M, S, C)
        return new(M, S, C)
    end
end

mutable struct JobAssignment
    J::Job
    P::JobAssignmentProperties
    function JobAssignment(J::Job, M::Machine, S, C)
        if S >= C
            error("The execution time must be positive.")
        end        
        return new(J, ClassicalJobAssignmentProperties(M, S, C))
    end
    function JobAssignment(J::Job, M::Vector{Machine}, S, C)
        if S >= C
            error("The execution time must be positive.")
        end
        return new(J, ParallelJobAssignmentProperties(M, S, C))
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
    if isa(A.P, Scheduling.ClassicalJobAssignmentProperties)
        printstyled(io, "$(A.P.M.name)"; bold = true, color = :light_yellow)
        print(io, "[$(rtos(A.P.S)), $(rtos(A.P.C)))")
    elseif isa(A.P, Scheduling.ParallelJobAssignmentProperties)
        for i in 1:length(A.P.M)
            printstyled(io, "$(A.P.M[i].name) "; bold = true, color = :light_yellow)
        end
        print(io, "[$(A.P.S), $(A.P.C))")
    else
        print(io, "UNKNOWN", typeof(A.P))
    end
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

# Example
```julia-repl
julia> JobAssignments()
A set of 0 assignment(s):

```
"""
function JobAssignments()
    return Vector{JobAssignment}()
end
