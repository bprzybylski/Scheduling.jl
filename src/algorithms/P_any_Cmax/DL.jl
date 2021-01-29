
# Du, J., & Leung, J. (1989). 
# Complexity of scheduling parallel task systems. 
# SIAM Journal on Discrete Mathematics, 2(4), 473–487. 
# http://doi.org/10.1137/0402042

# Copright (c) 2021, sahu 

mutable struct DL_cell
    val::Real
    # for each job, we store whether it is seq (0) or par (1)
    job_config::Tuple{Int64,Int8}
end


function DL(J::Array{Job}, M::Vector{Machine})::Schedule

    n = length(J)
    m = length(M)

    if m != 2
        return nothing
    end

    # sum up seq running times (upper bound)
    T = Int64(sum(x -> J[x].params.p[1], 1:n))

    F = Array{DL_cell}(undef, n + 1, T + 1, T + 1)

    F[1,1,1] = DL_cell(0, (-1,0))

    # cmax will not be larger then T
    INFTY = 2*T

    for x1 = 0:T
        for x2 = 0:T        
            if 0 < x1 + x2 && x1 + x2 <= T
                F[1,1 + x1,1 + x2] = DL_cell(INFTY, (-1,0))
            end
        end
    end

    F[1,1,1].val = 0


    for j = 2:n + 1
        for x1 = 0:T
            for x2 = 0:T
                if x1 + x2 <= T
                     # print("j=$(j) x1=$(x1) x2=$(x2)\n")
                    val1 = F[j - 1, 1 + x1, 1 + x2].val + J[j - 1].params.p[2]

                    val2 = INFTY
                    if x1 - J[j - 1].params.p[1] >= 0
                        val2 = F[j - 1, 1 + x1 - J[j - 1].params.p[1], 1 + x2].val
                    end

                    val3 = INFTY
                    if x2 - J[j - 1].params.p[1] >= 0
                        val3 = F[j - 1, 1 + x1, 1 + x2 - J[j - 1].params.p[1]].val
                    end

                     # print("$(val1) $(val2) $(val3)\n")
                    val   = min(val1, val2, val3)
                    jstate = argmin([ val1, val2, val3 ])

                    F[j,1 + x1,1 + x2] = DL_cell(val, (j-1, jstate))
                end
            end
        end
    end


    # minx1,x2{F(n,x1,x2)+max{x1,x2}}

    cmax = INFTY
    best_indices = [1,1,1]
    for x1 = 0:T
        for x2 = 0:T
            if x1 + x2 <= T
                oldcmax = cmax
                cmax = min(cmax, F[n + 1,x1 + 1,x2 + 1].val + max(x1, x2))
                if oldcmax > cmax
                    best_indices = [n+1, x1+1, x2+1]
                end
            end
        end
    end

    # now that we have built up the table
    # we need to extract the schedule backwards

    # start with the table cell that contains the optimal solution
    Flast = F[best_indices[1], best_indices[2], best_indices[3]]
    # println("task:", Flast.job_config[1], " conf:", Flast.job_config[2]) 

    # we collect all jobs in different bins 
    # for building the schedule later (in canonical form, see paper)
    par_jobs = Tuple{Int64,Int8}[]
    m1_jobs  = Tuple{Int64,Int8}[]
    m2_jobs  = Tuple{Int64,Int8}[]


    curx = best_indices[2]
    cury = best_indices[3]
    for curn = n:-1:1

        if Flast.job_config[2] == 1
            push!(par_jobs, Flast.job_config)     
            # was mapped to two procs
            Flast = F[curn, curx, cury]       
        elseif Flast.job_config[2] == 2
            push!(m1_jobs, Flast.job_config)
            # was mapped to proc 1
            curx -= J[curn].params.p[1] 
            Flast = F[curn, curx, cury]
        elseif Flast.job_config[2] == 3
            push!(m2_jobs, Flast.job_config)
            # was mapped to proc 2
            cury -= J[curn].params.p[1] 
            Flast = F[curn, curx, cury]
        end
        #println("task:", Flast.job_config[1], " conf:", Flast.job_config[2]) 
    end    

    #println(par_jobs)
    #println(m1_jobs)
    #println(m2_jobs)

    # now we can build the schedule
    # start with p=2 jobs, then schedule the single-machine jobs
    m1_time = 0
    m2_time = 0

    jobass = JobAssignment[]
    for i=1:length(par_jobs)

        stime = m1_time
        etime = stime + J[ par_jobs[i][1] ].params.p[2]  # add the time on two machines
        ja = JobAssignment( 
            J[ par_jobs[i][1] ],
            M,
            stime,
            etime
        )
        push!(jobass, ja)

        m1_time = etime
        m2_time = etime
    end

    for i=1:length(m1_jobs)

        stime = m1_time
        etime = stime + J[ m1_jobs[i][1] ].params.p[1]  # add the time on one machine
        ja = JobAssignment( 
            J[ m1_jobs[i][1] ],
            M[1],
            stime,
            etime
        )
        push!(jobass, ja)

        m1_time = etime
    end    

    for i=1:length(m2_jobs)

        stime = m2_time
        etime = stime + J[ m2_jobs[i][1] ].params.p[1]  # add the time on one machine
        ja = JobAssignment( 
            J[ m2_jobs[i][1] ],
            M[2],
            stime,
            etime
        )
        push!(jobass, ja)

        m2_time = etime
    end    

    Schedule(J, M, jobass)

end
