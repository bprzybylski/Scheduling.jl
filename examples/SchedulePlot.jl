using Scheduling

# Create a new schedule
S = Scheduling.Schedule(Jobs([5, 3, 2, 6]), Machines(4))

# Assign jobs to machines
push!(S.assignments, JobAssignment(S.jobs[1], S.machines[1], 2, 7))
push!(S.assignments, JobAssignment(S.jobs[2], S.machines[4], 6, 9))
push!(S.assignments, JobAssignment(S.jobs[3], S.machines[1], 10, 12))
push!(S.assignments, JobAssignment(S.jobs[4], S.machines[2], 5, 11))

# Plot the schedule
Scheduling.plot(S)
