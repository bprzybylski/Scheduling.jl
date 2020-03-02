using JuMP, GLPK

"""
    P__Cmax(J::Vector{Job}, M::Vector{Machine}; optimizer = GLPK.Optimizer, copy = false)

Solves the P||Cmax problem by applying the simple IP proposed by Drozdowski (2009, p. 23). By default, the open source GLPK optimizer together with JuMP is used. If `copy` is set to true, then the returned structure will refer to the copies of the input vectors.

# References
* M.Drozdowski, Scheduling for Parallel Processing, Springer-Verlag, London, 2009, ISBN: 978-1-84882-309-9.
"""
function P__Cmax(J::Vector{Job}, M::Vector{Machine}; optimizer = GLPK.Optimizer, copy = false)
    if copy
        J = copy(J)
        M = copy(M)
    end

    for j in J
        if denominator(j.p) != 1
            error("Job $(j.name) has a non-integer processing time.")
        end
    end

    # Set up the model
    model = Model(optimizer)

    # Get the number of jobs
    n = length(J)
    # Get the number of machines
    m = length(M)

    # [2.9] Each job is either assigned to a machine, or not
    @variable(model, x[1:n,1:m], Bin)
    # The objective is cmax
    @variable(model, cmax >= 0, Int)

    # [2.6] The objective is to minimize the cmax
    @objective(model, Min, cmax)

    # [2.8] Each job should be assigned to exactly one machine
    for i in 1:n
        @constraint(model, sum(x[i,j] for j=1:m) == 1)
    end

    # [2.7] Each machine should have a load lower or equal to cmax
    for j in 1:m
        @constraint(model, sum(x[i,j]*J[i].p for i=1:n) <= cmax)
    end

    optimize!(model)

    # Generate an empty job assignments list
    A = JobAssignments()

    # Get the assignments from the solution
    x = value.(x)

    # Use the IP solution to determine the assignments
    for j in 1:m
        load = Rational{UInt}(0)
        for i in 1:n
            if x[i,j] == 1
                push!(A, JobAssignment(J[i], M[j], load, load + J[i].p))
                load = load + J[i].p
            end
        end
    end

    return Schedule(J, M, A)
end
