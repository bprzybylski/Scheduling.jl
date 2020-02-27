export Machine, Machines

struct Machine
    name::String
    s::Rational{UInt}   # speed
    function Machine(name::String; s = 1)
        return new(name, s)
    end
end

function Base.show(io::IO, M::Machine)
    function rtos(r::Rational)
        if r == Inf
            return "∞"
        elseif denominator(r) == 1
            return string(numerator(r))
        end
        return string(numerator(r), "//", denominator(r))
    end

    print(io, "Machine ")
    printstyled(io, "$(M.name)"; bold = true, color = :light_yellow)
    if M.s != 1
        print(io, ":\t [s = ")
        printstyled(io, "$(rtos(M.s))"; bold = true, color = :magenta)
        print(io, "]")
    end
end

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
