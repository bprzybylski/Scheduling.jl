import Base.@kwdef

"""
Q_prmp_Cmax_GS(J::Vector{Job}, M::Vector{Machine})

Solves the Q|prmp|Cmax by applying the algorithm of Gonzales and Sahni. Their algorithm is divided into a general body, 
and four separate rules (R1 - R4). It maintains, among other things, two important structures: the set \$I\$, which contains 
at any point the processors that are in use by the algorithm, and a DPS. A DPS (disjoint processor system) is a set 
of processors \$P_{i_1}, P_{i_2}, ..., P_{i_r}\$ with increasing indices (i.e. \$i_1 \\le i_2 \\le ... \\le i_r\$) whose 
free intervals are non-overlapping, span the entire interval \$[0,w]\$, and are ordered in a "reverse waterfall" manner 
(for a more stringent definition, please refer to the paper itself). Also of note is that the algorithm expects jobs and 
machines to be provided in descending order (by processing time and speed, respectively), a restriction that we lift in our 
implementation by doing the sorting as a first step (this does of course increase the running time above \$O(n)\$). 

The general algorithm body repeatedly calls one of the rules R1 - R3 until a condition is no longer met, after which it proceeds 
to a single call of rule R4. Rules R1 - R3 each add one processor to the set \$I\$ and schedule one job on the processors in \$I\$. 
They therefore ensure that, when the next job \$k+1\$ is scheduled, \$|I| = k + 1\$. Furthermore, they maintain the invariant that 
the free time-slots on the processors in \$I\$ form a DPS. Rule R4 is run once, at the very latest when \$|I| = m\$ (i.e. when all 
processors have been included into \$I\$), and schedules the remaining jobs on the remaining empty processors, and then on the 
free slots in the DPS.

# References
* Teofilo F. Gonzalez and Sartaj Sahni, Preemptive scheduling of uniform processor systems, Journal of the ACM, 25(1):92–101, 1978
"""
function Q_prmp_Cmax_GS(J::Vector{Job}, M::Vector{Machine})
    jobs = sort(J, by = (j -> j.params.p), rev = true)
    machines = sort(M, by = (m -> m.params.s), rev = true)
    
    if length(jobs) < length(machines)
        machines = machines[1:length(jobs)]
    end

    schedule = Schedule(jobs, machines)
    c = Context(jobs, machines)

    while c.k < c.m && (c.t_I // c.s_I >= c.w || c.times[c.k] > c.w * c.speeds[c.s])
        # println("Schedule for task ", c.k)
        if c.t_I // c.s_I == c.w
            rule_r1(c, schedule)
        elseif c.t_I // c.s_I > c.w
            rule_r2(c, schedule)
        else # c.t_I // c.s_I < c.w
            rule_r3(c, schedule)
        end

        c.k = c.k + 1
        c.t_I = c.t_I + c.times[c.k]
    end

    rule_r4(c, schedule)

    return schedule
end

@kwdef mutable struct Context
    n::Int # number of jobs
    m::Int # number of Machines

    w::Rational{Int} # minimum makespan
    times::Vector{Rational{Int}} # processing times of the jobs
    speeds::Vector{Rational{Int}} # speeds of the machines
    s::Int # index of the slowest processor not in I

    j::Int # highest index of a processor in I
    f::Int # index of the first machine in I2
    e::Int # index of the last machine in I2
    link::Vector{Int} # entries are the indices of the next node in I2

    D::Vector{Int} # entries are the indices of the processors in the DPS
    F::Vector{Rational{Int}} # entries are the time boundaries between processors in the DPS
    p::Int # first index of the DPS, i.e. D[p] contains the index of the first machine in the DPS
    q::Int # last index of the DPS

    t_I::Rational{Int} # sum of processing time of currenty scheduled jobs
    s_I::Rational{Int} # sum of processing speed of currently used machines
    k::Int # current iteration
end

# constructor that initializes a context from the provided jobs and machines
# this could maybe be made more beautiful using struct default values
function Context(jobs::Vector{Job}, machines::Vector{Machine})
    n = length(jobs)
    m = length(machines)

    w = calculate_w(jobs, machines)
    times = map(j -> j.params.p, jobs)
    speeds = [map(m -> m.params.s, machines)..., times[1] // w + 1]

    c = Context(n = n,
        m = m,
        w = w,
        times = times,
        speeds = speeds,
        s = m,
        j = 1,
        f = 0,
        e = 0,
        link = Vector{Int}(undef, m),
        D = Vector{Int}(undef, m),
        F = Vector{Rational{Int}}(undef, m),
        p = 1,
        q = 1,
        t_I = times[1],
        s_I = speeds[1],
        k = 1
    )
    c.D[1] = 1
    c.F[1] = w

    return c
end

function calculate_w(jobs::Vector{Job}, machines::Vector{Machine})
    jobs = sort(jobs, by = (j -> j.params.p), rev = true)
    machines = sort(machines, by = (m -> m.params.s), rev = true)
    if length(jobs) < length(machines)
        machines = machines[1:length(jobs)]
    end

    task_sum = j -> sum(t -> t.params.p, jobs[1:j])
    speed_sum = j -> sum(m -> m.params.s, machines[1:j])

    m = length(machines)
    n = length(jobs)

    ratios = map(j -> task_sum(j) // speed_sum(j), 1:(m-1))

    return max(task_sum(n) // speed_sum(m), ratios...)
end

function rule_r1(c::Context, schedule::Schedule)
    # println("Applying rule R1")

    t1 = 0 // 1
    for i = c.q:-1:c.p
        add_assignment(schedule, c.k, c.D[i], t1, c.F[i])
        t1 = c.F[i]
    end

    # add P_{j+1} to I
    c.j = c.j + 1
    c.s_I = c.s_I + c.speeds[c.j]

    # update DPS
    c.p = 1
    c.q = 1
    c.D[c.p] = c.j
    c.F[c.p] = c.w

    # update I1 and I2 
    while c.j + 1 == c.f # if the first element in I_2 is now actually next to the last element in I_1
        c.j = c.j + 1 # "add" that element to I_1 by setting j to its index
        c.f = c.link[c.f] # set f to the index of the next element in I_2
    end
end

function rule_r2(c::Context, schedule::Schedule)
    # println("Applying rule R2")

    t1 = 0 // 1

    schedule_next = () -> begin
        # schedule job k on the free interval of processor D[p]
        add_assignment(schedule, c.k, c.D[c.p], c.F[c.p+1], c.F[c.p])

        # add this to the total time that job k has been processed already
        t1 = t1 + (c.F[c.p] - c.F[c.p+1]) * c.speeds[c.D[c.p]]

        # processor D[p] now no longer has a free interval, so the DPS starts at the next processor in D
        c.p = c.p + 1
    end

    # schedule job k on all the free intervals in I1 (i.e. all the processors in D that have an index <= j)
    while c.D[c.p] <= c.j
        schedule_next()
    end

    # set F(q+1) from a potentially random previous value to 0 to ensure that in the next code segment,
    # (F(p) - F(p+1)) has the correct value if the iteration where p=q is reached
    c.F[c.q+1] = 0

    # T(k) - T1 - (F(p) - F(p+1)) * S(D(p)): processing time remaining for job k after the free interval of D(p) is used
    # S(j+1) * F(p+1): maximal processing time that can be scheduled on machine j+1 in the interval between 0 and F(p+1)
    # => schedule job k on machines in I2 until the remaining processing time can be scheduled on machine j+1 without overlap (a violation of the DPS criterion)
    # note: the condition p != q was added by us, since in the case that the check is performed for p = q, S(j+1) * F(p+1) = 0 
    # since F(p+1) = F(q+1) = 0 due to the statement above. Therefore the condition will hold, job k will be scheduled on the last 
    # entry of the DPS, and during the next check of the while condition, an error will be thrown, since now we are calculating with 
    # entries of the DPS that do not exist (p is now greater than q)
    while c.p != c.q && c.times[c.k] - t1 - (c.F[c.p] - c.F[c.p+1]) * c.speeds[c.D[c.p]] > c.speeds[c.j+1] * c.F[c.p+1]
        schedule_next()
    end

    # calculate the exact cutover point T2 where the remaining processing time of job k is split 
    # between machine j+1 (from 0 to T2) and machine D(p) (from T2 to F(p))
    # see the bottom p99 of the paper to understand how the formula for T2 comes to be
    # machine j+1 is then free from T2 to w, the remaining machines in J are free from 0 to T2 
    # since the remaining machines in J must be of I2 (we used up all the free intervals in I1), 
    # their indices must be higher than j+1, so we have a DPS again
    t2 = (c.times[c.k] - t1 - c.F[c.p] * c.speeds[c.D[c.p]]) // (c.speeds[c.j+1] - c.speeds[c.D[c.p]])
    add_assignment(schedule, c.k, c.j + 1, 0//1, t2)
    add_assignment(schedule, c.k, c.D[c.p], t2, c.F[c.p])

    # if T2 is not F(p+1), i.e. job k is not scheduled on the entire free interval of machine D(p),
    # then we can't overwrite its position in D and F with the info for machine j+1, since it still is part of the DPS
    # thus, we set its new F(p) value to T2 (so that the free interval of machine D(p) now runs from F(p+1) to T2)
    # and decrease p by 1, to get the slot in which we will write the DPS info for machine j+1, which is now the 
    # first machine in the DPS
    if t2 != c.F[c.p+1]
        c.F[c.p] = t2
        c.p = c.p - 1
    end

    c.j = c.j + 1 # we added machine j+1 to I1, so update the index accordingly
    c.D[c.p] = c.j # the first machine in D is now machine j (the machine we just added), since it is free from T2 to w
    c.F[c.p] = c.w # the machine we just added is free from T2 (F(p+1) since we just updated it in the if-clause above) to w
    c.s_I = c.s_I + c.speeds[c.j]

    # update I1 and I2 
    while c.j + 1 == c.f # if the first element in I_2 is now actually next to the last element in I_1
        c.j = c.j + 1 # "add" that element to I_1 by setting j to its index
        c.f = c.link[c.f] # set f to the index of the next element in I_2
    end
end

function rule_r3(c::Context, schedule::Schedule)
    # println("Applying rule R3")
    # starting from j+1 (the first processor that is not in I),
    # find the first processor that is too slow to process job k
    # in time w
    is_in_I2 = x -> begin
        if c.f == 0
            return false
        else
            next_I2 = c.f
            while next_I2 != 0
                if next_I2 == x
                    return true
                else
                    next_I2 = c.link[next_I2]
                end
            end

            return false
        end
    end

    v = c.j + 1
    while c.times[c.k] <= c.speeds[v] * c.w || is_in_I2(v)
        v = v + 1
    end


    if v == c.j + 1
        # if that processor is j+1, simply extend I1
        c.j = v
    else
        # if not, put processor v into I2
        c.link[v] = 0

        if c.f == 0
            # if I2 is empty, initialize I2 to contain only 
            # processor v (i.e. it's the first and last processor in I2)
            c.f = v
            c.e = v
        else
            # if I2 is not empty, make processor v the last processor in 
            # I2 and update LINK to make the previous last point to v
            # (processor v is guaranteed to have a higher index than any 
            # processor currently in I, according to the paper)
            c.link[c.e] = v
            c.e = v
        end
    end

    # if the chosen processor is processor m, increase s 
    # (the index of the slowest processor not in I) accordingly
    # which will invalidate the condition T(k) > w * S(s) in 
    # the outer while loop of the algorithm, since S(m+1) was 
    # initialized to T(1)/w and T(j) <= T(1) for j > 1
    if v == c.m
        c.s = c.m + 1
    end

    c.s_I = c.s_I + c.speeds[v]

    # real time (i.e. number between 0 and w) up to which 
    # the schedule for job k has been built
    t1 = 0 // 1

    # processing time (i.e. number between 0 and T(k)) that is 
    # already scheduled for job k in the interval from 0 to T1
    t2 = 0 // 1

    while true
        # the amount of processing time that job k can be scheduled for on the
        # next processor (going backwards from the last one, D(q)) in the DPS
        t3 = (c.F[c.q] - t1) * c.speeds[c.D[c.q]]

        # if we were to fully use up the free slot of the current processor in the 
        # DPS (i.e. from T1 to F(q)) (which provides an amount of processing time T3), 
        # how much processing time still needs to be scheduled (i.e. T(k) - T2 - T3),
        # and where would an interval going up to w have to start for it to contain this 
        # remaining processing time at the speed of processor v? -> that start time is T4
        t4 = c.w - (c.times[c.k] - t2 - t3) // c.speeds[v]


        if t4 < c.F[c.q]
            # if T4 is before F(q), then that means that processor v is too slow to 
            # perform the remaining processing time after the free slot of processor D(q)
            # without producing an overlap, so we still need to involve faster processors 
            # in the DPS -> schedule D(q) on the interval T1 to F(q) and decrease q to 
            # move to the next processor in the DPS
            add_assignment(schedule, c.k, c.D[c.q], t1, c.F[c.q])
            t2 = t2 + t3
            t1 = c.F[c.q]
            c.q = c.q - 1 
        elseif t4 == c.F[c.q]
            # if T4 is exactly F(q), then scheduling processor D(q) from T1 to F(q) and 
            # processor v from F(q) to w provides exactly the remaining processing time 
            # required by job k
            # since processor k is now free from 0 to F(q), and the other processors in the DPS 
            # are free from F(q) to w, the new schedule still observes the DPS variant, with processor v
            # as the last DPS entry
            add_assignment(schedule, c.k, c.D[c.q], t1, c.F[c.q])
            add_assignment(schedule, c.k, v, c.F[c.q], w)
            c.D[c.q] = v
            break
        else
            # if T4 is after F(q), then processor v could perform the remaining work in a shorter time interval 
            # than F(q) to w, which would introduce an overlap in the DPS (since processor v would then be 
            # free from 0 to T4, and the next processor in the DPS would be free from F(q) onwards) which 
            # would violate the DPS' invariants. We therefore have schedule job k on less than the full free 
            # interval of processor D(q) (which is faster than processor v), thus increasing the remaining processing 
            # time to be scheduled on processor v, in a way that the two processors are fully occupied by job k 
            # in the interval from T1 to w. T5 is exaclty that split point, which thus has to fulfill the equation
            # (T5 - T1) * S(D(q)) + (w - T5) * S(v) = T(k) - T2.
            # We then update the DPS to increase its length by 1 (since the free slot of the current D(q) hasn't been 
            # fully used up) and set processor v as the new last node in the DPS.
            t5 = (c.times[c.k] - t2 + t1 * c.speeds[c.D[c.q]] - c.w * c.speeds[v]) // (c.speeds[c.D[c.q]] - c.speeds[v])
            add_assignment(schedule, c.k, c.D[c.q], t1, t5)
            add_assignment(schedule, c.k, v, t5, c.w)
            c.q = c.q + 1
            c.D[c.q] = v
            c.F[c.q] = t5
            break
        end
    end
end

function add_assignment(schedule::Schedule, job::Int, machine::Int, from::Rational{Int}, to::Rational{Int})
    # println("Assigning Job $(schedule.jobs[job].name) to $(schedule.machines[machine]) from $(from) to $(to)")

    push!(schedule.assignments,
        JobAssignment(schedule.jobs[job], schedule.machines[machine], from, to))
end

function rule_r4(c::Context, schedule::Schedule)
    # println("Applying rule R4")
    if c.k != c.m
        pr = get_processors_not_in_I(c)
        
        # let i be the smallest index that satisfies this condition
        possible_indices = [filter(x -> sum(c.times[c.k:x]) >= c.w * sum(c.speeds[pr]), c.k:c.n)...]
        if length(possible_indices) == 0 # if there is no such i, let i = n
            i = c.n
        else # take the smallest index
            i = minimum(possible_indices)
        end
        
        schedule_on_pr = () -> begin
            # schedule the jobs k to i on the processors P_{r1} to P_{rl}
            # this needs to be done for case i) and ii) of rule R4 in the paper
            # in case ii), it might happen that i is not fully scheduled after the loop exits
            # (i.e. that rem_processing_time_k > 0)
            rem_processing_time_k = c.times[c.k]
            j = 1
            interval_end_j = c.w
            while c.k <= i && j <= length(pr)
                processing_time_j = c.speeds[pr[j]] * interval_end_j

                if processing_time_j >= rem_processing_time_k
                    cutoff = interval_end_j - rem_processing_time_k // c.speeds[pr[j]]
                    add_assignment(schedule, c.k, pr[j], cutoff, interval_end_j)
                    interval_end_j = cutoff
                    c.k = c.k + 1
                    if c.k <= c.n
                        rem_processing_time_k = c.times[c.k]
                    end
                else
                    add_assignment(schedule, c.k, pr[j], 0 // 1, interval_end_j)
                    j = j + 1
                    interval_end_j = c.w
                    rem_processing_time_k = rem_processing_time_k - processing_time_j
                end
            end

            return rem_processing_time_k
        end



        if sum(c.times[c.k:i]) <= c.w * sum(c.speeds[pr])
            # this covers case i) of rule R4
            # println("case i: scheduling on pr, then the rest on the DPS")
            schedule_on_pr()
            if i != c.n
                # this covers the sub-case for case i) or rule R4 when there are still jobs
                # left after i (i != n), which will then be scheduled onto the DPS   
                schedule_remaining_on_dps(c, schedule)
            end
        else
            # this covers the case ii) of rule R4, where a part of job i and the remaining 
            # jobs are scheduled onto the DPS
            # println("case ii: scheduling on pr with remaining fraction of job i, then the rest on the DPS")
            rem_processing_time_k = schedule_on_pr()
            schedule_remaining_on_dps(c, schedule, rem_processing_time_k)
        end
    else
        # this covers case iii) of rule R4, where the remaining jobs can simply be scheduled on the DPS
        # println("case iii: scheduling the remaining jobs on the DPS")
        schedule_remaining_on_dps(c, schedule)
    end
end

function get_processors_not_in_I(c::Context)
    processors_in_I = collect(1:c.j)

    if c.f != 0
        x = c.f
        push!(processors_in_I, x)
        while x != c.e
            x = c.link[x]
            push!(processors_in_I, x)
        end
    end

    return filter(i -> !(i in processors_in_I), 1:c.m)
end

function schedule_remaining_on_dps(c::Context, schedule::Schedule, rem_processing_time_k = nothing)
    rem_processing_time_k = rem_processing_time_k === nothing ? c.times[c.k] : rem_processing_time_k

    while c.k <= c.n
        processing_time_p = (c.F[c.p] - (c.p != c.q ? c.F[c.p+1] : 0 // 1)) * c.speeds[c.D[c.p]]

        if processing_time_p >= rem_processing_time_k
            cutoff = c.F[c.p] - rem_processing_time_k // c.speeds[c.D[c.p]]
            add_assignment(schedule, c.k, c.D[c.p], cutoff, c.F[c.p])
            c.F[c.p] = cutoff
            c.k = c.k + 1
            if c.k <= c.n
                rem_processing_time_k = c.times[c.k]
            end
        else
            add_assignment(schedule, c.k, c.D[c.p], c.F[c.p+1], c.F[c.p])
            c.p = c.p + 1
            rem_processing_time_k = rem_processing_time_k - processing_time_p
        end
    end
end

