
# Julia@Home Assignments

## 5. Traits and Closures

### Traits

An alternative implementation of the pre- and post-processing can be constructed via traits, based on the following functions:
```julia
haspreprocessing(::Equation{<:Number, <:Function, Nothing}) = false
haspreprocessing(::Equation{<:Number, <:Function, <:Function}) = true
haspostprocessing(::Equation{<:Number, <:Function, <:Union{Function,Nothing}, Nothing}) = false
haspostprocessing(::Equation{<:Number, <:Function, <:Union{Function,Nothing}, <:Function}) = true
```

With those we can rewrite the `preprocessing` and `postprocessing` functions:
```julia
function preprocessing(equ::Equation, x₀::AbstractArray)
    if haspreprocessing(equ)
        equ.f_pre(x₀)
    else
        # nothing to do
    end
end

function postprocessing(equ::Equation, x₁::AbstractArray)
    if haspostprocessing(equ)
        equ.f_post(x₁)
    end
end
```

In this example there is little benefit by using traits, but in other contexts code can become much short and sometimes easier to read by using traits instead of dispatch, especially when only a small fraction of a method depends on a given property of an object.
Traits cause no additional overhead: as they are dispatched on type parameters, the compiler will optimise `preprocessing` and `postprocessing` for the equation they are called with and remove all of the code in the branches that are not executed.
