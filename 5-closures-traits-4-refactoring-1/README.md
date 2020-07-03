
# Julia@Home Assignments

## 5. Traits and Closures

### Discussion

With the current structure of the code, certain callback functionality cannot be implemented via the pre-/post-processing infrastructure.
In particular, if we consider Runge-Kutta or splitting methods, we might want to update the electrostatic potential at the beginning or end of each stage or substep.
While it is easy to call the pre- and post-processing functions in the integrator instead of the simulation, our current solution structure and the way the simulation works prevents us from updating the potential in the integrator.
Only the state of one single particle is ever passed to the integrator but we need all particles to compute the electrostatic potential; therefore, we need to modify our data structure, pass the data for all particles and integrate all particles. This implies that either the integrator has to take care of looping over particles or the vector field function has to provide the vector field for all particles at once.

Which of the two solutions is preferred depends on the primary purpose of the code:
    - the first case might make sense if we write a dedicated particle-in-cell enginge,
    - the second case is preferred if we write a general ode solver that is also used for pic simulations, as it is more general,
    - remark: in the first case there also is the drawback that one has to implement the looping over particles, etc., for each integrator, over and over again, and it is less flexible w.r.t. generalisations, e.g., towards advancing both particles and fields.


### Refactoring

We want to restructure and refactor our code in the following ways:
    - in the simulation, store only the current state of the system instead of its whole history,
    - store the solution as vector of vectors, where elements of the enclosing vector correspond to particles and elements of the inner vector represent a particle's phasespace position,
    - compute the vector-field for all particles at once,
    - add pre- and post-processing callbacks also to the simulation in order to allow for plotting and storing the solution to disk.

In the simulation, store only the current state of the system as vector of vectors:
```julia
struct Simulation{DT <: Number, IT <: Integrator{DT}}
    int::IT
    nt::Int                    ### explicitly store number of time steps ###
    x::Vector{Vector{DT}}

    function Simulation(x₀::AbstractArray{DT}, int::IT, nt::Int) where {DT,
                                                            IT <: Integrator{DT}}
        new{DT,IT}(int, nt, copy(x₀))
    end
end

function Simulation(equ::Equation, integrator::Type{<:Integrator},
                    Δt::Real, nt::Int; kwargs...)
    int = integrator(equ, Δt; kwargs...)
    Simulation(equ.x₀, int, nt)
end

ndims(sim::Simulation) = ndims(sim.int.equ)
nsamples(sim::Simulation) = nsamples(sim.int.equ)
ntimesteps(sim::Simulation) = sim.nt
eachsample(sim::Simulation) = eachindex(sim.x)
eachtimestep(sim::Simulation) = 1:ntimesteps(sim)

function (sim::Simulation{DT})() where {DT}
    for n in eachtimestep(sim)
        preprocessing(sim.int.equ, sim.x)
        for i in eachsample(sim)
            sim.int(sim.x[i])    ### no views necessary ###
        end
        postprocessing(sim.int.equ, sim.x)
    end
    return sim.x
end
```

The integrators are hardly changed (except for accepting only one argument and updating in place):
```julia
struct ExplicitEuler{DT, ET <: Equation{DT}} <: Integrator{DT}
    equ::ET
    Δt::DT
    ẋ::Vector{DT}
    
    function ExplicitEuler(equ::ET, Δt::DT) where {DT, ET <: Equation{DT}}
        new{DT,ET}(equ, Δt, zeros(DT, ndims(equ)))
    end
end

function (int::ExplicitEuler)(x::AbstractVector)
    int.equ.f(int.ẋ, x)
    x .+= int.Δt .* int.ẋ
end
```

We need to change the initialisation in our sample scripts:
in `scripts/pendulum.jl` (and analogous in `scripts/charged_particles.jl`) from 
```julia
x₀ = hcat(rand(ns) .* 2π, rand(ns) .* 2 .- 1)'
```
to
```julia
x₀ = [ [rand() .* 2π, rand() .* 2 .- 1] for i in 1:ns ]
```
and in `scripts/vlasov-poisson.jl` from 
```julia
# random initial conditions
x₀ = randn(np)
v₀ = randn(np)

# [...]

# concatenate x₀ and v₀
z₀ = hcat(x₀, v₀)'
```
to
```julia
# random initial conditions
x₀ = randn(np)
v₀ = randn(np)

# [...]

# concatenate x₀ and v₀
z₀ = [ collect(z) for z in zip(x₀, v₀) ]
```
