
# import Particles package
using Particles

# parameters
Δt = 0.1    # time step size
nt = 100    # number of time steps
ns = 5      # number of samples

# random initial conditions
x₀ = [ [rand() .* 2 .- 1, rand() .* 2 .- 1, 0, rand() .- 0.5, rand() .- 0.5, 1] for i in 1:ns ]

# electric field
E(x::Vector{DT}) where {DT} = DT[0, 0, cos(2π*x[3])]

# magnetic field
B(x::Vector{DT}) where {DT} = DT[0, 0, 1]

# vector field
function lorentz_force!(ż, z)
    for i in eachindex(ż, z)
        x = z[i][1:3]
        v = z[i][4:6]

        e = E(x)
        b = B(x)

        ż[i][1] = v[1]
        ż[i][2] = v[2]
        ż[i][3] = v[3]

        ż[i][4] = e[1] + v[2] * b[3] - v[3] * b[2]
        ż[i][5] = e[2] + v[3] * b[1] - v[1] * b[3]
        ż[i][6] = e[3] + v[1] * b[2] - v[2] * b[1]
    end
end

# create an Equation instance
equ = Equation(lorentz_force!, x₀)

# create Simulation instance
sim = Simulation(equ, ExplicitEuler, Δt, nt)

# run simulation
x = sim()


# load Plots package
# using Plots

# set plot ranges
# xlim = (-2, +2)
# ylim = (-2, +2)
# zlim = ( 0, 20)

# create empty 3d plot with ns empty series
# plt = plot3d(
#     ns,
#     xlim = xlim,
#     ylim = ylim,
#     zlim = zlim,
#     title = "Charged Particles",
#     legend = false,
#     marker = 5,
#     size = (800, 600)
# )

# plot solutions
# for j in axes(x,3)
#     for i in axes(x,2)
#         push!(plt, i, x[1,i,j], x[2,i,j], x[3,i,j])
#     end
# end

# save figure to file
# savefig("charged_particles.png")
