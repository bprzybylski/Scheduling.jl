using Scheduling, Scheduling.Algorithms, Test, Printf, Random, Distributions

function generate_instance(n_jobs::Int, n_machines::Int, time_max::Int = 100, speed_max::Int = 10)
    if n_jobs < n_machines
        println("Warning: The generated instance will have m > n, so the slowest (m-n) machines will not be utilized")
    end

    jobs = Jobs(rand(DiscreteUniform(1, time_max), n_jobs))
    machines = Machines(rand(DiscreteUniform(1, speed_max), n_machines))

    return (jobs, machines)
end


function validate_schedule(schedule::Schedule)
    valid = true
    for j in schedule.jobs
        assignments_j = sort(filter(a -> a.J === j, schedule.assignments), by = (a -> a.P.S))

        processing_time_j = sum(map(a -> (a.P.C - a.P.S) * a.P.M.params.s, assignments_j))
        if processing_time_j != j.params.p
            @printf "Schedule is invalid because of job %s:\nTotal processing time should be %.5f, but is %.5f\n" j.name j.params.p processing_time_j
            valid = false
        end

        if length(assignments_j) > 1
            pairs = zip(assignments_j[1:(length(assignments_j)-1)], assignments_j[2:length(assignments_j)])
            has_overlaps = any(p -> p[1].P.C > p[2].P.S, pairs)
            if has_overlaps
                @printf "Schedule is invalid because of job %s:\nProcessing intervals for the job overlap\n" j.name
                valid = false
            end
        end
    end

    w = Algorithms.calculate_w(schedule.jobs, schedule.machines)

    for m in schedule.machines
        assignments_m = sort(filter(a -> a.P.M === m, schedule.assignments), by = (a -> a.P.S))

        max_time_m = maximum(map(a -> a.P.C, assignments_m))
        if max_time_m > w
            @printf "Schedule is invalid because of machine %s:\nMaximum assignment end time of %.5f is higher than w = %.5f\n" m.name max_time_m w
            valid = false
        end

        if length(assignments_m) > 1
            pairs = zip(assignments_m[1:(length(assignments_m)-1)], assignments_m[2:length(assignments_m)])
            has_overlaps = any(p -> p[1].P.C > p[2].P.S, pairs)
            if has_overlaps
                @printf "Schedule is invalid because of machine %s:\nProcessing intervals for the machine overlap\n" m.name
                valid = false
            end
        end

    end

    return valid
end


@testset "Q|prmp|Cmax Gonzales & Sahni" begin
    Random.seed!(1234)

    @test Algorithms.calculate_w(Jobs([1]), Machines([2])) == 1 // 2
    @test Algorithms.calculate_w(Jobs([7, 5, 3]), Machines([2, 1, 2])) == 7 // 2
    @test Algorithms.calculate_w(Jobs([7, 3, 3, 5, 1]), Machines([2, 2, 1])) == 19 // 5

    @test validate_schedule(Algorithms.Q_prmp_Cmax_GS(Jobs([5, 3, 7, 1, 3, 2, 4, 2, 6, 1, 1, 3]), Machines([1 // 4, 2, 1, 1])))
    @test validate_schedule(Algorithms.Q_prmp_Cmax_GS(Jobs([55, 62, 35]), Machines([2, 1, 9, 10])))
    @test validate_schedule(Algorithms.Q_prmp_Cmax_GS(generate_instance(4, 4)...))
    @test validate_schedule(Algorithms.Q_prmp_Cmax_GS(generate_instance(10, 5)...))
    @test validate_schedule(Algorithms.Q_prmp_Cmax_GS(generate_instance(100, 20)...))
    @test validate_schedule(Algorithms.Q_prmp_Cmax_GS(generate_instance(1000, 20)...))
end