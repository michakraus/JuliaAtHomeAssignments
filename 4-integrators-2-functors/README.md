
# Julia@Home Assignments

## 4. Time-stepping schemes

### Discussion

In the design of the interface we made some choices for which there could be alternatives.

All temporary arrays needed to compute a time step either need to be allocated in the `integrate_step!` method (which often induces overhead as this method is called repeatedly) or stored as a field in the corresponding integrator type (as we did above).
The latter choice implies that an integrator instance is tied to a specific `Equation` as the size of e.g. the temporary vector that holds the vector field depends on the equation.
Therefore one could argue that the `Equation` instance should be a field in the `Integrator` rather than the `Simulation`.
Going one step further, we might not want to store the `Equation` in `Integrator` but only the vector field function `f`.


### Refactoring

We move the equation field from `Simulation` to `Equation`
```julia; eval=false
struct ExplicitEuler{DT, ET <: Equation{DT}} <: Integrator{DT}
    equ::ET
    Δt::DT
    ẋ::Vector{DT}
    
    function ExplicitEuler(equ::ET, Δt::DT) where {DT, ET <: Equation{DT}}
        new{DT,ET}(equ, Δt, zeros(DT, ndims(equ)))
    end
end
```

```julia; eval=false
struct Simulation{DT <: Number, IT <: Integrator{DT}}
    int::IT
    x::OffsetArray{DT,3,Array{DT,3}}

    function Simulation(x₀::AbstractArray{DT}, int::IT,
                        nt::Int) where {DT, IT <: Integrator{DT}}
        x = OffsetArray(zeros(DT, size(x₀)..., nt+1), axes(x₀)..., 0:nt)
        x[:,:,0] .= x₀
        new{DT,IT}(int, x)
    end
end

function Simulation(equ::Equation, integrator::Type{<:Integrator},
                    Δt::Real, nt::Int; kwargs...)
    int = integrator(equ, Δt; kwargs...)
    Simulation(equ.x₀, int, nt)
end
```
Here, we added a convenience constructor for `Simulation` that takes an `Integrator` type and creates both the integrator and the simulation; the `kwargs...` argument allows to pass integrator-specific parameters to the corresponding constructor

In the example scripts, e.g. `scripts/pendulum.jl` the construction of the integrator and simulation is changed from
```julia; eval=false
# create an Equation instance
equ = Equation(pendulum!, x₀)

# create an Integrator instance
int = ExplicitEuler(equ, Δt)

# create Simulation instance
sim = Simulation(equ, int, nt)
```
to
```julia; eval=false
# create an Equation instance
equ = Equation(pendulum!, x₀)

# create Simulation instance
sim = Simulation(equ, ExplicitEuler, Δt, nt)
```


### Functors

To streamline the interface a bit more we could also add functors for both the `Simulation` and the `Integrator`s.
The `run!` function could be replaced with 
```julia; eval=false
function (sim::Simulation{DT})() where {DT}
    for n in eachtimestep(sim)
        for i in eachsample(sim)
            @views integrate_step!(sim.int, sim.equ, sim.x[:,i,n-1], sim.x[:,i,n])
        end
    end
    return sim.x
end
```
This allows to run a simulation via
```julia; eval=false
sim()
```
instead of
```julia; eval=false
run!(sim)
```

Similarly, we could have the following functor instead of `integrate_step!`:
```julia; eval=false
function (int::Integrator)(x₀::AbstractVector, x₁::AbstractVector)
```
which would be called by
```julia; eval=false
int(x₀, x₁)
```

This is particularly elegant since we store the `Equation` in the `Integrator`.
