
using Particles
using StatsBase
using StatsPlots


nx = 16
nv = 12

n = 10000
x = randn(n)
v = randn(n)

xmax = ceil(maximum(abs.(x)))
x .+= xmax
x ./= 2*xmax

vmax = ceil(maximum(abs.(v)))


p = PoissonSolver{eltype(x)}(nx)
solve!(p, x)


xgrid = collect(0:p.Δx:1)
vgrid = LinRange(-vmax, +vmax, nv)

hx = fit(Histogram, x, xgrid)
hv = fit(Histogram, v, vgrid)


plot(hx; legend=nothing, xlabel="x", ylabel="n")
savefig("poisson_histogram_x.png")

plot(hv; legend=nothing, xlabel="v", ylabel="n")
savefig("poisson_histogram_v.png")

plot(p.xgrid[1:end-1], p.ρ; legend=nothing, xlabel="x", ylabel="ρ(x)")
savefig("poisson_ρ.png")

plot(p.xgrid[1:end-1], p.ϕ; legend=nothing, xlabel="x", ylabel="ϕ(x)")
savefig("poisson_ϕ.png")

plot(p.xgrid, x -> eval_field(p, x); legend=nothing, xlabel="x", ylabel="E(x)")
savefig("poisson_E.png")
