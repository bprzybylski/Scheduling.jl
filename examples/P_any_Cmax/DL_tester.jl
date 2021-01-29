include("instance_generator.jl")

using Random
using Scheduling, Scheduling.Algorithms, Scheduling.Objectives

Random.seed!(5)

#n = 10
n = 7
# DL works only for m=2
m = 2
jobs = gen_instance_prasanna_musicus(n, m)

# we convert running time to ints, as DL works for ints only
jobs_int = Array{Job}(undef, n)
for i=1:n

    pfloat = jobs[i].params.p
    pint   = Array{Int64}(undef, m)
    map(x -> pint[x] = Int64(floor(pfloat[x])), 1:m)

    jobs_int[i] = Job(jobs[i].name, ParallelJobParams(pint))
end

println(jobs_int)

machines = Machines(m)

sched = Algorithms.DL(jobs_int, machines)

println("\n-------")
println("m=$(m)")
println("n=$(n)")

mrt_cmax = cmax(sched)

#println(sched)
println("makespan: $(Int(mrt_cmax))")

Scheduling.plot(sched)