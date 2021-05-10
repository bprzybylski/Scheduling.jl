# $\text{P}|\text{any}|\text{C}_\text{max}$

`Scheduling.jl` provides a few algorithms for the $\text{P}|\text{any}|\text{C}_\text{max}$ problem.

```@docs
Algorithms.P2_any_Cmax_DL(J::Vector{Job}, M::Vector{Machine})
Algorithms.P_any_Cmax_MRT(J::Vector{Job}, M::Vector{Machine})
Algorithms.P_any_Cmax_TWY(J::Vector{Job}, M::Vector{Machine})
```
