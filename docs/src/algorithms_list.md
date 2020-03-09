# List algorithms

The `Scheduling.jl` package provides a set of algorithms based on well-known priority rules. These algorithms are designed for scheduling on identical parallel machines.

```@docs
Algorithms.list(J::Vector{Job}, M::Vector{Machine}; copy = false)
Algorithms.spt(J::Vector{Job}, M::Vector{Machine}; weighted = false, copy = false)
Algorithms.wspt(J::Vector{Job}, M::Vector{Machine}; copy = false)
Algorithms.lpt(J::Vector{Job}, M::Vector{Machine}; weighted = false, copy = false)
Algorithms.wlpt(J::Vector{Job}, M::Vector{Machine}; copy = false)
```
