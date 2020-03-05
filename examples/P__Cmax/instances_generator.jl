using Random, Distributions
using Scheduling

##############
# Parameters #
##############

# Output directory
output_dir = "./instances/"

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
instance_filter(n, m) = (2*m <= n)
# Number of instances for each pair
no_of_instances = 10

########################
# Uniform distribution #
########################
for n in N, m in M, a in A, b in B, d in D
    if instance_filter(n, m)
        # Setting a random seed for each (n, m, a, b, d) tuple guarantees that
        # generated instances with the same names will be identical
        Random.seed!(3*n - 5*m + 7*b - 2*a + 11*d)

        # Generate the set of machines
        machines = Machines(m)

        # For all the instance indexes
        for i in 1:no_of_instances
            # Generate the file_name
            fname = "UNI/UNI-$(n)-$(m)-$(a)-$(b)-$(d)-$(i)"

            # Print information
            println("Generating the $(fname) instance")

            # Save the schedule
            Scheduling.save(Schedule(
                                Jobs(map(X -> X//d, rand(a*d:b*d, n))),
                                machines),
                            "$(output_dir)$(fname).jdl")
        end
    end
end

#########################################################
# Non-uniform distribution inspired by Frangioni et al. #
#########################################################
for n in N, m in M, a in A, b in B, d in D
    if instance_filter(n, m)
        # Setting a random seed for each (n, m, a, b, d) tuple guarantees that
        # generated instances with the same names will be identical
        Random.seed!(3*n - 5*m + 7*b - 2*a + 11*d)

        # Generate the set of machines
        machines = Machines(m)

        # For all the instance indexes
        for i in 1:no_of_instances
            # Generate the file_name
            fname = "FNS/FNS-$(n)-$(m)-$(a)-$(b)-$(d)-$(i)"

            # Print information
            println("Generating the $(fname) instance")

            jpt = Vector{Rational{Int}}()

            # 98% of jobs should be in the [0.9(b−a), b] interval
            # 2% of jobs should be in the [a, 0.2(b-a)] interval
            for j in 1:n
                if rand() >= 0.98
                    push!(jpt, rand(Int(ceil(9//10 * (b-a)))*d:b*d)//d)
                else
                    push!(jpt, rand(a*d:Int(ceil(2//10 * (b-a)))*d)//d)
                end
            end

            # Save the schedule
            Scheduling.save(Schedule(Jobs(jpt), machines), "$(output_dir)$(fname).jdl")
        end
    end
end

###################################
# Poisson distribution (λ = 1//3) #
###################################
for n in N, m in M, a in A, b in B, d in D
    if instance_filter(n, m)
        # Setting a random seed for each (n, m, a, b, d) tuple guarantees that
        # generated instances with the same names will be identical
        Random.seed!(3*n - 5*m + 7*b - 2*a + 11*d)

        # Generate the set of machines
        machines = Machines(m)

        # For all the instance indexes
        for i in 1:no_of_instances
            # Generate the file_name
            fname = "PO3/PO3-$(n)-$(m)-$(a)-$(b)-$(d)-$(i)"

            # Print information
            println("Generating the $(fname) instance")

            jpt = Vector{Rational{Int}}()
            for j in 1:n
                p = a*d + rand(Poisson(Int(ceil(1//3 * (b-a) * d))))
                if p > b*d
                    p = b*d
                end
                push!(jpt, p//d)
            end

            # Save the schedule
            Scheduling.save(Schedule(Jobs(jpt), machines), "$(output_dir)$(fname).jdl")
        end
    end
end

####################################
# Binomial distribution (p = 1//2) #
####################################
for n in N, m in M, a in A, b in B, d in D
    if instance_filter(n, m)
        # Setting a random seed for each (n, m, a, b, d) tuple guarantees that
        # generated instances with the same names will be identical
        Random.seed!(3*n - 5*m + 7*b - 2*a + 11*d)

        # Generate the set of machines
        machines = Machines(m)

        # For all the instance indexes
        for i in 1:no_of_instances
            # Generate the file_name
            fname = "BN2/BN2-$(n)-$(m)-$(a)-$(b)-$(d)-$(i)"

            # Print information
            println("Generating the $(fname) instance")

            jpt = Vector{Rational{Int}}()
            for j in 1:n
                p = a*d + rand(Binomial((b-a) * d))
                if p > b*d
                    p = b*d
                end
                push!(jpt, p//d)
            end

            # Save the schedule
            Scheduling.save(Schedule(Jobs(jpt), machines), "$(output_dir)$(fname).jdl")
        end
    end
end
