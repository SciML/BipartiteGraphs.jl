using SafeTestsets

@safetestset "Aqua" begin
    using BipartiteGraphs
    using Aqua
    using Test
    Aqua.test_all(BipartiteGraphs; unbound_args = false, deps_compat = false)
    # Aqua unbound type parameters: 1 found (Matching(v::V) where {U, V<:AbstractArray{Union{Int64, U}, 1}}
    # at src/matching.jl:88) — tracked in https://github.com/SciML/BipartiteGraphs.jl/issues/36
    @test_broken false
    # Aqua deps_compat: `Pkg` in [extras] has no [compat] entry — tracked in
    # https://github.com/SciML/BipartiteGraphs.jl/issues/36
    @test_broken false
end

@safetestset "JET" begin
    using BipartiteGraphs
    using JET
    using Test
    # JET.report_package finds 10 possible errors stemming from the Union-typed `fadjlist`/`badjlist`
    # fields of BipartiteGraph/HyperGraph (no-matching-method on push!/+/searchsortedfirst/deleteat!/
    # Base.OneTo/empty! over Union{Int64, Vector{...}}) — tracked in
    # https://github.com/SciML/BipartiteGraphs.jl/issues/36
    rep = JET.report_package(BipartiteGraphs; target_defined_modules = true)
    @test_broken isempty(JET.get_reports(rep))
end
