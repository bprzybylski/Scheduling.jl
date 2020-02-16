mutable struct Schedule
    jobs::Jobs
    assignments::JobAssignments
    function Schedule(jobs = Jobs(), assignments = JobAssignments())
        return new(jobs, assignments)
    end
end

function save(S::Schedule, file::String; compile = false)
    file_path = abspath(file)
    build_dir = dirname(file_path)

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
        m       = Int(maximum(A->A.M, S.assignments))
        # Find the length of a schedule
        cmax    = float(maximum(A->A.C, S.assignments))

        write(f, """% Draw the horizontal axis
                \\draw (0,$m) -- ($cmax,$m);
                % Mark integers on this axis
                \\foreach \\i in {0,1,2,...,$(Int(ceil(cmax)))}
                    \\draw (\\i, $m.3) node[below] {\\i}--++(0,-.3);
                """)

        write(f, "% Processors", "\n")
        for i in 1:m
            write(f, "\\fill[gray!15] (0,$(i - 1)) rectangle ($cmax, $i);", "\t")
            write(f, "\\node[left,xshift=-0.25cm] at (0,0.5+$(i - 1)) {\$M_$i\$};", " % M$i", "\n")
        end

        write(f, "% Jobs", "\n")
        for A in S.assignments
            write(f, "\\path ($(float(A.S)),$(A.M)) node[burst={\$$(A.J.name)\$}{$(float(A.C-A.S))}, fill=white];", " % $A", "\n")
        end

        write(f, """\\end{tikzpicture}
                \\end{document}
                """)

        # External LaTeX compilation
        if compile
            @async run(`pdflatex -output-directory $build_dir $file_path`)
        end
    end
end
