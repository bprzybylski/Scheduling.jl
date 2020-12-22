# 
# par task model by Prasanna and Musicus, p(i) = p(1) / i^alpha
#
# Prasanna, G. N. S., & Musicus, B. R. (1996). 
# Generalized Multiprocessor Scheduling and Applications to Matrix Computations. 
# IEEE Trans. Parallel Distrib. Syst., 7(6), 650–664. http://doi.org/10.1109/71.506703
#

function gen_instance_prasanna_musicus(n, m) 
    #p = Array{Float64}(undef, n, m)
    jobs = Array{Job}(undef, n)
    
    # split into big and small tasks
    #n_large = Int64(ceil(n * 1/2))
    n_large = Int64(ceil(n * 2/3))
    #n_large = n
    n_small = n - n_large

    for i in 1:n_large
        p = Array{Float64}(undef, m)
        alpha = 0.8 + (0.2)rand()
        p[1] = rand(100:120)
        for j in 2:m
            p[j] = p[1] / (j^alpha)
        end
        jobs[i] = Job(string(i), ParallelJobParams(p))
    end
    
    for i in (n_large+1):n
        p = Array{Float64}(undef, m)
        alpha = rand()
        p[1] = rand(2:6)
        for j in 2:m
            p[j] = p[1] / (j^alpha)
        end
        jobs[i] = Job(string(i), ParallelJobParams(p))
    end
    jobs
end
