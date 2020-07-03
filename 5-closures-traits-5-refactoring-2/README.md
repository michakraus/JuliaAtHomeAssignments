
# Julia@Home Assignments

## 5. Traits and Closures

### Further Refactoring

We change the integrator to update the whole particle vector at once
```julia
struct ExplicitEuler{DT, ET <: Equation{DT}} <: Integrator{DT}
    equ::ET
    Δt::DT
    ẋ::Vector{Vector{DT}}
    
    function ExplicitEuler(equ::ET, Δt::DT) where {DT, ET <: Equation{DT}}
        ẋ = [ zeros(DT, ndims(equ)) for i in 1:nsamples(equ) ]
        new{DT,ET}(equ, Δt, ẋ)
    end
end
```

Unfortunately, the `zero` function cannot be applied to vectors of vectors thus initialisation of the temporary vector `ẋ` is somewhat tedious. However, arithmetic operations and the dot notation work in the expected way for vectors of vectors. Thus nothing changes in the integrator functor, except that we move the pre- and post-processing calls from the simulation functor:
```julia
function (int::ExplicitEuler)(x::AbstractVector)
    preprocessing(int.equ, x)
    int.equ.f(int.ẋ, x)
    x .+= int.Δt .* int.ẋ
    postprocessing(int.equ, x)
end
```
```julia
function (sim::Simulation{DT})() where {DT}
    for n in eachtimestep(sim)
        sim.int(sim.x)
    end
end
```

We need to adapt our vector field functions:
for `scripts/charged_particles.jl`:
```julia
function lorentz_force!(ż, z)
    for i in eachindex(ż, z)
        x = z[i][1:3]
        v = z[i][4:6]

        e = E(x)
        b = B(x)

        ż[i][1] = v[1]
        ż[i][2] = v[2]
        ż[i][3] = v[3]

        ż[i][4] = e[1] + v[2] * b[3] - v[3] * b[2]
        ż[i][5] = e[2] + v[3] * b[1] - v[1] * b[3]
        ż[i][6] = e[3] + v[1] * b[2] - v[2] * b[1]
    end
end
```
and for  `scripts/vlasov_poisson.jl`:
```julia
function lorentz_force!(ż, z, p::PoissonSolver)
    for i in eachindex(ż, z)
        ż[i][1] = z[i][2]
        ż[i][2] = eval_field(p, z[i][1])
    end
end
```
