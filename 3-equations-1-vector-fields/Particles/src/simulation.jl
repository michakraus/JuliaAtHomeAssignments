
struct Simulation{DT <: Number, FT <: Function}
    Δt::DT
    f::FT
    x::OffsetArray{DT,3,Array{DT,3}}

    function Simulation(f::FT, x₀::AbstractArray{DT,2}, Δt::DT, nt::Int) where {DT, FT}
        x = OffsetArray(zeros(DT, size(x₀)..., nt+1), axes(x₀)..., 0:nt)
        x[:,:,0] .= x₀
        new{DT,FT}(Δt, f, x)
    end
end

ntimesteps(sim::Simulation) = lastindex(sim.x,3)
nsamples(sim::Simulation) = length(axes(sim.x,2))
ndims(sim::Simulation) = length(axes(sim.x,1))

eachtimestep(sim::Simulation) = axes(sim.x,3)[1:end]
eachsample(sim::Simulation) = axes(sim.x,2)


function run!(sim::Simulation{DT}) where {DT}
    ẋ = zeros(DT, ndims(sim))
    for n in eachtimestep(sim)
        for i in eachsample(sim)
            sim.f(ẋ, sim.x[:,i,n-1])
            sim.x[:,i,n] .= sim.x[:,i,n-1] .+ sim.Δt .* ẋ
        end
    end
    return sim.x
end
