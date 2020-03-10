# List algorithms

The `Scheduling.jl` package provides a set of algorithms based on well-known priority rules. These algorithms are designed for scheduling on identical parallel machines.

```@docs
Algorithms.list!(J::Vector{Job}, M::Vector{Machine})
Algorithms.list(J::Vector{Job}, M::Vector{Machine})
Algorithms.spt!(J::Vector{Job}, M::Vector{Machine}; weighted = false)
Algorithms.spt(J::Vector{Job}, M::Vector{Machine}; weighted = false)
Algorithms.wspt!(J::Vector{Job}, M::Vector{Machine})
Algorithms.wspt(J::Vector{Job}, M::Vector{Machine})
Algorithms.lpt!(J::Vector{Job}, M::Vector{Machine}; weighted = false)
Algorithms.lpt(J::Vector{Job}, M::Vector{Machine}; weighted = false)
Algorithms.wlpt!(J::Vector{Job}, M::Vector{Machine})
Algorithms.wlpt(J::Vector{Job}, M::Vector{Machine})
```
