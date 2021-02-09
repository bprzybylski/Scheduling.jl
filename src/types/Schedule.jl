export Schedule

using JLD2
using Plots
using Plots.PlotMeasures

mutable struct Schedule
    jobs::Vector{Job}
    machines::Vector{Machine}
    assignments::Vector{JobAssignment}
    function Schedule(jobs = Jobs(), machines = Machines(), assignments = JobAssignments())
        return new(jobs, machines, assignments)
    end
end

"""
    TeX(S::Schedule, output_file::String = "Schedule.tex"; compile = false)

Generates a TeX file with a tikz representation of a schedule. An optional parameter `compile` determines whether the output file should be automatically compiled using `pdflatex`. If the `output_file` exists, then it will be replaced without any prompt. All the intermediate directories will be created if needed.

# Examples
```julia-repl
julia> Scheduling.TeX(S, "/absolute/path/to/the/file.tex")
julia> Scheduling.TeX(S, "../relative/path/to/the/file.tex", compile = true)
```
"""
function TeX(S::Schedule, output_file::String = "Schedule.tex"; compile = false)
    file_path = abspath(output_file)
    build_dir = dirname(file_path)
    if !isdir(build_dir)
        mkpath(build_dir)
    end

    open(file_path, "w") do f
        write(f, """%!TEX program=pdflatex
                \\documentclass[crop,tikz]{standalone}

                \\begin{document}
                \\def\\ux{0.5cm}\\def\\uy{-0.6cm}
                \\begin{tikzpicture}
                \\tikzset{x=\\ux,
                          y=\\uy,
                          burst/.style 2 args={draw,
                                               anchor=south west,
                                               minimum height=-\\uy,
                                               minimum width=#2*\\ux,
                                               node contents=#1,
                                               inner sep=0pt}}
                \\tikzset{x=\\ux,
                          y=\\uy,
                          burstp/.style n args={3}{draw,
                                                anchor=south west,
                                                minimum height=-#2*\\uy,
                                                minimum width=#3*\\ux,
                                                node contents=#1,
                                                inner sep=0pt}}
                """)

        # Find the number of machines
        m = length(S.machines)
        # Find the length of a schedule
        cmax = 0
        if length(S.assignments) > 0
            cmax = maximum(A->A.P.C, S.assignments)
        end

        write(f, "% Processors", "\n")
        for i in 1:m
            M = S.machines[i]
            write(f, "\\fill[gray!15] (0,$(i - 1)) rectangle ($(Int(ceil(cmax))), $i);", "\t")
            write(f, "\\node[left,xshift=-0.25cm] at (0,0.5+$(i - 1)) {\$$(M.name)\$};", " % $M", "\n")
        end

        write(f, "% Jobs", "\n")
        for A in S.assignments

            if  typeof(A.P) == ClassicalJobAssignmentProperties
                write(f, "\\path ($(float(A.P.S))-.015,$(findfirst(x->x==A.P.M, S.machines))) node[burst={\$$(A.J.name)\$}{$(float(A.P.C-A.P.S))}, fill=white];", " % $A", "\n")
            else
                nmach = length(A.P.M)
                first_mach = A.P.M[1]
                last_mach = last(A.P.M)
                write(f, "\\path ($(float(A.P.S))-.015,$(findfirst(x->x==last_mach, S.machines))) node[burstp={\$$(A.J.name)\$}{$(nmach)}{$(float(A.P.C-A.P.S))}, fill=white];", " % $A", "\n")
            end
    
        end

        write(f, """% Draw the horizontal axis
                \\draw (0,$m-.015) -- ($(Int(ceil(cmax))),$m-.015);
                % Mark integers on this axis
                \\foreach \\i in {0,1,2,...,$(Int(ceil(cmax)))}
                    \\draw (\\i, $m.3) node[below] {\\i}--++(0,-.3);
                """)

        write(f, """\\end{tikzpicture}
                \\end{document}
                """)

        # External LaTeX compilation
        if compile
            @async run(`pdflatex -output-directory $build_dir $file_path`)
        end
    end
end

"""
    plot(S::Schedule;
         animate = false, sizex = 800, sizey = 500,
         output_file::String = "Schedule.gif", fps = 1)

Plots a schedule. The optional arguments are taken into account if `animate` is set to `true`. Then, a `gif` file is generated.

# Examples
```julia-repl
julia> Scheduling.plot(S)
julia> Scheduling.plot(S, animate = true)
```
"""
function plot(S::Schedule; animate = false, sizex = 800, sizey = 500, output_file::String = "Schedule.gif", fps = 1)
    if animate
        file_path = abspath(output_file)
        build_dir = dirname(file_path)
        if !isdir(build_dir)
            mkpath(build_dir)
        end
    end

    # Find the number of machines
    m = length(S.machines)
    # Find the length of a schedule
    cmax = 0
    if length(S.assignments) > 0
        cmax = maximum(A->A.P.C, S.assignments)
    end

    rectangle(w::Float64, h::Int64, x::Float64, y::Int64) =
        Plots.Shape(x .+ [0,w,w,0], y .+ [0,0,h,h])

    #Plots.theme(:juno)
    Plots.theme(:default)
    Plots.pyplot(size = (sizex, sizey), legend = false, dpi=300)
    Plots.plot(xlims = (0, cmax),
               ylims = (0, m),
               yflip = true,
               ytickfont = font(18, "Courier New"),
               margin = 15px)

    # Generate yticks
    Plots.yticks!([i - 0.5 for i in 1:m],
                  [S.machines[i].name for i in 1:m])

    if animate
        anim = Plots.Animation()
        Plots.frame(anim)
    end

    for A in S.assignments
        x = float(A.P.S)

        if  typeof(A.P) == ClassicalJobAssignmentProperties
            y = findfirst(x->x==A.P.M, S.machines) - 1
            w = float(A.P.C-A.P.S)
            h = 1
        else
            # these are the parallel jobs
            # there must be at least one machine
            #println(A.J)
            #println(A.P)

            nmach = length(A.P.M)
            first_mach = A.P.M[1]
            last_mach = last(A.P.M)
            #println(first_mach.name * " : " * last_mach.name)

            y = findfirst(x->x==first_mach, S.machines) - 1
            w = float(A.P.C-A.P.S)
            h = findfirst(x->x==last_mach, S.machines) - findfirst(x->x==first_mach, S.machines) + 1
            #println(y, " ", w, " ", h)
        end

        Plots.plot!(rectangle(w, h, x, y))
        Plots.annotate!([(x+w/2, y+h/2,
                        Plots.text(A.J.name, :center, 14, "Courier New"))])

        if animate
            Plots.frame(anim)
        end
    end


    if animate
        Plots.gif(anim, output_file, fps = fps)
    else
        Plots.current()
    end
end

"""
    save(S::Schedule, output_file::String = "Schedule.jld")

Saves a schedule to a file so it can be reloaded later.
"""
function save(S::Schedule, output_file::String = "Schedule.jld")
    file_path = abspath(output_file)
    build_dir = dirname(file_path)
    if !isdir(build_dir)
        mkpath(build_dir)
    end

    jldopen(output_file, "w") do f
        f["S"] = S
    end

    return
end

"""
    load(input_file::String = "Schedule.jld")

Loads a schedule from a file. Return a reference to a loaded schedule.
"""
function load(input_file::String = "Schedule.jld")
    S = Schedule()

    jldopen(input_file, "r") do f
        S = f["S"]
    end

    return S
end
