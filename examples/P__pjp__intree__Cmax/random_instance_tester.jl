using Scheduling, Scheduling.Algorithms
using Random

include("instance_generator.jl")

Random.seed!(123)

num_jobs = 40
num_machines = 5
depth = 5 # max-depth of the constraint intree

instance = generate_instance(num_jobs, num_machines, depth)

schedule = Algorithms.P__pⱼp__intree__Cmax(instance["J"], instance["M"], instance["IntreeConstraints"])

# to plot constraint graph (using Gplot) uncomment next lines 
# g, t = jobs_and_intree_to_graph(hus_instance["J"], hus_instance["IntreeConstraints"])
# gplot(g, nodelabel=(1:nv(g)))  

Scheduling.plot(schedule)


