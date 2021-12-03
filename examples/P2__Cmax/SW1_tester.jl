
using Random
using Scheduling, Scheduling.Algorithms, Scheduling.Objectives

Random.seed!(123)

J = Jobs([27, 19, 19, 4, 48, 38, 29, 21, 9, 22, 11, 27, 36, 34, 21, 7, 7, 28])
M = Machines(2)

sched = Algorithms.P2__Cmax_SW1(J, M, eps=1//10)

println("Cmax: $(Float64(cmax(sched)))")

Scheduling.plot(sched)
