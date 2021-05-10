module Scheduling

include("types/Job.jl")
include("types/Machine.jl")
include("types/JobAssignment.jl")
include("types/Schedule.jl")

include("types/MachineLoad.jl")

# module SchedulingOptimizer
# include("helper/optimizer_selector.jl")
# include("helper/model_glpk.jl")
# #include("helper/model_gurobi.jl")
# end

module Objectives
include("objectives/cmax.jl")
include("objectives/csum.jl")
include("objectives/lmax.jl")
include("objectives/tsum.jl")
include("objectives/nt.jl")
end

module Algorithms
include("algorithms/list.jl")
include("algorithms/P__Cmax/IP.jl")
include("algorithms/P__Cmax/MR.jl")
include("algorithms/P__Cmax/HS.jl")
include("algorithms/P2__Cmax/SW1.jl")
include("algorithms/P2__Cmax/SW3.jl")
include("algorithms/P_any_Cmax/MRT.jl")
include("algorithms/P_any_Cmax/DL.jl")
include("algorithms/P_any_Cmax/TWY.jl")
end

end # module
