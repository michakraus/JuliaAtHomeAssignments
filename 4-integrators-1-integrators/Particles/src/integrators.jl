
abstract type Integrator{DT} end

function integrate_step! end


struct ExplicitEuler{DT} <: Integrator{DT}
    Δt::DT
    ẋ::Vector{DT}
    
    function ExplicitEuler(equ::Equation{DT}, Δt::DT) where {DT}
        new{DT}(Δt, zeros(DT, ndims(equ)))
    end
end

function integrate_step!(int::ExplicitEuler, equ::Equation, x₀::AbstractVector, x₁::AbstractVector)
    equ.f(int.ẋ, x₀)
    x₁ .= x₀ .+ int.Δt .* int.ẋ
end