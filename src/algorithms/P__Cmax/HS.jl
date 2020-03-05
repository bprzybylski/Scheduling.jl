mutable struct P__Cmax_HS_BinConfig
    load::Rational{Int}
    assignments::Array{Int}
end

function P__Cmax_HS_BINS(n::Int,
                         no_of_pieces::Array{Int},
                         sizes_of_pieces::Array{Rational{Int}},
                         Q::Array{Array{Int},},
                         bins::Array{Int,}, selected_bin_configs::Array{Array{Array{Int,1},1},})

    if length(no_of_pieces) == 0
        ret_no_of_bins = 0
    elseif bins[(no_of_pieces .+ 1)...] > 0
        ret_no_of_bins = bins[(no_of_pieces .+ 1)...]
        if selected_bin_configs[(no_of_pieces .+ 1)...] == [[]]
            selected_bin_configs[(no_of_pieces .+ 1)...] = [copy(no_of_pieces)]
        end
    else
        ret_no_of_bins = 0

        cur_min = typemax(Int)
        best_q = nothing

        # Find the best value in Q
        for q in Q
            cp_no_of_pieces = copy(no_of_pieces)
            cp_no_of_pieces -= q
            if minimum(cp_no_of_pieces) >= 0
                no_of_bins = P__Cmax_HS_BINS(n, cp_no_of_pieces, sizes_of_pieces, Q, bins, selected_bin_configs)
                if no_of_bins < cur_min
                    cur_min = no_of_bins
                    best_q = copy(q)
                end
            end
        end

        bins[(no_of_pieces .+ 1)...] = 1 + cur_min

        # Find the solution for the best q
        cp_no_of_pieces = copy(no_of_pieces)
        cp_no_of_pieces -= best_q

        a = copy(selected_bin_configs[(cp_no_of_pieces .+ 1)...])
        append!(a, [best_q])

        selected_bin_configs[(no_of_pieces .+ 1)...] = a
        ret_no_of_bins = bins[(no_of_pieces .+ 1)...]
    end

    return ret_no_of_bins
end

function P__Cmax_HS_Q!(Q::Array{Array{Int},}, # the set Q
                       n::Int, # number of elements in arrays
                       current_position::Int, # initial position
                       current_no_of_pieces::Array{Int},
                       current_weight::Rational{Int},
                       no_of_pieces::Array{Int},
                       sizes_of_pieces::Array{Rational{Int}})
    # Perform the algorithm only if the current position is
    # not greater than n
    if current_position <= n
        for i in 0:no_of_pieces[current_position]
            if i * sizes_of_pieces[current_position] + current_weight <= 1
                cp_current_no_of_pieces = copy(current_no_of_pieces)
                cp_current_no_of_pieces[current_position] = i
                if sum(cp_current_no_of_pieces) > 0
                    if !(cp_current_no_of_pieces in Q)
                        push!(Q, cp_current_no_of_pieces)
                    end
                end
                P__Cmax_HS_Q!(Q,
                              n,
                              current_position + 1,
                              cp_current_no_of_pieces,
                              i * sizes_of_pieces[current_position] + current_weight,
                              no_of_pieces,
                              sizes_of_pieces)
            end
        end
    end
end

