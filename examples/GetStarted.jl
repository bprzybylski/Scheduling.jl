using Scheduling, Scheduling.Algorithms, Scheduling.Objectives

# Generate a set of jobs with processing times from an array
J = Jobs([27, 19, 19, 4, 48, 38, 29, 21, 9, 22, 11, 27, 36, 34, 21, 7, 7, 28])
# Generate a set of 4 identical machines
M = Machines(4)

# Generate an optimal schedule using IP
OPT = Algorithms.P__Cmax_IP(J, M)
println("Optimal schedule:     Cmax = $(Int(cmax(OPT)))")

# Generate a schedule using LPT list rule
LPT = Algorithms.lpt(J, M)
println("LPT schedule:         Cmax = $(Int(cmax(LPT)))")

# Generate a schedule using SPT list rule
SPT = Algorithms.spt(J, M)
println("SPT schedule:         Cmax = $(Int(cmax(SPT)))")

# Generate a schedule using the Hochbaum-Shmoys algorithm
HS = Algorithms.P__Cmax_HS(J, M, eps = 1//3)
println("HS schedule:          Cmax = $(Int(cmax(HS)))")

# Plot the optimal schedule
Scheduling.plot(OPT)
