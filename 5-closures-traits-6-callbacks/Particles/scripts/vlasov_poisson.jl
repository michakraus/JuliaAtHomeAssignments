
# import Particles package
using Particles

# import HDF5 package for storing solution
using HDF5

# parameters
Δt = 0.1    # time step size
nt = 200    # number of time steps
np = 10000  # number of particles
nx = 16     # number of grid points

# output file
h5file = "vlasov_poisson.hdf5"

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

# solution storage
function copy_to_hdf5(h5z, z, n)
    h5z[:,:,n+1] = reduce(hcat, z)
end

# create Poisson solver
p = PoissonSolver{eltype(x₀)}(nx)
solve!(p, x₀)

# create an Equation instance with callbacks
equ = Equation((ż, z) -> lorentz_force!(ż, z, p), z₀; f_preproc = z -> solve!(p, reduce(hcat, z)[1,:]))

# create HDF5 file and copy initial conditions
h5  = h5open(h5file, "w")
h5z = d_create(h5, "z", eltype(x₀), ((2, np, nt+1), (2, np, -1)), "chunk", (2,np,1))
copy_to_hdf5(h5z, z₀, 0)

# create Simulation instance
sim = Simulation(equ, ExplicitEuler, Δt, nt; f_postproc = (z, n) -> copy_to_hdf5(h5z, z, n))

# run simulation
try
    z = sim()
finally
    close(h5)
end


# load Plots package
using Plots

# read array from HDF5 file
z = h5read(h5file, "z")

# compute plot ranges
vmax = ceil(maximum(abs.(v₀)))
xlim = (0, 1)
vlim = (-vmax, +vmax)

# plot initial condition
scatter(mod.(z[1,:,1], 1), z[2,:,1],
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
    scatter(mod.(z[1,:,n+1], 1), z[2,:,n+1],
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
