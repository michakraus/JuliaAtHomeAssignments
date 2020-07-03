
# import Particles package
using Particles

# parameters
Δt = 0.1    # time step size
nt = 200    # number of time steps
np = 10000  # number of particles
nx = 16     # number of grid points

# random initial conditions
x₀ = randn(np)
v₀ = randn(np)

# shift x₀ to the interval [0,1]
xmax = ceil(maximum(abs.(x₀)))
x₀ .+= xmax
x₀ ./= 2*xmax

# concatenate x₀ and v₀
z₀ = hcat(x₀, v₀)'

# vector field
function lorentz_force!(ż, z, p::PoissonSolver)
    ż[1] = z[2]
    ż[2] = eval_field(p, z[1])
end

# create Poisson solver
p = PoissonSolver{eltype(z₀)}(nx)
solve!(p, x₀)

# create an Equation instance
equ = Equation((ż, z) -> lorentz_force!(ż, z, p), z₀)

# create Simulation instance
sim = Simulation(equ, ExplicitEuler, Δt, nt)

# run simulation
z = sim()


# load Plots package
using Plots

# compute plot ranges
vmax = ceil(maximum(abs.(v₀)))
xlim = (0, 1)
vlim = (-vmax, +vmax)

# plot initial condition
scatter(mod.(z[1,:,0], 1), z[2,:,0],
        marker = 3,
        xlim = xlim,
        ylim = vlim,
        title = "Vlasov-Poisson",
        legend = false,
        size = (800, 600)
)

# save figure to file
savefig("vlasov_poisson_z₀.png")


# create animation
anim = @animate for n in 0:nt
    scatter(mod.(z[1,:,n], 1), z[2,:,n],
        marker = 3,
        xlim = xlim,
        ylim = vlim,
        title = "Vlasov-Poisson",
        legend = false,
        size = (800, 600)
    )
end

# save animation to file
gif(anim, "vlasov_poisson_anim.gif", fps=10)
