using Documenter
using Scheduling, Scheduling.Objectives, Scheduling.Algorithms

makedocs(
   format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true"
   ),
   sitename = "Scheduling.jl",
   modules = [Scheduling, Scheduling.Objectives, Scheduling.Algorithms],
   clean = true,
   doctest = false,
   strict = false,
   checkdocs = :none,
   pages    = [
      "Introduction" => "index.md",
      "Basics" => [
         "scheduling_jobs.md",
         "scheduling_machines.md",
         "scheduling_assignments.md",
         "scheduling_schedules.md",
         "scheduling_objectives.md"
      ],
      "Algorithms" => [
         "algorithms_list.md",
         "algorithms_P__Cmax.md"
      ],
      "examples.md"
   ]
)

deploydocs(
   repo   = "github.com/bprzybylski/Scheduling.jl.git",
   target = "build",
)
