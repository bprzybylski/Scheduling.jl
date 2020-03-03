mutable struct MachineLoad
    index::UInt
    load::Rational{UInt}
end

function Base.isless(a::MachineLoad, b::MachineLoad)
    if a.load < b.load || (a.load == b.load && a.index < b.index)
        return true
    end
    return false
end
