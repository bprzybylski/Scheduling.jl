export Machines

function Base.show(io::IO, ::MIME"text/plain", S::Vector{Machine})
    print("A set of $(size(S)[1]) machine(s):")
    for M in S
        print(io, "\n\t")
        show(io, M)
    end
end

"""
    Machines()

Generates an empty vector of `Machine` elements.
"""
function Machines()
    return Vector{Machine}()
end

"""
    Machines(m::Int)

Generates a set of `m` identical parallel machines, denoted by `P_1`, `P_2`, etc.
"""
function Machines(m::Int)
    M = Machines()

    for i in 1:m
        if i < 10
            push!(M, Machine("P_$i"))
        else
            push!(M, Machine("P_{$i}"))
        end
    end

    return M
end

"""
    Machines(S::Array{Rational{Int}, 1})

Generates a set of machines with speeds determined by the `S` array, denoted by `Q_1`, `Q_2`, etc.
"""
function Machines(S::Array{Rational{Int}, 1})
    M = Machines()

    for i in 1:length(S)
        if S[i] <= 0
            error("Machine $i cannot have a non-positive speed.")
        end
        if i < 10
            push!(M, Machine("Q_$i", s = S[i]))
        else
            push!(M, Machine("Q_{$i}", s = S[i]))
        end
    end

    return M
end

"""
    Machines(S::Array{Int, 1})

Generates a set of machines with speeds determined by the `S` array, denoted by `Q_1`, `Q_2`, etc.
"""
Machines(S::Array{Int, 1}) = Machines(Array{Rational{Int},1}(S))
