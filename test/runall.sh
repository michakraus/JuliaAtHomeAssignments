#!/bin/bash

julia --project=../2-pendulum-1-script/Particles ../2-pendulum-1-script/Particles/prototyping/pendulum.jl

julia --project=../2-pendulum-2-simulation/Particles ../2-pendulum-2-simulation/Particles/scripts/pendulum.jl

julia --project=../2-pendulum-3-simulation-offsetarrays/Particles ../2-pendulum-3-simulation-offsetarrays/Particles/scripts/pendulum.jl

julia --project=../2-pendulum-4-simulation-revised/Particles ../2-pendulum-4-simulation-revised/Particles/scripts/pendulum.jl

julia --project=../3-equations-1-vector-fields/Particles ../3-equations-1-vector-fields/Particles/scripts/pendulum.jl

julia --project=../3-equations-2-equations/Particles ../3-equations-2-equations/Particles/scripts/pendulum.jl

julia --project=../3-equations-3-refactoring/Particles ../3-equations-3-refactoring/Particles/scripts/pendulum.jl

julia --project=../3-equations-4-charged-particles/Particles ../3-equations-4-charged-particles/Particles/scripts/pendulum.jl
julia --project=../3-equations-4-charged-particles/Particles ../3-equations-4-charged-particles/Particles/scripts/charged_particles.jl

julia --project=../4-integrators-1-integrators/Particles ../4-integrators-1-integrators/Particles/scripts/pendulum.jl
julia --project=../4-integrators-1-integrators/Particles ../4-integrators-1-integrators/Particles/scripts/charged_particles.jl

julia --project=../4-integrators-2-functors/Particles ../4-integrators-2-functors/Particles/scripts/pendulum.jl
julia --project=../4-integrators-2-functors/Particles ../4-integrators-2-functors/Particles/scripts/charged_particles.jl

julia --project=../5-closures-traits-1-poisson/Particles ../5-closures-traits-1-poisson/Particles/scripts/pendulum.jl
julia --project=../5-closures-traits-1-poisson/Particles ../5-closures-traits-1-poisson/Particles/scripts/charged_particles.jl
julia --project=../5-closures-traits-1-poisson/Particles ../5-closures-traits-1-poisson/Particles/scripts/vlasov_poisson.jl

julia --project=../5-closures-traits-2-closures/Particles ../5-closures-traits-2-closures/Particles/scripts/vlasov_poisson.jl
julia --project=../5-closures-traits-2-closures/Particles ../5-closures-traits-2-closures/Particles/scripts/pendulum.jl
julia --project=../5-closures-traits-2-closures/Particles ../5-closures-traits-2-closures/Particles/scripts/charged_particles.jl

julia --project=../5-closures-traits-3-traits/Particles ../5-closures-traits-3-traits/Particles/scripts/vlasov_poisson.jl
julia --project=../5-closures-traits-3-traits/Particles ../5-closures-traits-3-traits/Particles/scripts/pendulum.jl
julia --project=../5-closures-traits-3-traits/Particles ../5-closures-traits-3-traits/Particles/scripts/charged_particles.jl

julia --project=../5-closures-traits-4-refactoring-1/Particles ../5-closures-traits-4-refactoring-1/Particles/scripts/vlasov_poisson.jl
julia --project=../5-closures-traits-4-refactoring-1/Particles ../5-closures-traits-4-refactoring-1/Particles/scripts/pendulum.jl
julia --project=../5-closures-traits-4-refactoring-1/Particles ../5-closures-traits-4-refactoring-1/Particles/scripts/charged_particles.jl

julia --project=../5-closures-traits-5-refactoring-2/Particles ../5-closures-traits-5-refactoring-2/Particles/scripts/vlasov_poisson.jl
julia --project=../5-closures-traits-5-refactoring-2/Particles ../5-closures-traits-5-refactoring-2/Particles/scripts/pendulum.jl
julia --project=../5-closures-traits-5-refactoring-2/Particles ../5-closures-traits-5-refactoring-2/Particles/scripts/charged_particles.jl

julia --project=../5-closures-traits-6-callbacks/Particles ../5-closures-traits-6-callbacks/Particles/scripts/vlasov_poisson.jl
julia --project=../5-closures-traits-6-callbacks/Particles ../5-closures-traits-6-callbacks/Particles/scripts/pendulum.jl
julia --project=../5-closures-traits-6-callbacks/Particles ../5-closures-traits-6-callbacks/Particles/scripts/charged_particles.jl


find .. -type f -name '.gif' -exec rm {} +
find .. -type f -name '.png' -exec rm {} +
find .. -type f -name '.hdf5' -exec rm {} +
