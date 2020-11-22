
include("instance_generator.jl")

using Random
using Scheduling, Scheduling.Algorithms, Scheduling.Objectives

Random.seed!(5)

n = 25
m = 10 
p = gen_instance_prasanna_musicus(n, m) 

makespan, sched = Algorithms.MRT(n, m, p)

println("\n-------")
println("m=$(m)")
println("n=$(n)")
#println("p=$(p)")
println("makespan: $(makespan)")
