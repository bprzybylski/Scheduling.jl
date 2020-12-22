export Job, Jobs, JobParams
export ClassicalJobParams, ParallelJobParams

abstract type JobParams end

######################
# ClassicalJobParams #
######################

struct ClassicalJobParams <: JobParams
    p::Rational{UInt}     # basic processing time
    w::Rational{Int}      # weight
    r::Rational{UInt}     # ready time
    d::Rational{Int}      # due date
    D::Rational{UInt}     # deadline
    function ClassicalJobParams(;p = 1, w = 1, r = 0, d = Inf, D = Inf)
        if r + p > D
            error("It is impossible for a job with [r + p > D] to exist.")
        end
        return new(p, w, r, d, D)
    end
end

######################
# ParallelJobParams
######################

struct ParallelJobParams <: JobParams
    p::Array{Float64}     # processing times        
    function ParallelJobParams(p)
        return new(p)
    end
end


#######
# Job #
#######

struct Job
    name::String
    params::JobParams
    function Job(name::String, params = ClassicalJobParams())
        return new(name, params)
    end
    function Job(name::String, params::ParallelJobParams)
        return new(name, params)
    end
end

function Base.show(io::IO, J::Job)
    if typeof(J.params) == ClassicalJobParams
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
        printstyled(io, "$(rtos(J.params.p))"; bold = true, color = :light_cyan)
        if J.params.w != 1
            print(io, ", w = ")
            printstyled(io, "$(rtos(J.params.w))"; bold = true, color = :magenta)
        end
        if J.params.r != 0
            print(io, ", r = ")
            printstyled(io, "$(rtos(J.params.r))"; bold = true, color = :light_black)
        end
        if J.params.d != Inf
            print(io, ", d = ")
            printstyled(io, "$(rtos(J.params.d))"; bold = true, color = :light_black)
        end
        if J.params.D != Inf
            print(io, ", D = ")
            printstyled(io, "$(rtos(J.params.D))"; bold = true, color = :light_black)
        end
        print(io, "]")
    else
        print(io, "Job ")
        printstyled(io, "$(J.name)"; bold = true, color = :light_blue)
        print(io, "[$(typeof(J.params))]")
    end
end

function Base.show(io::IO, ::MIME"text/plain", S::Vector{Job})
    print("A set of $(length(S)) job(s):")
    for J in S
        print(io, "\n\t")
        show(io, J)
    end
end

##############
# Generators #
##############

"""
    Jobs()

Generates an empty vector of `Job{ClassicalJobParams}` elements.

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
​    Job J_1:    [p = 1]
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
​    Job J_1:    [p = 1//2]
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
            push!(J, Job("J_$i", ClassicalJobParams(p = P[i])))
        else
            push!(J, Job("J_{$i}", ClassicalJobParams(p = P[i])))
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