function P__Cmax_HS_DABIN(J::Vector{Job}, eps::Rational{Int})
    ########################################
    # PART 1. Schedule all the large jobs. #
    ########################################

    # Find all the jobs that have processing times higher that eps
    J_large_idx = findall(X -> X.p > eps, J)
    # Extract the jobs with high processing times
    J_large = J[J_large_idx]

    # Compute the constants
    s = Int(ceil(1//eps^2))
    iv = (1 - eps)//s

    # Generate the array of length bounds; here, 1:1:s means [1,2,...,s]
    lbounds = eps .+ collect(1:1:s)*iv

    # Generate an array of zeros
    b = fill(0, s)

    # Find the bounds for large jobs
    bounds2idx = Array{Array{Int,1}}(undef, s)
    # For each job in the set of large jobs
    for i in 1:length(J_large)
        # Find the first lower bound good for a big job
        idx = findfirst(x -> (J_large[i].p <= x), lbounds)
        # Increment the corresponding value of b
        b[idx] += 1
        # If no indices have been assigned to bounds2idx,
        # then prepare an empty array for them
        if isassigned(bounds2idx, idx) == false
            bounds2idx[idx] = []
        end
        # Append the corresponding index of a job to it
        append!(bounds2idx[idx], J_large_idx[i])
    end

    # Reduce lower bounds and number of pieces
    valid_bs_idx = findall(x -> (x != 0), b)
    sub_b = b[valid_bs_idx]
    sub_lbounds = lbounds[valid_bs_idx]
    sub_bounds2idx = bounds2idx[valid_bs_idx]

    # Set constants
    n = length(sub_b)
    current_no_of_pieces = fill(0, n)

    # Initialize the set Q
    Q = Array{Int,}[]
    P__Cmax_HS_Q!(Q, n, 1, current_no_of_pieces, Rational{Int}(0), sub_b, sub_lbounds)

    # We start counting at 1 and this would be the real 0
    bins = zeros(Int, Tuple(sub_b .+ 1))
    for q in Q
        bins[Tuple(q .+ 1)...] = 1
    end

    selected_bin_configs = fill([Int[]], Tuple(sub_b .+ 1))

    # Determine the number of bins
    no_of_bins = P__Cmax_HS_BINS(n, sub_b, sub_lbounds, Q, bins, selected_bin_configs)
    res_config = selected_bin_configs[Tuple(sub_b .+ 1)...]

    bin_packing = Array{P__Cmax_HS_BinConfig}(undef, no_of_bins)

    for i in 1:no_of_bins
        bin_packing[i] = P__Cmax_HS_BinConfig(Rational{Int}(0), [])
        config = res_config[i]
        for j in 1:length(config)
            if config[j] > 0
                bin_packing[i].load += config[j] * sub_lbounds[j]
                for k in 1:config[j]
                    task_idx = popfirst!(sub_bounds2idx[j])
                    push!(bin_packing[i].assignments, task_idx)
                end
            end
        end
    end

    ########################################
    # PART 2. Schedule all the small jobs. #
    ########################################

    # Find all the jobs that have processing times lower that eps
    J_small_idx = findall(X -> X.p <= eps, J)
    # Extract the jobs with low processing times
    J_small = J[J_small_idx]


    # Push the elements to bins
    for i in 1:length(J_small)
        bin_idx = 1

        while bin_idx <= no_of_bins && bin_packing[bin_idx].load > 1
            bin_idx += 1
        end

        if bin_idx > no_of_bins
            # Start a new bin
            push!(bin_packing, P__Cmax_HS_BinConfig(Rational{Int}(0), []))
            no_of_bins += 1
        end

        bin_packing[bin_idx].load += J_small[i].p
        push!(bin_packing[bin_idx].assignments, J_small_idx[i])
    end

    return no_of_bins, bin_packing
end

"""
    P__Cmax_HS(J::Vector{Job}, M::Vector{Machine}; eps = 1//10, copy = false, verbose = false)

Finds an approximation solution of the P||Cmax problem based on the algorithms proposed by Hochbaum and Shmoys (1987). If `copy` is set to true, then the returned structure will refer to the copies of the input vectors.

# References
* D.S. Hochbaum and D.B. Shmoys, Using dual approximation algorithms for scheduling problems theoretical and practical results, Journal of the ACM, 34(1):144–162 (1987), doi: 10.1145/7531.7535
"""
function P__Cmax_HS(J::Vector{Job}, M::Vector{Machine}; eps = 1//10, copy = false, verbose = false)
    if copy
        J = Base.copy(J)
        M = Base.copy(M)
    end

    # Generate an empty job assignments list
    A = JobAssignments()

    # Get the number of jobs
    n = length(J)
    # Get the number of machines
    m = length(M)

    # Set the lower and the upper bound on the cmax
    cmax_lb = max(sum(X -> X.p, J) // m, maximum(X -> X.p, J))
    cmax_ub = 2*cmax_lb

    if verbose
        println("* Starting with cmax_lb=$(float(cmax_lb)), cmax_ub=$(float(cmax_ub))")
    end

    # Set the best solution found
    best_bin_packing = nothing

    # Find the best bound for the instance
    while cmax_ub//cmax_lb > 101//100
        # Find the middle point between upper and lower bound
        d = (cmax_ub + cmax_lb)//2
        if verbose
            println("* Trying d=$(float(d)) (cmax_lb=$(float(cmax_lb)), cmax_ub=$(float(cmax_ub)))")
        end

        # Scale all the job processing times
        JC = map(X -> Job(X.name; p = X.p//d), J)
        # Perform a dual approximation for bin packing
        bins, bin_packing = P__Cmax_HS_DABIN(JC, eps)

        if (bins > m)
            if verbose
                println("  Failure: $(m) machines available, $(bins) needed")
                println("           Increasing cmax_lb to $(float(d))")
            end
            cmax_lb = d
        else
            if verbose
                println("  Success: decreasing cmax_ub to $(float(d))")
            end
            cmax_ub = d
            best_bin_packing = bin_packing
        end
    end

    if best_bin_packing != nothing
        # For every bin in a solution (a machine)
        for i in 1:length(best_bin_packing)
            load = Rational{Int}(0)
            # For every assignment of a job to a bin
            for j in best_bin_packing[i].assignments
                # Generate the JobAssignment
                push!(A, JobAssignment(J[j], M[i], load, load + J[j].p))
                # Increase the load
                load = load + J[j].p
            end
        end
    end

    return Schedule(J, M, A)
end
