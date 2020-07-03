module Particles

using OffsetArrays

export Equation, Simulation, run!
export ExplicitEuler

include("equation.jl")
include("integrators.jl")
include("simulation.jl")

end # module
