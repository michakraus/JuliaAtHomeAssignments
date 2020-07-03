module Particles

using OffsetArrays

export Equation, Simulation
export ExplicitEuler

include("equation.jl")
include("integrators.jl")
include("simulation.jl")

end # module
