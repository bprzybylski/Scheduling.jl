# $\text{P}||\text{C}_\text{max}$

The $\text{P}||\text{C}_\text{max}$ problem is one of the most popular scheduling problems known. There exist plenty of different algorithms and approaches to solving it or approximating an exact solution, as the problem itself is strongly NP-hard. `Scheduling.jl` provides a few algorithms for the $\text{P}||\text{C}_\text{max}$ problem which state a base for extending the package by new ones.

```@docs
Algorithms.P__Cmax_IP!(J::Vector{Job}, M::Vector{Machine}; optimizer = GLPK.Optimizer)
Algorithms.P__Cmax_IP(J::Vector{Job}, M::Vector{Machine}; optimizer = GLPK.Optimizer)
Algorithms.P__Cmax_HS!(J::Vector{Job}, M::Vector{Machine}; eps = 1//10, verbose = false)
Algorithms.P__Cmax_HS(J::Vector{Job}, M::Vector{Machine}; eps = 1//10, verbose = false)
Algorithms.P__Cmax_MR!(J::Vector{Job}, M::Vector{Machine})
Algorithms.P__Cmax_MR(J::Vector{Job}, M::Vector{Machine})
```
