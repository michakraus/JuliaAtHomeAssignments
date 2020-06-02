
# struct Simulation{DT <: Number, AT <: OffsetArray{DT,3}}
#     Δt::DT
#     nt::Int
#     x::AT

#     function Simulation(x₀::AbstractArray{DT,2}, Δt::DT, nt::Int) where {DT}
#         x = OffsetArray(zeros(DT, size(x₀)..., nt+1), axes(x₀)..., 0:nt)
#         x[:,:,0] .= x₀
#         new{DT, typeof(x)}(Δt, nt, x)
#     end
# end

struct Simulation{DT <: Number}
    Δt::DT
    nt::Int
    x::OffsetArray{DT,3,Array{DT,3}}

    function Simulation(x₀::AbstractArray{DT,2}, Δt::DT, nt::Int) where {DT}
        x = OffsetArray(zeros(DT, size(x₀)..., nt+1), axes(x₀)..., 0:nt)
        x[:,:,0] .= x₀
        new{DT}(Δt, nt, x)
    end
end


function run!(sim::Simulation)
    for n in 1:sim.nt
        for i in axes(sim.x, 2)
            sim.x[1,i,n] = sim.x[1,i,n-1] + sim.Δt * sim.x[2,i,n-1]
            sim.x[2,i,n] = sim.x[2,i,n-1] - sim.Δt * sin(sim.x[1,i,n-1])
        end
    end
    return sim.x
end




