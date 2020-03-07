export Job, Jobs

struct Job
    name::String
    p::Rational{UInt}     # basic processing time
    w::Rational{Int}      # weight
    r::Rational{UInt}     # ready time
    d::Rational{Int}      # due date
    D::Rational{UInt}     # deadline
    function Job(name::String; p = 1, w = 1, r = 0, d = Inf, D = Inf)
        if r + p > D
            error("It is impossible for a job with [r + p > D] to exist.")
        end
        return new(name, p, w, r, d, D)
    end
end

function Base.show(io::IO, J::Job)
    function rtos(r::Rational)
        if r == Inf
            return "∞"
        elseif denominator(r) == 1
            return string(numerator(r))
        end
        return string(numerator(r), "//", denominator(r))
    end

    print(io, "Job ")
    printstyled(io, "$(J.name):\t"; bold = true, color = :light_blue)
    print(io, "[p = ")
    printstyled(io, "$(rtos(J.p))"; bold = true, color = :light_cyan)
    if J.w != 1
        print(io, ", w = ")
        printstyled(io, "$(rtos(J.w))"; bold = true, color = :magenta)
    end
    if J.r != 0
        print(io, ", r = ")
        printstyled(io, "$(rtos(J.r))"; bold = true, color = :light_black)
    end
    if J.d != Inf
        print(io, ", d = ")
        printstyled(io, "$(rtos(J.d))"; bold = true, color = :light_black)
    end
    if J.D != Inf
        print(io, ", D = ")
        printstyled(io, "$(rtos(J.D))"; bold = true, color = :light_black)
    end
    print(io, "]")
end

function Base.show(io::IO, ::MIME"text/plain", S::Vector{Job})
    print("A set of $(size(S)[1]) job(s):")
    for J in S
        print(io, "\n\t")
        show(io, J)
    end
end

"""
    Jobs()

Generates an empty vector of `Job` elements.

# Example
```julia-repl
julia> Jobs()
A set of 0 job(s):

```
"""
function Jobs()
    return Vector{Job}()
end

"""
    Jobs(n::Int)

Generates a set of `n` identical unit jobs, denoted by `J_1`, `J_2`, etc.

# Example
```julia-repl
julia> Jobs(4)
A set of 4 job(s):
    Job J_1:    [p = 1]
    Job J_2:    [p = 1]
    Job J_3:    [p = 1]
    Job J_4:    [p = 1]

```
"""
function Jobs(n::Int)
    J = Jobs()

    for i in 1:n
        if i < 10
            push!(J, Job("J_$i"))
        else
            push!(J, Job("J_{$i}"))
        end
    end

    return J
end

"""
    Jobs(P::Array{Rational{Int}, 1})

Generates a set of jobs with basic processing times determined by the `P` array, denoted by `J_1`, `J_2`, etc.

# Example
```julia-repl
julia> Jobs([1//2, 3, 5//3, 7])
A set of 4 job(s):
    Job J_1:    [p = 1//2]
    Job J_2:    [p = 3]
    Job J_3:    [p = 5//3]
    Job J_4:    [p = 7]

```
"""
function Jobs(P::Array{Rational{Int}, 1})
    J = Jobs()

    for i in 1:length(P)
        if P[i] <= 0
            error("Job $i cannot have a non-positive processing time.")
        end
        if i < 10
            push!(J, Job("J_$i", p = P[i]))
        else
            push!(J, Job("J_{$i}", p = P[i]))
        end
    end

    return J
end

"""
    Jobs(P::Array{Int, 1})

Generates a set of jobs with basic processing times determined by the `P` array, denoted by `J_1`, `J_2`, etc.

# Example
```julia-repl
julia> Jobs([1, 5, 6, 2])
A set of 4 job(s):
    Job J_1:    [p = 1]
    Job J_2:    [p = 5]
    Job J_3:    [p = 6]
    Job J_4:    [p = 2]

```
"""
Jobs(P::Array{Int, 1}) = Jobs(Array{Rational{Int},1}(P))
