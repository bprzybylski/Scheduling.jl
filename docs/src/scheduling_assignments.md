# Assignments

Given a job and a machine, one can assign a job to the machine(s). In order to create an assignment, you need a reference to a job (either a standalone one, or one from a vector), a machine (classical jobs) or a vector of machines (parallel jobs), and job starting and completion times. In case of classical jobs, start and completion times must be rational numbers, while for classical jobs they can be floats.

```julia-repl
julia> J = Job("J")
Classical job J:        [p = 1]

julia> M = Machine("M")
Machine M

julia> JobAssignment(J, M, 2, 4)
J → M[2, 4)
```

```julia-repl
julia> J = Job("J")
Classical job J:        [p = 1]

julia> M = Machines(2)
A set of 2 machine(s):
        Machine P_1
        Machine P_2

julia> JobAssignment(J, M, 2, 4)
J → P_1 P_2 [2.0, 4.0)
```

Assignments can be stored in vectors.

```@docs
JobAssignments()
```
