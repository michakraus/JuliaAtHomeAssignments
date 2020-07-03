
struct Simulation{DT <: Number, IT <: Integrator{DT}}
    int::IT
    nt::Int
    x::Vector{Vector{DT}}

    function Simulation(x₀::Vector{Vector{DT}}, int::IT, nt::Int) where {DT, IT <: Integrator{DT}}
        new{DT,IT}(int, nt, copy(x₀))
    end
end

function Simulation(equ::Equation, integrator::Type{<:Integrator}, Δt::Real, nt::Int; kwargs...)
    int = integrator(equ, Δt; kwargs...)
    Simulation(equ.x₀, int, nt)
end


ndims(sim::Simulation) = ndims(sim.int.equ)
nsamples(sim::Simulation) = nsamples(sim.int.equ)
ntimesteps(sim::Simulation) = sim.nt

eachsample(sim::Simulation) = eachindex(sim.x)
eachtimestep(sim::Simulation) = 1:ntimesteps(sim)


function (sim::Simulation{DT})() where {DT}
    for n in eachtimestep(sim)
        preprocessing(sim.int.equ, sim.x)
        for i in eachsample(sim)
            sim.int(sim.x[i])
        end
        postprocessing(sim.int.equ, sim.x)
    end
end
