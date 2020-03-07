using Random
using Scheduling, Scheduling.Algorithms, Scheduling.Objectives

Random.seed!(12345)

eps = 1//2

# We will generate 20 instances
for instance_id in 1:20
    # Generate the set of machines
    M = Machines(rand(2:6))
    # Generate the set of 12--20 jobs
    J = Jobs(rand(1:50, rand(12:20)))

    # Generate an exact solution
    S1 = Algorithms.P__Cmax_IP(J, M)
    # Generate an approximation
    S2 = Algorithms.P__Cmax_HS(J, M, eps = eps)

    # Calculate the approximation ratio
    approx_ratio = cmax(S2)//cmax(S1)

    # Print the summary
    println("Instance $(instance_id):")
    println("   IP:             $(float(cmax(S1)))")
    println("   HS:             $(float(cmax(S2)))")
    println("   Approx. ratio:  $(float(approx_ratio))")
end