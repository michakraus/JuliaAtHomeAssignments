
# Julia@Home Assignments

## 3. Equations

Implement the possibility to change the equation, i.e. write an `Equation` type that stores the functions providing the vector fields and initial conditions.

Implement a simulation for `n` independent charged particles in some prescribed electromagnetic field:
$$
\dot{x} = v , \quad
\dot{v} = E (x) + v \times B(x) .
$$


### Vector Field Functions

As a first step, we separate the vector field from the integrator in the `run!` function.
To this end, we extend the `Simulation` by a field `f` that stores the vector field function:
```julia; eval=false
struct Simulation{DT <: Number, FT <: Function}
    Δt::DT
    f::FT
    x::OffsetArray{DT,3,Array{DT,3}}

    function Simulation(f::FT, x₀::AbstractArray{DT,2}, Δt::DT, nt::Int) where {DT, FT}
        x = OffsetArray(zeros(DT, size(x₀)..., nt+1), axes(x₀)..., 0:nt)
        x[:,:,0] .= x₀
        new{DT,FT}(Δt, f, x)
    end
end
```
Here, it is important to also store the type of the function `f` as a type parameter `FT`.
Note that the type of `f` is not `Function`, but a subtype thereof.

Next we implement a `pendulum!` function in `scripts/pendulum.jl` that takes two arguments `(ẋ, x)` and computes the vector field:
```julia; eval=false
function pendulum!(ẋ, x)
    ẋ[1] = x[2]
    ẋ[2] = - sin(x[1])
end
```
The first argument, `ẋ`, holds the output vector, i.e., the vector field. The second vector, `x`, holds the current state vector of the system.
This function is then passed to the `Simulation` constructor:
```julia; eval=false
sim = Simulation(pendulum!, x₀, Δt, nt)
```

Before we adapt the `run!` function to work on generic vector fields, let us add another convenience function that returns the length of the state vector:
```julia; eval=false
ndims(sim::Simulation) = lastindex(sim.x,1)
```

We need this to create a temporary array in `run!`, that holds the vector field:
```julia; eval=false
function run!(sim::Simulation{DT}) where {DT}
    ẋ = zeros(DT, ndims(sim))
    for n in eachtimestep(sim)
        for i in eachic(sim)
            sim.f(ẋ, sim.x[:,i,n-1])
            sim.x[:,i,n] .= sim.x[:,i,n-1] .+ sim.Δt .* ẋ
        end
    end
    return sim.x
end
```
Here we also need the solution data type, i.e., the `DT` parameter of the `Simulation` type, in order to instantiate the temporary vector field vector.
Note that we do not need to declare the vector field function type `FT` as function parameter in order to obtain optimised code. `FT` being specified as type parameter is sufficient.
In the loop, we evaluate the vector field function, that is stored in the `f` field of the `Simulation` type.

With that, we can prescribe arbitrary vector fields and are not restricted to the equation of the pendulum.
However, as an initial value problem is characterised not only by its vector field but also by its initial condition, it seems worthwhile to abstract this concept into a separate `Equation` type.
