
# Julia@Home Assignments

## 2. Pendulum

Implement a simulation for `n` independent pendula:
$$
\dot{x} = v , \quad
\dot{v} = - \sin(x) .
$$


### The Simulation Type

We start by writing a `Simulation` type that stores all the necessary information (solution, time step size, number of time steps, etc.).
Create a new file `src/simulation.jl` and include that file in `src/Particles.jl`:
```julia; eval=false
module Particles

include("simulation.jl")

end
```

In `simulation.jl` implement a new `struct` with the aforementioned fields:
```julia; eval=false
struct Simulation{DT <: Number}
    Δt::DT
    nt::Int
    x::Array{DT,3}

    function Simulation(x₀::AbstractArray{DT,2}, Δt::DT, nt::Int) where {DT}
        x = zeros(DT, size(x₀)..., nt+1)
        x[:,:,1] .= x₀
        new{DT}(Δt, nt, x)
    end
end
```
The `Simulation` type has one constructor that takes the initial conditons `x₀`, time step `Δt` and the number of time steps to compute `nt`.
We expect the initial conditions to be a 2d array, where the first dimension holds the degrees of freedom, and the second dimension holds different samples.
Based on the size of the initial condition array, we create a 3d solution array that has the same first two dimensions as the initial conditions and the number of time steps as the third dimension.

At first, we proceed by supporting only one specific time-stepping scheme and one specific equation, in this case the explicit Euler method and the pendulum example.
This is implemented in the function `run!`,
```julia; eval=false
function run!(sim::Simulation)
    for n in 1:sim.nt
        for i in axes(sim.x, 2)
            sim.x[1,i,n+1] = sim.x[1,i,n] + sim.Δt * sim.x[2,i,n]
            sim.x[2,i,n+1] = sim.x[2,i,n] - sim.Δt * sin(sim.x[1,i,n])
        end
    end
    return sim.x
end
```
which takes an instance `sim` of `Simulation` as parameter, applies the time integrator for `sim.nt` time steps and stores the solution in `sim.x`.
For convenience, the `run!` function returns the solution array.
Note that the number of samples is not stored explicitly, but inferred from the solution array size.

In order to conveniently load the Particle package, export `Simulation` and `run!` in the module in `src/Particles.jl`:
```julia; eval=false
module Particles

export Simulation, run!

include("simulation.jl")

end
```
Note that the order in which the export statement and the actual definition of e.g. the `Simulation` type appear does not matter.

In order to run the simulation, we create a new file `scripts/pendulum.jl`:
```julia; eval=false
# import Particles package
using Particles

# parameters
Δt = 0.1    # time step size
nt = 100    # number of time steps
ns = 5      # number of samples

# random initial conditions
x₀ = hcat(rand(ns) .* 2π, rand(ns) .* 2 .- 1)'

# create Simulation instance
sim = Simulation(x₀, Δt, nt)

# run simulation
x = run!(sim)
```
In the first three paragraphs, we import the `Particles` package, set the same parameters as before, and create a `2 × ni` array holding random initial conditions.
Then, we create an instance of `Simulation`, where we pass the initial conditions, time step size and number of time steps.
Note that in the following, the global variables `Δt`, `nt` and `ni` are not used anymore, but only the `sim` value is passed around.
In particular, we pass `sim` to `run!`, which consecutively applies the explicit Euler method `nt` times and returns the results.
After that we can apply the very same plotting code as before.

This script is called by
```shell
julia --project=. scripts/pendulum.jl
```
from the `Particles` directory, or alternatively by
```shell
julia --project=.. pendulum.jl
```
from the `Particles/scripts` directory.
