using Random
using Scheduling, Scheduling.Algorithms, Scheduling.Objectives

Random.seed!(12345)

eps = 1//3

# We will generate 20 instances
for instance_id in 1:20
    println("Instance $(instance_id):")

    # Generate the set of machines
    M = Machines(rand(2:6))
    # Generate the set of 12--20 jobs
    J = Jobs(rand(1:50, rand(12:20)))

    Scheduling.save(Schedule(J,M), "HS_vs_IP/I$(instance_id).jdl")

    # Generate an exact solution
    S1 = Algorithms.P__Cmax_IP(J, M)
    println("   IP:             $(float(cmax(S1)))")

    # Generate an approximation (eps = 1//10)
    S2 = Algorithms.P__Cmax_HS(J, M, eps = eps)
    println("   HS:             $(float(cmax(S2)))")

    approx_ratio = cmax(S2)//cmax(S1)
    println("   Approx. ratio:  $(float(approx_ratio))")
    if approx_ratio < 1 || approx_ratio > 1 + eps
        println("   Are we happy?:  NO")
        println(S2)
    else
        println("   Are we happy?:  YES")
    end
end
