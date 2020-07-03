
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
z₀ = [ collect(z) for z in zip(x₀, v₀) ]

# vector field
function lorentz_force!(ż, z, p::PoissonSolver)
    for i in eachindex(ż, z)
        ż[i][1] = z[i][2]
        ż[i][2] = eval_field(p, z[i][1])
    end
end

# create Poisson solver
p = PoissonSolver{eltype(x₀)}(nx)
solve!(p, x₀)

# create an Equation instance with callbacks
equ = Equation((ż, z) -> lorentz_force!(ż, z, p), z₀; f_preproc = z -> solve!(p, reduce(hcat, z)[1,:]))

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
z₀plot = reduce(hcat, z₀)
scatter(mod.(z₀plot[1,:], 1), z₀plot[2,:],
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
# anim = @animate for n in 0:nt
#     scatter(mod.(z[1,:,n], 1), z[2,:,n],
#         marker = 3,
#         xlim = xlim,
#         ylim = vlim,
#         title = "Vlasov-Poisson",
#         legend = false,
#         size = (800, 600)
#     )
# end

# save animation to file
# gif(anim, "vlasov_poisson_anim.gif", fps=10)
