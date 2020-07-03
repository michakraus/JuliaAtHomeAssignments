
# import Particles package
using Particles

# parameters
Δt = 0.1    # time step size
nt = 100    # number of time steps
ns = 5      # number of samples

# random initial conditions
x₀ = hcat(rand(ns) .* 2π, rand(ns) .* 2 .- 1)'

# vector field
function pendulum!(ẋ, x)
    ẋ[1] = x[2]
    ẋ[2] = - sin(x[1])
end

# create an Equation instance
equ = Equation(pendulum!, x₀)

# create Simulation instance
sim = Simulation(equ, ExplicitEuler, Δt, nt)

# run simulation
x = sim()

# load Plots package
using Plots

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
