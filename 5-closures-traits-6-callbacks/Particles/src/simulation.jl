
struct Simulation{DT <: Number, IT <: Integrator{DT}, FPRE <: Union{Function,Nothing}, FPOST <: Union{Function,Nothing}}
    int::IT
    nt::Int

    f_pre::FPRE
    f_post::FPOST

    x::Vector{Vector{DT}}

    function Simulation(x₀::Vector{Vector{DT}}, int::IT, nt::Int, f_preproc::FPRE, f_postproc::FPOST) where {DT, IT <: Integrator{DT}, FPRE, FPOST}
        new{DT, IT, FPRE, FPOST}(int, nt, f_preproc, f_postproc, copy(x₀))
    end
end

function Simulation(equ::Equation, integrator::Type{<:Integrator}, Δt::Real, nt::Int; f_preproc=nothing, f_postproc=nothing, kwargs...)
    int = integrator(equ, Δt; kwargs...)
    Simulation(equ.x₀, int, nt, f_preproc, f_postproc)
end


ndims(sim::Simulation) = ndims(sim.int.equ)
nsamples(sim::Simulation) = nsamples(sim.int.equ)
ntimesteps(sim::Simulation) = sim.nt

eachsample(sim::Simulation) = eachindex(sim.x)
eachtimestep(sim::Simulation) = 1:ntimesteps(sim)


haspreprocessing(::Simulation{<:Any, <:Any, Nothing}) = false
haspreprocessing(::Simulation{<:Any, <:Any, <:Function}) = true

haspostprocessing(::Simulation{<:Any, <:Any, <:Any, Nothing}) = false
haspostprocessing(::Simulation{<:Any, <:Any, <:Any, <:Function}) = true

preprocessing(sim::Simulation, x, n) = haspreprocessing(sim) && sim.f_pre(x, n)
postprocessing(sim::Simulation, x, n) = haspostprocessing(sim) && sim.f_post(x, n)


function (sim::Simulation{DT})() where {DT}
    for n in eachtimestep(sim)
        preprocessing(sim, sim.x, n)
        sim.int(sim.x)
        postprocessing(sim, sim.x, n)
    end
end
