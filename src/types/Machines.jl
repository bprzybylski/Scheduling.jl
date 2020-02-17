const Machines = Vector{Machine}

function Base.show(io::IO, ::MIME"text/plain", S::Machines)
    print("A set of $(size(S)[1]) machine(s):")
    for M in S
        print(io, "\n\t")
        show(io, M)
    end
end
