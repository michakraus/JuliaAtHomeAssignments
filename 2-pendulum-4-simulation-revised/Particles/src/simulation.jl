
struct Simulation{DT <: Number}
    Δt::DT
    x::OffsetArray{DT,3,Array{DT,3}}

    function Simulation(x₀::AbstractArray{DT,2}, Δt::DT, nt::Int) where {DT}
        x = OffsetArray(zeros(DT, size(x₀)..., nt+1), axes(x₀)..., 0:nt)
        x[:,:,0] .= x₀
        new{DT}(Δt, x)
    end
end

ntimesteps(sim::Simulation) = lastindex(sim.x,3)
nics(sim::Simulation) = lastindex(sim.x,2)

eachtimestep(sim::Simulation) = 1:ntimesteps(sim)
eachic(sim::Simulation) = axes(sim.x,2)


function run!(sim::Simulation)
    for n in eachtimestep(sim)
        for i in eachic(sim)
            sim.x[1,i,n] = sim.x[1,i,n-1] + sim.Δt * sim.x[2,i,n-1]
            sim.x[2,i,n] = sim.x[2,i,n-1] - sim.Δt * sin(sim.x[1,i,n-1])
        end
    end
    return sim.x
end
