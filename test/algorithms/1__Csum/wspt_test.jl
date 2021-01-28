
@testset "wspt" begin
    
J = [
    Job("1", ClassicalJobParams(p = 2, w = 1, r = 0, d = Inf, D = Inf)),
    Job("2", ClassicalJobParams(p = 2, w = 2, r = 0, d = Inf, D = Inf)),
    Job("3", ClassicalJobParams(p = 2, w = 3, r = 0, d = Inf, D = Inf)),
    Job("4", ClassicalJobParams(p = 2, w = 2, r = 0, d = Inf, D = Inf))
]

M = Machines(1)

sched = Algorithms.wspt(J, M)

for i=1:length(sched.assignments)
    for j=(i+1):length(sched.assignments)
        if i == j
            continue
        end
        # make sure that if job i is scheduled before job j
        # then w_i/p_i >= w_j/p_j 
        if sched.assignments[i].P.S < sched.assignments[j].P.S
            ratio_i = sched.assignments[i].J.params.w / sched.assignments[i].J.params.p
            ratio_j = sched.assignments[j].J.params.w / sched.assignments[j].J.params.p
            @test ratio_i >= ratio_j
        end
    end
end

end
