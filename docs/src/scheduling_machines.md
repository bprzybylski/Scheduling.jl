# Machines

Another basic structure provided by the `Scheduling.jl` package is a `Machine`.

## Creating a single machine

In order to create a machine, you may use the `Machine` constructor. Is is required to pass a machine name to the constructor, but all the other parameters are optional.

```julia-repl
julia> Machine("M")
Machine M
```

Machine parameters can be set when the machine is created. However, as `Machine` is an immutable struct, you are not able to change any of the parameters of an existing job. Below we present all the possible parameters together with their default values:

```julia
struct Machine
    name::String
    s::Rational{UInt}   # speed (default: 1)
end
```

## Creating a set of machines

You are provided a few functions that can generate a vector of jobs. A vector of jobs is the basic structure any scheduling algorithm works on. You can create an empty vector of jobs, a vector of a given number of identical jobs or a vector of jobs with arbitrary processing times.

```@docs
Machines()
Machines(n::Int)
Machines(P::Array{Rational{Int}, 1})
Machines(P::Array{Int, 1})
```

As the set of machines is a vector of `Machine` elements, you may always extend it by a new one.

```julia-repl
julia> M = Machines()
A set of 0 machine(s):

julia> push!(M, Machine("M"))
A set of 1 machine(s):
    Machine M

```
