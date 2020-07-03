module Particles

using FFTW
using StatsBase

export Equation, Simulation
export ExplicitEuler
export PoissonSolver, solve!, eval_field

include("equation.jl")
include("integrators.jl")
include("simulation.jl")
include("poisson.jl")

end # module
