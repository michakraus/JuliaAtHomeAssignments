
# Julia@Home Assignments

## 2. Pendulum

Implement a simulation for `n` independent pendula:
$$
\dot{x} = v , \quad
\dot{v} = - \sin(x) .
$$


### Quick and dirty script

The quickest way of solving this problem is to write a short script:
```julia
# parameters
Δt = 0.1    # time step size
nt = 100    # number of time steps
ns = 5      # number of samples

# solution array
x = zeros(2,ns,nt+1)

# random initial conditions
x[1,:,1] .= rand(ns) .* 2π
x[2,:,1] .= rand(ns) .* 2 .- 1

# run simulation with explicit Euler
for n in 1:nt
    for i in 1:ns
        x[1,i,n+1] = x[1,i,n] + Δt * x[2,i,n]
        x[2,i,n+1] = x[2,i,n] - Δt * sin(x[1,i,n])
    end
end
```

The results can be visualised with *Plots.jl*
```julia
# load Plots package
using Plots

# select backend (default: GR)
plotlyjs()

# set plot ranges
xlim = (-π, +π)
ylim = (-3, +3)

# plot energy contour lines
plt = contour(
    LinRange(xlim..., 100),
    LinRange(ylim..., 100),
    (x,v) -> v^2 / 2  + 1 - cos(x),
    xlim = xlim,
    ylim = ylim,
    title = "Pendulum",
    legend = false,
    size = (800, 600)
)

# plot solutions
for i in 1:ns
    scatter!(plt, (x[1,i,:] .+ π) .% 2π .- π, x[2,i,:], marker=5)
end

# save figure to file
savefig("pendula.png")
```

The script is stored in the folder `prototyping/pendulum.jl`.


### Limitations

While this script does the job, it does have several issues and limitations:
- We are using global variables, preventing Julia from generating efficient, optimised code.
- We hardcoded the integration scheme and the vector field of the equation, none of which can be easily changed.
- More generally speaking, none of the code we have written is not really resusable in any sane way.

There are also some minor annoyances:
- The indexing of our solution array starts at `1` although here `0` would be much more natural, with the index-0 entry storing the initial condition.


The optimisation issue could be remedied by putting `const` in front of the parameter names. However, it seems better practice to put all parameters and simulation-relevant data structures into a `struct` which we will call `Simulation`.

The integrator and the vector field can be provided by individual functions, which can be stored in the `Simulation` composite type so they can be replaced easily.

These measures will lead to a better code structure and code that can easily be reused later on.

To resolve the indexing issue, we will use an `OffsetArray` instead of a vanilla array.
