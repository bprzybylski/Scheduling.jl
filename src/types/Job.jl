struct Job
    name::String
    p::Rational{UInt64} # basic processing time
    w::Rational{Int64}  # weight
    r::Rational{UInt64}  # ready time
    d::Rational{Int64}  # due date
    D::Rational{UInt64}  # deadline
    function Job(name::String; p = 1, w = 1, r = 0, d = Inf, D = Inf)
        if r + p > D
            error("It is impossible for a job with [r + p > D] to exist.")
        end
        return new(name, p, w, r, d, D)
    end
end

function Base.show(io::IO, J::Job)
    function rtos(r::Rational)
        if r == Inf
            return "∞"
        elseif denominator(r) == 1
            return string(numerator(r))
        end
        return string(numerator(r), "//", denominator(r))
    end

    print(io, "Job ")
    printstyled(io, "$(J.name):\t"; bold = true, color = :light_blue)
    print(io, "[p = ")
    printstyled(io, "$(rtos(J.p))"; bold = true, color = :light_cyan)
    if J.w != 1
        print(io, ", w = ")
        printstyled(io, "$(rtos(J.w))"; bold = true, color = :magenta)
    end
    if J.r != 0
        print(io, ", r = ")
        printstyled(io, "$(rtos(J.r))"; bold = true, color = :light_black)
    end
    if J.d != Inf
        print(io, ", d = ")
        printstyled(io, "$(rtos(J.d))"; bold = true, color = :light_black)
    end
    if J.D != Inf
        print(io, ", D = ")
        printstyled(io, "$(rtos(J.D))"; bold = true, color = :light_black)
    end
    print(io, "]")
end
