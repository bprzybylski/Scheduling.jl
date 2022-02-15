using Scheduling, Scheduling.Algorithms

function node_with_successors(J::Vector{Job}, job::Int, successors...) :: Tuple{Job, Vector{Job}}
    return (J[job], [J[s] for s in successors])
end

# manually recreate instance from Hu's paper
# References: T. C. Hu, (1961) Parallel Sequencing and Assembly Line Problems. Operations Research 9(6):841-848. 
# http://dx.doi.org/10.1287/opre.9.6.841
function instance_from_paper()
    J = Jobs(19)
    M = Machines(3)

    IntreeConstraints::Vector{Tuple{Job, Vector{Job}}} = []
    push!(IntreeConstraints, node_with_successors(J, 2, 1))
    push!(IntreeConstraints, node_with_successors(J, 3, 1))
    push!(IntreeConstraints, node_with_successors(J, 4, 2))
    push!(IntreeConstraints, node_with_successors(J, 5, 2))
    push!(IntreeConstraints, node_with_successors(J, 6, 2))
    push!(IntreeConstraints, node_with_successors(J, 7, 4))
    push!(IntreeConstraints, node_with_successors(J, 8, 5))
    push!(IntreeConstraints, node_with_successors(J, 9, 6))
    push!(IntreeConstraints, node_with_successors(J, 10, 7))
    push!(IntreeConstraints, node_with_successors(J, 11, 8))
    push!(IntreeConstraints, node_with_successors(J, 12, 10))
    push!(IntreeConstraints, node_with_successors(J, 13, 10))
    push!(IntreeConstraints, node_with_successors(J, 14, 11))
    push!(IntreeConstraints, node_with_successors(J, 15, 11))
    push!(IntreeConstraints, node_with_successors(J, 16, 13))
    push!(IntreeConstraints, node_with_successors(J, 17, 14))
    push!(IntreeConstraints, node_with_successors(J, 18, 15))
    push!(IntreeConstraints, node_with_successors(J, 19, 15))

    return Dict("J" => J, "IntreeConstraints" => IntreeConstraints, "M" => M)
end

hus_instance = instance_from_paper()

hus_schedule = Algorithms.P__pⱼp__intree__Cmax(hus_instance["J"], hus_instance["M"], hus_instance["IntreeConstraints"])

Scheduling.plot(hus_schedule)