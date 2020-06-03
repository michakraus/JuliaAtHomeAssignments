
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
for i in 1:ns
    scatter!(plt, (x[1,i,:] .+ π) .% 2π .- π, x[2,i,:], marker=5)
end

# save figure to file
savefig("pendulum.png")
