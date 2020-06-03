
# struct Simulation{DT <: Number, ET <: Equation{DT}}
#     Δt::DT
#     equ::ET
#     x::OffsetArray{DT,3,Array{DT,3}}

#     function Simulation(equ::ET, Δt::DT, nt::Int) where {DT, ET <: Equation{DT}}
#         x = OffsetArray(zeros(DT, size(equ.x₀)..., nt+1), axes(equ.x₀)..., 0:nt)
#         x[:,:,0] .= equ.x₀
#         new{DT,ET}(Δt, equ, x)
#     end
# end

struct Simulation{DT <: Number, FT <: Function}
    Δt::DT
    equ::Equation{DT,FT}
    x::OffsetArray{DT,3,Array{DT,3}}

    function Simulation(equ::Equation{DT,FT}, Δt::DT, nt::Int) where {DT, FT}
        x = OffsetArray(zeros(DT, size(equ.x₀)..., nt+1), axes(equ.x₀)..., 0:nt)
        x[:,:,0] .= equ.x₀
        new{DT,FT}(Δt, equ, x)
    end
end

ndims(sim::Simulation) = ndims(sim.equ)
nsamples(sim::Simulation) = nsamples(sim.equ)
ntimesteps(sim::Simulation) = lastindex(sim.x,3)

eachsample(sim::Simulation) = axes(sim.x,2)
eachtimestep(sim::Simulation) = axes(sim.x,3)[1:end]


function run!(sim::Simulation{DT}) where {DT}
    ẋ = zeros(DT, ndims(sim))
    for n in eachtimestep(sim)
        for i in eachsample(sim)
            sim.equ.f(ẋ, sim.x[:,i,n-1])
            sim.x[:,i,n] .= sim.x[:,i,n-1] .+ sim.Δt .* ẋ
        end
    end
    return sim.x
end
