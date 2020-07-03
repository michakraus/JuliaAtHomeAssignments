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


find .. -type f -name '.gif' -exec rm {} +
find .. -type f -name '.png' -exec rm {} +
