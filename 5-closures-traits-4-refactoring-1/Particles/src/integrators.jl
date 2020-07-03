
abstract type Integrator{DT} end


struct ExplicitEuler{DT, ET <: Equation{DT}} <: Integrator{DT}
    equ::ET
    Δt::DT
    ẋ::Vector{DT}
    
    function ExplicitEuler(equ::ET, Δt::DT) where {DT, ET <: Equation{DT}}
        new{DT,ET}(equ, Δt, zeros(DT, ndims(equ)))
    end
end

function (int::ExplicitEuler)(x::AbstractVector)
    int.equ.f(int.ẋ, x)
    x .+= int.Δt .* int.ẋ
end
