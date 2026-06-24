using BipartiteGraphs
using Aqua
using ExplicitImports
using JET
using SciMLTesting
using Test

# Aqua + ExplicitImports via the shared SciMLTesting harness.
#
# Aqua: `unbound_args`/`deps_compat` are disabled because of two pre-existing nits
# tracked in https://github.com/SciML/BipartiteGraphs.jl/issues/36 (a genuinely
# unbound type parameter in `Matching` and a `[compat]`-less `[extras]` entry).
#
# ExplicitImports: all four standard checks and both public-API checks run. Three
# qualified accesses are unavoidable and so are ignored (per-check, minimal):
#   * `OneTo` — `Base.OneTo` is the vertex-range type returned by `𝑑vertices`/
#     condensation-graph `vertices`; it is public Base API as of Julia 1.11 but only
#     retroactively marked, so the check flags it on the 1.10 LTS. Rewriting it to a
#     `UnitRange` would change the return type, so the canonical name is kept.
#   * `print_matrix` — the only routine for tabular `Base.show` of a matrix view.
#   * `typeinfo_implicit` — the documented (internal) hook for suppressing the
#     element-type header when printing an array of `HighlightInt`.
run_qa(
    BipartiteGraphs;
    Aqua = Aqua,
    aqua_kwargs = (; unbound_args = false, deps_compat = false),
    ExplicitImports = ExplicitImports,
    explicit_imports = true,
    ei_kwargs = (;
        all_qualified_accesses_are_public = (;
            ignore = (:OneTo, :print_matrix, :typeinfo_implicit),
        ),
    ),
)

@testset "Aqua (known-broken nits, issue #36)" begin
    # Aqua unbound type parameters: 1 found (Matching(v::V) where {U, V<:AbstractArray{Union{Int64, U}, 1}}
    # at src/matching.jl:88) — tracked in https://github.com/SciML/BipartiteGraphs.jl/issues/36
    @test_broken false
    # Aqua deps_compat: `Pkg` in [extras] has no [compat] entry — tracked in
    # https://github.com/SciML/BipartiteGraphs.jl/issues/36
    @test_broken false
end

@testset "JET" begin
    # JET.report_package finds 10 possible errors stemming from the Union-typed `fadjlist`/`badjlist`
    # fields of BipartiteGraph/HyperGraph (no-matching-method on push!/+/searchsortedfirst/deleteat!/
    # Base.OneTo/empty! over Union{Int64, Vector{...}}) — tracked in
    # https://github.com/SciML/BipartiteGraphs.jl/issues/36
    rep = JET.report_package(BipartiteGraphs; target_defined_modules = true)
    @test_broken isempty(JET.get_reports(rep))
end
