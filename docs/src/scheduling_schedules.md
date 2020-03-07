# Schedules

A schedule (in the sense of `Scheduling.jl` package) consists of three parts:

* a vector of jobs,
* a vector of machines,
* a vector of job assignments.

```julia
mutable struct Schedule
    jobs::Vector{Job}
    machines::Vector{Machine}
    assignments::Vector{JobAssignment}
end
```

## Creating a schedule

A schedule can be created easily by assigning vectors of jobs, machines, and assignments to a structure of `Schedule` type.

```julia-repl
julia> M = Machines()
A set of 0 machine(s):

julia> push!(M, Machine("M"))
A set of 1 machine(s):
    Machine M

```

!!! note

    When creating a schedule, take the following guidelines into account:

    * It is highly recommended, for further compatibility purposes, that any job reference in the `assignments` vector is also stored in the `jobs` vector. The same rule applies to machines.
    * The `machines` vector is used when a plotting/exporting function is called. If there exists an assignment of a job to a machine, such that the reference to the machine is not stored in the `machines` vector, then the behavior of the plotting/exporting function may be unexpected.

## Plotting/exporting a schedule

A schedule can be plotted (using `PyPlot`) or exported (as a $\TeX$ file).

```@docs
Scheduling.plot(S::Schedule;
     animate = false, sizex = 800, sizey = 500,
     output_file::String = "Schedule.gif", fps = 1)
Scheduling.TeX(S::Schedule, output_file::String = "Schedule.tex"; compile = false)
```

## Saving/loading a schedule

A `Schedule` structure can be easily saved to a file and then loaded back. The `Scheduling` package uses the HDF5 binary files to store structures.

```@docs
Scheduling.save(S::Schedule, output_file::String = "Schedule.jld")
Scheduling.load(input_file::String = "Schedule.jld")
```
