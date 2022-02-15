import Graphs: SimpleDiGraph, add_vertex!, add_edge!, vertices, edges, outneighbors, inneighbors, is_cyclic, nv, rem_edge!, is_connected
import DataStructures: PriorityQueue, enqueue!, dequeue!

function jobs_and_intree_to_graph(J::Vector{Job}, IntreeConstraints::Vector{Tuple{Job,Vector{Job}}})
    n = size(J)[1]
    #create digraph from job list and intree constraints
    graph = SimpleDiGraph(n)
    for (job, successors) in IntreeConstraints
        ind_1 = findfirst(x -> x == job, J)
        for succ in successors
            ind_2 = findfirst(x -> x == succ, J)
            add_edge!(graph, ind_1, ind_2)
        end
    end
    terminals::Vector{Int} = []
    for node in vertices(graph)
        if size(outneighbors(graph, node), 1) == 0
            push!(terminals, node)
        end
    end
    #if there are more than 1 terminal nodes, then introduce artificial terminal node
    terminal = Nothing
    if size(terminals, 1) > 1
        terminal = n + 1
        add_vertex!(graph)
        for t in terminals
            add_edge!(graph, t, terminal)
        end
    elseif size(terminals, 1) == 1
        terminal = terminals[1]
    else
        terminal
    end
    return graph, terminal
end

function label_graph(graph::SimpleDiGraph, terminal::Int)::Vector{Int}
    labels = [0 for _ in vertices(graph)]
    distance = 1
    labels[terminal] = distance

    current_layer = inneighbors(graph, terminal)

    while !isempty(current_layer)
        distance += 1
        next_layer = []
        for node in current_layer
            labels[node] = distance
            next_layer = [next_layer; inneighbors(graph, node)]
        end
        current_layer = next_layer
    end
    return labels
end

"""
    P__pⱼp__intree__Cmax(J::Vector{Job}, M::Vector{Machine}, IntreeConstraints::Vector{Tuple{Job,Vector{Job}}})

This is an exact algorithm for scheduling uniform jobs with intree constraints. Intree constraints are given as 
a vector of tuples (j, s), where j is a job and s is a vector of successors of j. 

References: T. C. Hu, (1961) Parallel Sequencing and Assembly Line Problems. Operations Research 9(6):841-848. 
http://dx.doi.org/10.1287/opre.9.6.841
"""
function P__pⱼp__intree__Cmax(J::Vector{Job}, M::Vector{Machine}, IntreeConstraints::Vector{Tuple{Job,Vector{Job}}})
    #first, create graph from intree constraints
    n = size(J, 1)
    m = size(M, 1)
    p = J[1].params.p
    graph, terminal = jobs_and_intree_to_graph(J, IntreeConstraints)
    @assert !is_cyclic(graph)
    @assert is_connected(graph)

    #then, label nodes with the distance of longest path to root
    labels = label_graph(graph, terminal)

    starting_nodes = PriorityQueue{Int,Int}(Base.Order.Reverse)
    for node in vertices(graph)
        if isempty(inneighbors(graph, node))
            enqueue!(starting_nodes, node, labels[node])
        end
    end

    current_time = 0

    assignments = JobAssignment[]

    while length(starting_nodes) > 0
        scheduled_jobs = []
        for i = 1:m
            if length(starting_nodes) == 0
                break
            end
            push!(scheduled_jobs, dequeue!(starting_nodes))
        end

        #remove jobs from list and add new starting nodes
        for job in scheduled_jobs
            successors = outneighbors(graph, job)
            for succ in successors
                rem_edge!(graph, job, succ)
                if isempty(inneighbors(graph, succ))
                    enqueue!(starting_nodes, succ, labels[succ])
                end
            end
        end

        #schedule jobs on Machines and increase timestep
        for (index, job) in enumerate(scheduled_jobs)
            job == n+1 && continue #ignore artificial terminal node
            push!(assignments,
                JobAssignment(
                    J[job],
                    M[index],
                    current_time,
                    current_time + p
                )
            )
        end

        current_time += p
    end

    return Schedule(J, M, assignments)
end