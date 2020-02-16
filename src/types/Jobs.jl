const Jobs = Vector{Job}

function Base.show(io::IO, ::MIME"text/plain", S::Jobs)
    print("A set of $(size(S)[1]) job(s):")
    for J in S
        print(io, "\n\t")
        show(io, J)
    end
end
