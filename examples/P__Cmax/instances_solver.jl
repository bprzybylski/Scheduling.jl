using Scheduling, Scheduling.Algorithms, Scheduling.Objectives

##############
# Parameters #
##############

# Output directory
output_dir = "./instances/"

# Possible prefixes
P = ["UNI", "FNS", "PO3", "BN2"]
# Denominators
D = [1, 2, 2^3, 2^7, 2^23]
# Possible numbers of jobs
N = [10, 50, 100, 500, 1000]
# Possible numbers of machines
M = [5, 10, 25]
# Minimum processing times
A = [1]
# Maximum processing times
B = [100, 1000, 10000]

# Required relation between number of machines and number of jobs
instance_filter(n, m) = (m < n)
# Number of instances for each pair
no_of_instances = 10

#############
# IP Solver #
#############
# Calculate expected number of instances
solved_no_of_instances = 0

for p in P, n in N, m in M, a in A, b in B, d in D
    if instance_filter(n, m)
        # For all the instance indexes
        for i in 1:no_of_instances
            # Generate the file_name
            fname = "$(p)/$(p)-$(n)-$(m)-$(a)-$(b)-$(d)-$(i)"

            # Print information
            global solved_no_of_instances += 1
            println("[$(solved_no_of_instances)] Solving the $(fname) instance")

            if !isfile("$(output_dir)$(fname).jdl")
                println("   File not found")
            else
                # Load the schedule
                S = Scheduling.load("$(output_dir)$(fname).jdl")

                # Solve the instance only if it is not solved yet
                if length(S.assignments) > 0
                    println("    Instance already solved with Cmax = $(Int(cmax(S)))")
                else
                    # Solve and store the schedule
                    S = Algorithms.P__Cmax_IP(S.jobs, S.machines)
                    println("    Solved now with Cmax = $(Int(cmax(S)))")
                    Scheduling.save(S, "$(output_dir)$(fname).jdl")
                end
            end

        end
    end
end
