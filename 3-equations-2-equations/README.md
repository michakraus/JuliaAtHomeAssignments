
# Julia@Home Assignments

## 3. Equations

Implement the possibility to change the equation, i.e. write an `Equation` type that stores the functions providing the vector fields and initial conditions.

Implement a simulation for `n` independent charged particles in some prescribed electromagnetic field:
$$
\dot{x} = v , \quad
\dot{v} = E (x) + v \times B(x) .
$$


### The Equation Type

In order to add the `Equation` type, create a new file `src/equation.jl`, include it in the `Particles` module and export `Equation`:
```julia; eval=false
module Particles

using OffsetArrays

export Equation, Simulation, run!

include("equation.jl")
include("simulation.jl")

end
```

The `Equation` type is just a container for the vector field `f` and the initial condition `x₀`:
```julia; eval=false
struct Equation{DT <: Number, FT <: Function}
    f::FT
    x₀::Array{DT,2}

    function Equation(f::FT, x₀::AbstractArray{DT,2}) where {DT, FT}
        new{DT,FT}(f, convert(Array{DT,2}, x₀))
    end
end
```
In the constructor we allow `x₀` to be a abstract array, however, we store is as standard array and, if necessary, convert it when calling `new`.

In the Simulation, we now store the equation instead of the vector field:
```julia; eval=false
struct Simulation{DT <: Number, FT <: Function}
    Δt::DT
    equ::Equation{DT,FT}
    x::OffsetArray{DT,3,Array{DT,3}}

    function Simulation(equ::Equation{DT,FT}, Δt::DT, nt::Int) where {DT, FT}
        x = OffsetArray(zeros(DT, size(equ.x₀)..., nt+1), axes(equ.x₀)..., 0:nt)
        x[:,:,0] .= equ.x₀
        new{DT,FT}(Δt, equ, x)
    end
end
```
In general, we still have to store the vector field function type as a type parameter in order to obtain optimised code.
Alternatively, we can just store the equation type as type parameter
```julia; eval=false
struct Simulation{DT <: Number, ET <: Equation{DT}}
    Δt::DT
    equ::ET
    x::OffsetArray{DT,3,Array{DT,3}}

    function Simulation(equ::ET, Δt::DT, nt::Int) where {DT, ET <: Equation{DT}}
        x = OffsetArray(zeros(DT, size(equ.x₀)..., nt+1), axes(equ.x₀)..., 0:nt)
        x[:,:,0] .= equ.x₀
        new{DT,ET}(Δt, equ, x)
    end
end
```
Which version is preferable depends on the situation. The first version is more explicit and somewhat stricter, however, propagation of the types of some member field's inner data structures can pollute the type parameters of outer types, especially in composition-rich codes.
We will see later on, that storing these types is not always strictly necessary.

The `run!` method is only mildly change, namely calling `sim.equ.f` instead of `sim.f`:
```julia; eval=false
function run!(sim::Simulation{DT}) where {DT}
    ẋ = zeros(DT, ndims(sim))
    for n in eachtimestep(sim)
        for i in eachic(sim)
            sim.equ.f(ẋ, sim.x[:,i,n-1])
            sim.x[:,i,n] .= sim.x[:,i,n-1] .+ sim.Δt .* ẋ
        end
    end
    return sim.x
end
```
