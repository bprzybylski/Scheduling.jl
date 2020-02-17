const Jobs = Vector{Job}

function Base.show(io::IO, ::MIME"text/plain", S::Jobs)
    print("A set of $(size(S)[1]) job(s):")
    for J in S
        print(io, "\n\t")
        show(io, J)
    end
end

"""
    function generateJobs(n::Int)

Generates a set of `n` identical unit jobs, denoted by `J_1`, `J_2`, etc.
"""
function generateJobs(n::Int)
    J = Jobs()

    for i in 1:n
        if i < 10
            push!(J, Job("J_$i"))
        else
            push!(J, Job("J_{$i}"))
        end
    end

    return J
end

"""
    function generateJobs(P::Array{Rational{Int}, 1})

Generates a set of jobs with basic processing times determined by the `P` array, by `Q_1`, `Q_2`, etc.
"""
function generateJobs(P::Array{Rational{Int}, 1})
    J = Jobs()

    for i in 1:size(P)[1]
        if P[i] <= 0
            error("Job $i cannot have a non-positive processing time.")
        end
        if i < 10
            push!(J, Job("J_$i", p = P[i]))
        else
            push!(M, Job("J_{$i}", p = P[i]))
        end
    end

    return J
end
