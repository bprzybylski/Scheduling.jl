export Machine, Machines, MachineParams, ClassicalMachineParams

abstract type MachineParams end

##########################
# ClassicalMachineParams #
##########################

struct ClassicalMachineParams <: MachineParams
    s::Rational{UInt}   # speed
    function ClassicalMachineParams(;s = 1)
        return new(s)
    end
end

###########
# Machine #
###########

struct Machine
    name::String
    params::MachineParams
    function Machine(name::String, params = ClassicalMachineParams())
        return new(name, params)
    end
end

function Base.show(io::IO, M::Machine)
    if typeof(M.params) == ClassicalMachineParams
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
        if M.params.s != 1
            print(io, ":\t (s = ")
            printstyled(io, "$(rtos(M.params.s))"; bold = true, color = :magenta)
            print(io, ")")
        end
    else
        print(io, "Machine ")
        printstyled(io, "$(M.name)"; bold = true, color = :light_yellow)
        print(io, "[$(typeof(M.params))]")
    end
end

function Base.show(io::IO, ::MIME"text/plain", S::Vector{Machine})
    print("A set of $(length(S)) machine(s):")
    for M in S
        print(io, "\n\t")
        show(io, M)
    end
end

##############
# Generators #
##############

"""
    Machines()

Generates an empty vector of `Machine{ClassicalMachineParams}` elements.

# Example
```julia-repl
julia> Machines()
A set of 0 machine(s):

```
"""
function Machines()
    return Vector{Machine}()
end

"""
    Machines(m::Int)

Generates a set of `m` identical parallel machines, denoted by `P_1`, `P_2`, etc.

# Example
```julia-repl
julia> Machines(4)
A set of 4 machine(s):
    Machine P_1
    Machine P_2
    Machine P_3
    Machine P_4

```
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

# Example
```julia-repl
julia> Machines([1, 1//2, 2])
A set of 3 machine(s):
    Machine Q_1
    Machine Q_2:     [s = 1//2]
    Machine Q_3:     [s = 2]

```
"""
function Machines(S::Array{Rational{Int}, 1})
    M = Machines()

    for i in 1:length(S)
        if S[i] <= 0
            error("Machine $i cannot have a non-positive speed.")
        end
        if i < 10
            push!(M, Machine("Q_$i", ClassicalMachineParams(s = S[i])))
        else
            push!(M, Machine("Q_{$i}", ClassicalMachineParams(s = S[i])))
        end
    end

    return M
end

"""
    Machines(S::Array{Int, 1})

Generates a set of machines with speeds determined by the `S` array, denoted by `Q_1`, `Q_2`, etc.

# Example
```julia-repl
julia> Machines([1, 3, 2])
A set of 3 machine(s):
    Machine Q_1
    Machine Q_2:     [s = 3]
    Machine Q_3:     [s = 2]

```
"""
Machines(S::Array{Int, 1}) = Machines(Array{Rational{Int},1}(S))
