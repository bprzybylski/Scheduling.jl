mutable struct Schedule
    jobs::Jobs
    machines::Machines
    assignments::JobAssignments
    function Schedule(jobs = Jobs(), machines = Machines(), assignments = JobAssignments())
        return new(jobs, machines, assignments)
    end
end

"""
    save(S::Schedule, output_file::String; compile = false)

Generates a TeX file with a tikz representation of a schedule. An optional parameter `compile` determines whether the output file should be automatically compiled using `pdflatex`. If the `output_file` exists, then it will be replaced without any prompt. All the intermediate directories will be created if needed.

# Examples
```julia-repl
julia> Scheduling.save(S, "/absolute/path/to/the/file.tex")
julia> Scheduling.save(S, "../relative/path/to/the/file.tex", compile = true)
```
"""
function save(S::Schedule, output_file::String; compile = false)
    file_path = abspath(output_file)
    build_dir = dirname(file_path)
    if !isdir(build_dir)
        mkpath(build_dir)
    end

    open(file_path, "w") do f
        write(f, """%!TEX program=pdflatex
                \\documentclass[crop,tikz]{standalone}
                \\usetikzlibrary{arrows.meta}

                \\begin{document}
                \\def\\ux{0.5cm}\\def\\uy{-0.6cm}
                \\begin{tikzpicture}
                \\tikzset{x=\\ux,
                          y=\\uy,
                          >=Latex,
                          burst/.style 2 args={draw,
                                               anchor=south west,
                                               minimum height=-\\uy,
                                               minimum width=#2*\\ux,
                                               node contents=#1,
                                               inner sep=0pt}}
                """)

        # Find the number of machines
        m       = size(S.machines)[1]
        # Find the length of a schedule
        cmax    = float(maximum(A->A.C, S.assignments))

        write(f, "% Processors", "\n")
        for i in 1:m
            M = S.machines[i]
            write(f, "\\fill[gray!15] (0,$(i - 1)) rectangle ($cmax, $i);", "\t")
            write(f, "\\node[left,xshift=-0.25cm] at (0,0.5+$(i - 1)) {\$$(M.name)\$};", " % $M", "\n")
        end

        write(f, "% Jobs", "\n")
        for A in S.assignments
            write(f, "\\path ($(float(A.S))-.015,$(findfirst(x->x==A.M, S.machines))) node[burst={\$$(A.J.name)\$}{$(float(A.C-A.S))}, fill=white];", " % $A", "\n")
        end

        write(f, """% Draw the horizontal axis
                \\draw (0,$m-.015) -- ($cmax,$m-.015);
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
