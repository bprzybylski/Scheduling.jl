using Scheduling

# Assign new jobs to machines
A = Scheduling.JobAssignments()
push!(A, Scheduling.JobAssignment(Scheduling.Job(name = "J_1", p = 5), 1, 2, 7))
push!(A, Scheduling.JobAssignment(Scheduling.Job(name = "J_2", p = 3), 4, 6, 9))
push!(A, Scheduling.JobAssignment(Scheduling.Job(name = "J_3", p = 2), 1, 10, 12))
push!(A, Scheduling.JobAssignment(Scheduling.Job(name = "J_4", p = 6), 2, 5, 11))

# Create and save a schedule
S = Scheduling.Schedule(Scheduling.Jobs(), A)
Scheduling.save(S, "ScheduleSave.tex", compile = true)
