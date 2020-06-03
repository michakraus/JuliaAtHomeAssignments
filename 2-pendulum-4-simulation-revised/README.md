
# Julia@Home Assignments

## 2. Pendulum

### The Simulation Type Revised

#### Convenience Functions

So far, we store the total number of time steps in the simulation type. This is redundant information as the number of time steps is also encoded in the size of the solution array.
We can eliminate the `nt` field without cluttering our code by adding a function that returns the number of time steps, and while we are at it, we do the same for the number of samples:
```julia; eval=false
ntimesteps(sim::Simulation) = lastindex(sim.x,3)
nsamples(sim::Simulation) = lastindex(sim.x,2)
```

With this, we can remove the `nt` field from `Simulation`:
```julia; eval=false
struct Simulation{DT <: Number}
    Δt::DT
    x::OffsetArray{DT,3,Array{DT,3}}

    function Simulation(x₀::AbstractArray{DT,2}, Δt::DT, nt::Int) where {DT}
        x = OffsetArray(zeros(DT, size(x₀)..., nt+1), axes(x₀)..., 0:nt)
        x[:,:,0] .= x₀
        new{DT}(Δt, x)
    end
end
```

The loops in the `run!` functions needs to be modified accordingly:
```julia; eval=false
function run!(sim::Simulation)
    for n in 1:ntimesteps(sim)
        for i in 1:nscs(sim)
            sim.x[1,i,n] = sim.x[1,i,n-1] + sim.Δt * sim.x[2,i,n-1]
            sim.x[2,i,n] = sim.x[2,i,n-1] - sim.Δt * sin(sim.x[1,i,n-1])
        end
    end
    return sim.x
end
```

We can add two more convenience functions in analogy to Julia's `eachindex` function: 
```julia; eval=false
eachtimestep(sim::Simulation) = axes(sim.x,3)[1:end]
eachsample(sim::Simulation) = axes(sim.x,2)
```

Then the `run!` function can be written as 
```julia; eval=false
function run!(sim::Simulation)
    for n in eachtimestep(sim)
        for i in eachsample(sim)
            sim.x[1,i,n] = sim.x[1,i,n-1] + sim.Δt * sim.x[2,i,n-1]
            sim.x[2,i,n] = sim.x[2,i,n-1] - sim.Δt * sin(sim.x[1,i,n-1])
        end
    end
    return sim.x
end
```

