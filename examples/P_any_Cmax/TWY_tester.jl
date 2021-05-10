
include("instance_generator.jl")

using Random
using Scheduling, Scheduling.Algorithms, Scheduling.Objectives

Random.seed!(5)

n = 25
#m = 10 
m = 15
jobs = gen_instance_prasanna_musicus(n, m) 
machines = Machines(m)

sched = Algorithms.TWY(jobs, machines)

println("\n-------")
println("m=$(m)")
println("n=$(n)")

mrt_cmax = cmax(sched)

println(sched)
#println("p=$(p)")
println("makespan: $(mrt_cmax)")

Scheduling.plot(sched)
