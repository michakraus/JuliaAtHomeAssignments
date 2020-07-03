
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

preprocessing(::Equation{<:Number, <:Function, Nothing}, ::AbstractArray) = nothing
postprocessing(::Equation{<:Number, <:Function, <:Union{Function,Nothing}, Nothing}, ::AbstractArray) = nothing

preprocessing(equ::Equation{<:Number, <:Function, <:Function}, x₀::AbstractArray) = equ.f_pre(x₀)
postprocessing(equ::Equation{<:Number, <:Function, <:Union{Function,Nothing}, <:Function}, x₁::AbstractArray) = equ.f_post(x₁)


