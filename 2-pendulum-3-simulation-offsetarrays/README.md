
# Julia@Home Assignments

## 2. Pendulum

### The Simulation Type Revised

In the following we want to refine our Simulation type a bit.

#### OffsetArrays

At first, we want to use an OffsetArray to store the solution instead of vanilla arrays.
We first have to add the OffsetArrays package to our project.
To this end, start Julia in the `Particles` directory via
```
$ julia --project=.
```
and change to the `Pkg` REPL with `]` so that you see a prompt like the following:
```
(@v1.4) pkg>
```
Add the OffsetArrays package:
```
(@v1.4) pkg> add OffsetArrays
   Updating registry at `~/.julia/registries/General`
   Updating git-repo `https://github.com/JuliaRegistries/General`
  Resolving package versions...
   Updating `~/Particles/Project.toml`
  [6fe1bfb0] + OffsetArrays v1.0.4
   Updating `~/Particles/Manifest.toml`
  [6fe1bfb0] + OffsetArrays v1.0.4
```

In the next step, we import `OffsetArrays` into the `Particles` module:
```julia
module Particles

using OffsetArrays

export Simulation, run!

include("simulation.jl")

end
```
Alternatively, we could import `OffsetArrays` in the `src/simulation.jl` file. However, as `using OffsetArrays` brings all names that are exported by OffsetArrays into the `Particles` namespace, it is better practice to import it here.

Finally, we have to modify the Simulation type:
```julia
struct Simulation{DT <: Number, AT <: OffsetArray{DT,3}}
    Δt::DT
    nt::Int
    x::AT

    function Simulation(x₀::AbstractArray{DT,2}, Δt::DT, nt::Int) where {DT}
        x = OffsetArray(zeros(DT, size(x₀)..., nt+1), axes(x₀)..., 0:nt)
        x[:,:,0] .= x₀
        new{DT, typeof(x)}(Δt, nt, x)
    end
end
```
We see that the solution field `x` was modified to be of type `AT`, which is a type parameter, and a subtype of `OffsetArray{DT,3}`.
In the constructor, we take the array we create by the `zero` function and pass it to the `OffsetArray` constructor, together with the ranges for all three dimensions.
Now, we can store the initial conditions in the temporal index `0` instead of `1`.
A final change with respect to the original implementation is that we have to pass the type of the solution array to the `new` function.

In the `run!` function, we need to adapt the temporal indices of the solution array:
```julia
function run!(sim::Simulation)
    for n in 1:sim.nt
        for i in axes(sim.x, 2)
            sim.x[1,i,n] = sim.x[1,i,n-1] + sim.Δt * sim.x[2,i,n-1]
            sim.x[2,i,n] = sim.x[2,i,n-1] - sim.Δt * sin(sim.x[1,i,n-1])
        end
    end
    return sim.x
end
```

Adding the type parameter `AT` was mostly a matter convenience. 
We could also make this explicit and replace `AT` with `OffsetArray{DT,3,Array{DT,3}}`, which is the actual type of our OffsetArray:
```julia
struct Simulation{DT <: Number}
    Δt::DT
    nt::Int
    x::OffsetArray{DT,3,Array{DT,3}}

    function Simulation(x₀::AbstractArray{DT,2}, Δt::DT, nt::Int) where {DT}
        x = OffsetArray(zeros(DT, size(x₀)..., nt+1), axes(x₀)..., 0:nt)
        x[:,:,0] .= x₀
        new{DT}(Δt, nt, x)
    end
end
```
With this, we do not need to pass the type of the solution array in the call to `new`.
Explicitly specifying the OffsetArray type removes one of the type parameters, which is generally considered preferable.

