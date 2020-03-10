# Jobs

One of the basic structures processed in the `Scheduling.jl` package is a `Job`.

## Creating a single job

In order to create a job, you may use the `Job` constructor. Is is required to pass a job name to the constructor, but all the other parameters are optional.

```julia-repl
julia> Job("J")
Job J:  [p = 1]
```

As you can see, the default processing time of a job is equal to 1. Of course, job parameters can be set when the job is created. However, as `Job` is an immutable struct, you are not able to change any of the parameters of an existing job. The structure of the `Job` struct is as follows:

```julia
struct Job
    name::String
    params::JobParams
end
```

while the default params are generated based on the following struct.

```julia
struct ClassicalJobParams <: JobParams
    p::Rational{UInt}     # basic processing time (default: 1)
    w::Rational{Int}      # weight (default: 1)
    r::Rational{UInt}     # ready time (default: 0)
    d::Rational{Int}      # due date (default: Inf)
    D::Rational{UInt}     # deadline (default: Inf)
end
```

It is forbidden to create a job for which `r + p > D`.

```julia-repl
julia> Job("J", ClassicalJobParams(p = 13//2, r = 7//3, d = -3//7))
Job J:  [p = 13//2, r = 7//3, d = -3//7]
```

## Creating a set of jobs

You are provided a few functions that can generate a vector of jobs. A vector of jobs is the basic structure any scheduling algorithm works on. You can create an empty vector of jobs, a vector of a given number of identical jobs or a vector of jobs with arbitrary processing times.

```@docs
Jobs()
Jobs(n::Int)
Jobs(P::Array{Rational{Int}, 1})
Jobs(P::Array{Int, 1})
```

As the set of jobs is a vector of `Job` elements, you may always extend it by a new one.

```julia-repl
julia> J = Jobs()
A set of 0 job(s):

julia> push!(J, Job("J"))
A set of 1 job(s):
    Job J:  [p = 1]

```
