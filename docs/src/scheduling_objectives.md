# Objective functions

Given a schedule, one can find its objective value based on one of the following functions from the `Scheduling.Objectives` submodule. After the module is loaded, the function names are in the global scope.

```@docs
cmax(S::Schedule)
csum(S::Schedule; weighted = false)
wcsum(S::Schedule)
lmax(S::Schedule)
nt(S::Schedule; weighted = false)
wnt(S::Schedule)
tsum(S::Schedule; weighted = false)
wtsum(S::Schedule)
```
