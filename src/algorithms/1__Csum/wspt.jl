function wspt(J::Array{Job}, M::Vector{Machine})::Schedule 
    
    # compute w_j/p_j
    sorted_jobs = sortslices(J, dims=1, rev=true, lt=(x,y)->isless(x.w/x.p,y.w/y.p))
    A = JobAssignments()

    mytime = 0.0
    for i in 1:n
        last_time = mytime
        mytime += sorted_jobs[i].p
        push!(A, JobAssignment(sorted_jobs[i], M[1], last_time, last_time + sorted_jobs[i].p))
    end

    return Schedule(jobs, M, A)
end
