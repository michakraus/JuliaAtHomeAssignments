
abstract type Integrator{DT} end


struct ExplicitEuler{DT, ET <: Equation{DT}} <: Integrator{DT}
    equ::ET
    Δt::DT
    ẋ::Vector{Vector{DT}}
    
    function ExplicitEuler(equ::ET, Δt::DT) where {DT, ET <: Equation{DT}}
        ẋ = [ zeros(DT, ndims(equ)) for i in 1:nsamples(equ) ]
        new{DT,ET}(equ, Δt, ẋ)
    end
end

function (int::ExplicitEuler)(x::AbstractVector)
    preprocessing(int.equ, x)
    int.equ.f(int.ẋ, x)
    x .+= int.Δt .* int.ẋ
    postprocessing(int.equ, x)
end
