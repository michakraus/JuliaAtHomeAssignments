
struct Simulation{DT <: Number, ET <: Equation{DT}, IT <: Integrator{DT}}
    equ::ET
    int::IT
    x::OffsetArray{DT,3,Array{DT,3}}

    function Simulation(equ::ET, int::IT, nt::Int) where {DT, ET <: Equation{DT}, IT <: Integrator{DT}}
        x = OffsetArray(zeros(DT, size(equ.x₀)..., nt+1), axes(equ.x₀)..., 0:nt)
        x[:,:,0] .= equ.x₀
        new{DT,ET,IT}(equ, int, x)
    end
end


ndims(sim::Simulation) = ndims(sim.equ)
nsamples(sim::Simulation) = nsamples(sim.equ)
ntimesteps(sim::Simulation) = lastindex(sim.x,3)

eachsample(sim::Simulation) = axes(sim.x,2)
eachtimestep(sim::Simulation) = axes(sim.x,3)[1:end]


function run!(sim::Simulation{DT}) where {DT}
    for n in eachtimestep(sim)
        for i in eachsample(sim)
            # x₀ = @view sim.x[:,i,n-1]
            # x₁ = @view sim.x[:,i,n]
            # integrate_step!(sim.int, sim.equ, x₀, x₁)

            integrate_step!(sim.int, sim.equ, view(sim.x, :, i ,n-1), view(sim.x, :, i, n))
        end
    end
    return sim.x
end
