
struct Equation{DT <: Number, FT <: Function, FPRE <: Union{Function,Nothing}, FPOST <: Union{Function,Nothing}}
    f::FT
    x₀::Array{DT,2}
    f_pre::FPRE
    f_post::FPOST

    function Equation(f::FT, x₀::AbstractArray{DT,2}; f_preproc::FPRE=nothing, f_postproc::FPOST=nothing) where {DT, FT, FPRE, FPOST}
        new{DT, FT, FPRE, FPOST}(f, Array(x₀), f_preproc, f_postproc)
    end
end

ndims(equ::Equation) = length(axes(equ.x₀,1))
nsamples(equ::Equation) = length(axes(equ.x₀,2))

haspreprocessing(::Equation{<:Number, <:Function, Nothing}) = false
haspreprocessing(::Equation{<:Number, <:Function, <:Function}) = true

haspostprocessing(::Equation{<:Number, <:Function, <:Union{Function,Nothing}, Nothing}) = false
haspostprocessing(::Equation{<:Number, <:Function, <:Union{Function,Nothing}, <:Function}) = true

function preprocessing(equ::Equation, x₀::AbstractArray)
    if haspreprocessing(equ)
        equ.f_pre(x₀)
    end
end

function postprocessing(equ::Equation, x₁::AbstractArray)
    if haspostprocessing(equ)
        equ.f_post(x₁)
    end
end
