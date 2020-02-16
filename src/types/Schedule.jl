mutable struct Schedule
    jobs::Jobs
    assignments::JobAssignments
    function Schedule(jobs = Jobs(), assignments = JobAssignments())
        return new(jobs, assignments)
    end
end

