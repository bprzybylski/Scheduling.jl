# Assignments

Given a job and a machine, one can assign a job to the machine. In order to create an assignment, you need a reference to a job (either a standalone one, or one from a vector), a reference to a machine, a starting time and a completion time.

```julia
mutable struct JobAssignment
    J::Job
    M::Machine
    S::Rational{UInt}     # starting time
    C::Rational{UInt}     # completion time
end
```

It is expected that `S < C`. Otherwise, an error will occur.

```julia-repl
julia> J = Job("J")
Job J:  [p = 1]

julia> M = Machine("M")
Machine M

julia> JobAssignment(J, M, 2, 4)
J → M[2, 4)

```

Assignments can be stored in vectors.

```@docs
JobAssignments()
```
