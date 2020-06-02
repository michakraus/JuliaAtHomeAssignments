
struct Simulation{DT <: Number}
    Δt::DT
    nt::Int
    x::Array{DT,3}

    function Simulation(x₀::AbstractArray{DT,2}, Δt::DT, nt::Int) where {DT}
        x = zeros(DT, size(x₀)..., nt+1)
        x[:,:,1] .= x₀
        new{DT}(Δt, nt, x)
    end
end


function run!(sim::Simulation)
    for n in 1:sim.nt
        for i in axes(sim.x, 2)
            sim.x[1,i,n+1] = sim.x[1,i,n] + sim.Δt * sim.x[2,i,n]
            sim.x[2,i,n+1] = sim.x[2,i,n] - sim.Δt * sin(sim.x[1,i,n])
        end
    end
    return sim.x
end




