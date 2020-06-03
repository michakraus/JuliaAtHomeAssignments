
# Julia@Home Assignments

## 3. Equations

Implement the possibility to change the equation, i.e. write an `Equation` type that stores the functions providing the vector fields and initial conditions.

Implement a simulation for `n` independent charged particles in some prescribed electromagnetic field:
$$
\dot{x} = v , \quad
\dot{v} = E (x) + v \times B(x) .
$$


### Charged Particle Dynamics

Now we have all the functionality we need in order to add another example.
We create a new file `scripts/charged_particles.jl` where all the problem-specific functionality is implemented.
First we need to implement a function that computes the Lorentz force, and to that end we need functions that provide electric and magnetic fields.
For the magnetic field, we use a simple Theta-pinch with $B = (0,0,1)$ and an oscillating electric field $E = (0, 0, \cos (2\pi z)$.
Other than changing the vector field and adapting the initial conditions, the script is the same as for the pendulum example:
```julia; eval=false
# import Particles package
using Particles

# parameters
Δt = 0.1    # time step size
nt = 100    # number of time steps
ni = 5      # number of initial conditions

# random initial conditions
x₀ = hcat(rand(ni) .* 2 .- 1, rand(ni) .* 2 .- 1, zeros(ni), rand(ni) .- 0.5, rand(ni) .- 0.5, ones(ni))'

# electric field
E(x::Vector{DT}) where {DT} = [zero(DT), zero(DT), cos(2π*x[3])]

# magnetic field
B(x::Vector{DT}) where {DT} = [zero(DT), zero(DT), one(DT)]

# vector field
function lorentz_force!(ż, z)
    x = z[1:3]
    v = z[4:6]

    e = E(x)
    b = B(x)

    ż[1] = v[1]
    ż[2] = v[2]
    ż[3] = v[3]

    ż[4] = e[1] + v[2] * b[3] - v[3] * b[2]
    ż[5] = e[2] + v[3] * b[1] - v[1] * b[3]
    ż[6] = e[3] + v[1] * b[2] - v[2] * b[1]
end

# create an Equation instance
equ = Equation(lorentz_force!, x₀)

# create Simulation instance
sim = Simulation(equ, Δt, nt)

# run simulation
x = run!(sim)
```

The plotting part is adapted to visualise the 3d particle trajectories:
```julia; eval=false
# load Plots package
using Plots

# set plot ranges
xlim = (-2, +2)
ylim = (-2, +2)
zlim = ( 0, 20)

# create empty 3d plot with ni empty series
plt = plot3d(
    ni,
    xlim = xlim,
    ylim = ylim,
    zlim = zlim,
    title = "Charged Particles",
    legend = false,
    marker=5,
    size = (800, 600)
)

# plot solutions
for j in axes(x,3)
    for i in 1:ni
        push!(plt, i, x[1,i,j], x[2,i,j], x[3,i,j])
    end
end

# save figure to file
savefig("charged_particles.png")
```
