using Scheduling

# Create a new schedule
S = Schedule()

# Create a set of machines
push!(S.machines, Machine("M_1"))
push!(S.machines, Machine("M_2"))
push!(S.machines, Machine("M_3"))
push!(S.machines, Machine("M_4"))

# Create a set of jobs
push!(S.jobs, Job("J_1", p = 5))
push!(S.jobs, Job("J_2", p = 3))
push!(S.jobs, Job("J_3", p = 2))
push!(S.jobs, Job("J_4", p = 6))

# Assign jobs to machines
push!(S.assignments, JobAssignment(S.jobs[1], S.machines[1], 2, 7))
push!(S.assignments, JobAssignment(S.jobs[2], S.machines[4], 6, 9))
push!(S.assignments, JobAssignment(S.jobs[3], S.machines[1], 10, 12))
push!(S.assignments, JobAssignment(S.jobs[4], S.machines[2], 5, 11))

# Export the schedule
Scheduling.TeX(S, "ScheduleSave.tex", compile = true)
