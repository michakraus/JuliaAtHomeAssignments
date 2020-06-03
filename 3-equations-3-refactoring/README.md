
# Julia@Home Assignments

## 3. Equations

Implement the possibility to change the equation, i.e. write an `Equation` type that stores the functions providing the vector fields and initial conditions.

Implement a simulation for `n` independent charged particles in some prescribed electromagnetic field:
$$
\dot{x} = v , \quad
\dot{v} = E (x) + v \times B(x) .
$$


### Refactoring

Before we proceed, we perform a little bit of refactoring, that will become useful later on.
We implemented some convenience functions for the `Simulation` type, that return the number of time steps, samples, etc.. 
Some of these functions should rather be implemented for the `Equation` type, specifically,
```julia; eval=false
ndims(equ::Equation) = length(axes(equ.x₀,1))
nsamples(equ::Equation) = length(axes(equ.x₀,2))
```

As these functions make also sense when applied to a `Simulation` instance, we do not remove the corresponding methods, but change them to
```julia; eval=false
ndims(sim::Simulation) = ndims(sim.equ)
nsamples(sim::Simulation) = nsamples(sim.equ)
```
This is a typical example of how composition is used in Julia.
