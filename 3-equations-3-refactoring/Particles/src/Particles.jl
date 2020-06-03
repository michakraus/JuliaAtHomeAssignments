module Particles

using OffsetArrays

export Equation, Simulation, run!

include("equation.jl")
include("simulation.jl")

end # module
