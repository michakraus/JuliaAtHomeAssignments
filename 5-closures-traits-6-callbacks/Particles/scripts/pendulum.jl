
# import Particles package
using Particles

# import HDF5 package for storing solution
using HDF5

# parameters
Δt = 0.1    # time step size
nt = 100    # number of time steps
ns = 5      # number of samples

# output file
h5file = "pendulum.hdf5"

# random initial conditions
x₀ = [ [rand() .* 2π, rand() .* 2 .- 1] for i in 1:ns ]

# vector field
function pendulum!(ẋ, x)
    for i in eachindex(ẋ, x)
        ẋ[i][1] = x[i][2]
        ẋ[i][2] = - sin(x[i][1])
    end
end

# solution storage
function copy_to_hdf5(h5x, x, n)
    h5x[:,:,n+1] = reduce(hcat, x)
end

# create an Equation instance
equ = Equation(pendulum!, x₀)

# create HDF5 file and copy initial conditions
h5  = h5open(h5file, "w")
h5x = d_create(h5, "x", eltype(x₀[1]), ((2, ns, nt+1), (2, ns, -1)), "chunk", (2,ns,1))
copy_to_hdf5(h5x, x₀, 0)

# create Simulation instance
sim = Simulation(equ, ExplicitEuler, Δt, nt; f_postproc = (x, n) -> copy_to_hdf5(h5x, x, n))

# run simulation
try
    z = sim()
finally
    close(h5)
end


# load Plots package
using Plots

# read array from HDF5 file
x = h5read(h5file, "x")

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
for i in axes(x,2)
    scatter!(plt, (x[1,i,:] .+ π) .% 2π .- π, x[2,i,:], marker=5)
end

# save figure to file
savefig("pendulum.png")
