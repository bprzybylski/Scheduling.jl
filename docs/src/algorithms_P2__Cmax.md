# $\text{P}2||\text{C}_\text{max}$

The $\text{P}2||\text{C}_\text{max}$ problem is one of the most popular scheduling problems known. There exist plenty of different algorithms and approaches to solving it or approximating an exact solution, as the problem itself is strongly NP-hard. `Scheduling.jl` provides a few approximation algorithms for the $\text{P}2||\text{C}_\text{max}$ problems.

```@docs
Algorithms.P2__Cmax_SW1(J::Vector{Job}, M::Vector{Machine}; eps = 1//10)
Algorithms.P2__Cmax_SW3(J::Vector{Job}, M::Vector{Machine}; eps = 1//10)
```
