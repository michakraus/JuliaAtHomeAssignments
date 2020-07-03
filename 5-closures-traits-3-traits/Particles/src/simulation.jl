
struct Simulation{DT <: Number, IT <: Integrator{DT}}
    int::IT
    x::OffsetArray{DT,3,Array{DT,3}}

    function Simulation(x₀::AbstractArray{DT}, int::IT, nt::Int) where {DT, IT <: Integrator{DT}}
        x = OffsetArray(zeros(DT, size(x₀)..., nt+1), axes(x₀)..., 0:nt)
        x[:,:,0] .= x₀
        new{DT,IT}(int, x)
    end
end

function Simulation(equ::Equation, integrator::Type{<:Integrator}, Δt::Real, nt::Int; kwargs...)
    int = integrator(equ, Δt; kwargs...)
    Simulation(equ.x₀, int, nt)
end


ndims(sim::Simulation) = ndims(sim.int.equ)
nsamples(sim::Simulation) = nsamples(sim.int.equ)
ntimesteps(sim::Simulation) = lastindex(sim.x,3)

eachsample(sim::Simulation) = axes(sim.x,2)
eachtimestep(sim::Simulation) = axes(sim.x,3)[1:end]


function (sim::Simulation{DT})() where {DT}
    for n in eachtimestep(sim)
        @views preprocessing(sim.int.equ, sim.x[:,:,n-1])
        for i in eachsample(sim)
            @views sim.int(sim.x[:,i,n-1], sim.x[:,i,n])
        end
        @views postprocessing(sim.int.equ, sim.x[:,:,n])
    end
    return sim.x
end
