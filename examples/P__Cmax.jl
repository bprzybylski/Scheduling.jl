using Random
using Scheduling, Scheduling.Algorithms

Random.seed!(12345)

S = Algorithms.P__Cmax_IP(Jobs(rand(1:100, rand(1:20))), Machines(rand(2:5)))

# Plot the schedule
Scheduling.plot(S)
