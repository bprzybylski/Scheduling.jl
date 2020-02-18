export Machine

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
