
# Julia@Home Assignments

## 4. Time-stepping schemes

Implement the possibility to change the time stepping schemes.
Write an abstract integrator type with different concrete sub-types.
Implement a function that integrates one time step and has different methods for different integrators.

Add at least one more time stepping method, e.g., Störmer-Verlet.


### Abstract Integrator

We add a new file `src/integrators.jl` and include it in `src/Particles.jl`:
```julia; eval=false
module Particles

using OffsetArrays

export Equation, Simulation, run!
export ExplicitEuler

include("equation.jl")
include("integrators.jl")
include("simulation.jl")

end
```

Anticipating that we want to add an `ExplicitEuler` integrator, we export it already.

In `src/integrators.jl` we add the abstract type `Integrator{DT}` with one type parameter and the function `integrate_step!` without any method:
```julia; eval=false
abstract type Integrator{DT} end

function integrate_step! end
```
This `integrate_step!` declaration should be used to add generic documentation for this function as there will be many methods, namely one for each integrator.

Every integrator should implement the `integrate_step!` method with the interface
```julia; eval=false
function integrate_step!(int::Integrator, equ::Equation, x₀::AbstractVector, x₁::AbstractVector) end
```
where `x₀` is the previous solution and `x₁` is the new solution.
To make this more explicit, we could add a method
```julia; eval=false
integrate_step!(int::Integrator, equ::Equation, x₀::AbstractVector, x₁::AbstractVector) = error("integrate_step!() not implemented for integrator ", typeof(int))
```
Thus when `integrate_step!` is called for any integrator that does not implement the corresponding method, an error is thrown.

The solution arguments should be `AbstractVector`s instead of `Vector`s as more often than not these will be views on an array rather than an actual array.


### Simulation

In the `Simulation` type we now store an integrator object instead of the time step:
```julia; eval=false
struct Simulation{DT <: Number, ET <: Equation{DT}, IT <: Integrator{DT}}
    equ::ET
    int::IT
    x::OffsetArray{DT,3,Array{DT,3}}

    function Simulation(equ::ET, int::IT, nt::Int) where {DT, ET <: Equation{DT}, IT <: Integrator{DT}}
        x = OffsetArray(zeros(DT, size(equ.x₀)..., nt+1), axes(equ.x₀)..., 0:nt)
        x[:,:,0] .= equ.x₀
        new{DT,ET,IT}(equ, int, x)
    end
end
```
The constructor is modified accordingly.
For the moment, we also store the type of the integrator as type parameter `IT`.
We will discuss this issue in some more detail later on.

In the `run!` function of the `Simulation` we now call the `integrate_step!` function instead implementing a specific integration method:
```julia; eval=false
function run!(sim::Simulation{DT}) where {DT}
    for n in eachtimestep(sim)
        for i in eachsample(sim)
            integrate_step!(sim.int, sim.equ, view(sim.x, :, i ,n-1), view(sim.x, :, i, n))
        end
    end
    return sim.x
end
```
Here, it is important that we pass views of the solution array to the `integrate_step!` function, e.g., in order for the solution of the integration step being copied to the right place.
The naive call
```julia; eval=false       
integrate_step!(sim.int, sim.equ, sim.x[:,i,n-1], sim.x[:,i,n])
```
creates a copy of the slice of the solution array, so that changes would not be stored.
A slightly longer but possibly more explicit alternative to the above implementation is the following:
```julia; eval=false       
x₀ = @view sim.x[:,i,n-1]
x₁ = @view sim.x[:,i,n]
integrate_step!(sim.int, sim.equ, x₀, x₁)
```
With than we can easily choose different integrators in our `Simulation`.


### Explicit Euler Integrator

We can add the `ExplicitEuler` integrator as follows:
```julia; eval=false
struct ExplicitEuler{DT} <: Integrator{DT}
    Δt::DT
    ẋ::Vector{DT}
    
    function ExplicitEuler(equ::Equation{DT}, Δt::DT) where {DT}
        new{DT}(Δt, zeros(DT, ndims(equ)))
    end
end
```
This type should store everything needed to compute one integration step, that is in particular the time step `Δt` (which can now be removed from the `Simulation` type), and a temporary array `ẋ` to store the vector field.
The constructor takes an `Equation`, from which it extracts all relevant information, and the time step.

The `integrate_step!` method for the `ExplicitEuler` integrator is very simple:
```julia; eval=false
function integrate_step!(int::ExplicitEuler, equ::Equation, x₀::AbstractVector, x₁::AbstractVector)
    equ.f(int.ẋ, x₀)
    x₁ .= x₀ .+ int.Δt .* int.ẋ
end
```
It has the aforementioned interface, computes the vector field `ẋ` on the old solution `x₀` and adds it to obtain the new solution `x₁`.


### Discussion

In the design of the interface we made some choices for which there could be alternatives.

All temporary arrays needed to compute a time step either need to be allocated in the `integrate_step!` method (which often induces overhead as this method is called repeatedly) or stored as a field in the corresponding integrator type (as we did above).
The latter choice implies that an integrator instance is tied to a specific `Equation` as the size of e.g. the temporary vector that holds the vector field depends on the equation.
Therefore one could argue that the `Equation` instance should be a field in the `Integrator` rather than the `Simulation`.
Going one step further, we might not want to store the `Equation` in `Integrator` but only the vector field function `f`.

The way we implemented the `run!` function does not directly access the `equ` or `int` field of the `Simulation`. 
If this is also true elsewhere, there is no need to store the equation and integrator types and the `Simulation` type can be simplified as follows:
```julia; eval=false
struct Simulation{DT <: Number}
    equ
    int
    x::OffsetArray{DT,3,Array{DT,3}}

    function Simulation(equ::ET, int::IT, nt::Int) where {DT, ET <: Equation{DT}, IT <: Integrator{DT}}
        x = OffsetArray(zeros(DT, size(equ.x₀)..., nt+1), axes(equ.x₀)..., 0:nt)
        x[:,:,0] .= equ.x₀
        new{DT}(equ, int, x)
    end
end
```
As the integrator and equation are not explicitly being used except for being passed to the `integrate_step!` function, there is no need to store their type.
When `integrate_step!` is called, Julia can automatically determine the corresponding types and generate optimised code specific to those types.
The crucial point is, that `integrate_step!` does not operate on a `Simulation` instance but on instances of `Integrator` and `Equation`.
The situation is different for the solution array `x`: as the `run!` function directly operates on this field of `Simulation` its type needs to be fully specified.

Note that the above version of `Simulation` still enforces that the solution array, the initial conditions equation and the time step in the integrator all use the same data type (as it is enforced in the constructor).
