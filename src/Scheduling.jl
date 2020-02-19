module Scheduling

include("types/Job.jl")
include("types/Jobs.jl")
include("types/Machine.jl")
include("types/Machines.jl")
include("types/JobAssignment.jl")
include("types/JobAssignments.jl")
include("types/Schedule.jl")

module Objectives
include("objectives/cmax.jl")
include("objectives/csum.jl")
include("objectives/lmax.jl")
include("objectives/tsum.jl")
include("objectives/nt.jl")
end

end # module
