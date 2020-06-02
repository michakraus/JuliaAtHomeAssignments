
# Julia@Home Assignments

## 1. Create a new Project

In order to organise your code, create a new Julia project.
Open the julia interpreter
```
$ julia
```
change to the `Pkg` REPL with `]` so that you see a prompt like the following:
```
(@v1.4) pkg>
```
Create the project using the `generate` command:
```
(@v1.4) pkg> generate Particles
 Generating  project Particles:
    Particles/Project.toml
    Particles/src/Particles.jl
```
This creates two files: `Project.toml` stores meta-data and dependencies of the package, and `src/Particles.jl` contains the main module.
The newly generated environment is activated by the `activate` command:
```
(@v1.4) pkg> activate Particles
 Activating new environment at `~/Particles/Project.toml`
```
Now you can add dependencies.
You will probably want to plot simulation results, which can be done by either Plots.jl or Makie.jl.
