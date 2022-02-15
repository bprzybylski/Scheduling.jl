using Scheduling

function assign_depth(depth, jobs, available_jobs)
    # Pick a random available job
    available_job_picker = rand(1 : length(available_jobs))
    job_picker = available_jobs[available_job_picker]

    # Set its depth 
    jobs[job_picker] = depth

    #Make it unavailable
    deleteat!(available_jobs, available_job_picker)
end

function assign_jobs_depths(depth, num_of_jobs)
    jobs_depths    = Vector{Int}(undef, num_of_jobs)
    available_jobs = Vector{Int}(undef, num_of_jobs)

    for i in 1:num_of_jobs
        jobs_depths[i] = 0        # Initially all jobs have the minimum depth
        available_jobs[i] = i     # All are available
    end

    # Generate root job
    assign_depth(1, jobs_depths, available_jobs)

    # Construct the tree
    for i in 2:depth
        if length(available_jobs) > 1
            # Decide number of jobs for the layer
            jobs_per_layer = rand(1 : length(available_jobs) / 2)

            # Build the layer
            for j in 1:jobs_per_layer
                assign_depth(i, jobs_depths, available_jobs)
            end
        end
    end

    # If there are still available jobs, we randomly assign them
    while length(available_jobs) > 0
        job_depth = rand(2 : depth)
        assign_depth(job_depth, jobs_depths, available_jobs)
    end

    return jobs_depths
end

function get_possible_succesors(jobs_depths, current_job_depth)
    possible_succesors = Vector{Int}(undef, 0)

    # Look for all jobs' position that may be succesors
    for i in 1:length(jobs_depths)
        if jobs_depths[i] == current_job_depth - 1
            push!(possible_succesors, i)
        end
    end

    return possible_succesors
end

function generate_succesors_list(depth, num_of_jobs, jobs)
    jobs_depths = assign_jobs_depths(depth, num_of_jobs)

    succesors_list = Vector{Tuple{Job, Vector{Job}}}(undef, num_of_jobs)

    for i in 1:depth
        for j in 1:length(jobs)
            # Select the jobs of the current depth
            if jobs_depths[j] == i
                if i == 1
                    succesors_list[j] = (jobs[j], Jobs(0))
                else
                    my_succesor_list::Vector{Job} = []

                    # Randomly select one possible succesor   
                    possible_succesors = get_possible_succesors(jobs_depths, i)
                    
                    if length(possible_succesors) > 0
                        succesor_picker = possible_succesors[rand(1 : length(possible_succesors))]
                        succesor = jobs[succesor_picker]

                        # Each job needs to point towards another job in one layer below
                        push!(my_succesor_list, succesor)
                    end
                    succesors_list[j] = (jobs[j], my_succesor_list)
                end
            end
        end
    end

    return succesors_list
end

function generate_instance(num_of_jobs, num_of_machines, depth)
    machines = Machines(num_of_machines)
    jobs = Jobs(num_of_jobs)
    
    succesors_list = generate_succesors_list(depth, num_of_jobs, jobs)

    return Dict("J" => jobs, "IntreeConstraints" => succesors_list, "M" => machines)
end
