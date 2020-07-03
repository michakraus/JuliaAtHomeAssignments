
struct Equation{DT <: Number, FT <: Function}
    f::FT
    x₀::Array{DT,2}

    function Equation(f::FT, x₀::AbstractArray{DT,2}) where {DT,FT}
        new{DT,FT}(f, Array(x₀))
    end
end

ndims(equ::Equation) = length(axes(equ.x₀,1))
nsamples(equ::Equation) = length(axes(equ.x₀,2))
