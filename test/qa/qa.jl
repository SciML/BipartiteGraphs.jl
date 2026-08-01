using BipartiteGraphs
using SciMLTesting
using Test

# ExplicitImports only inspects an extension module once it exists, which requires the
# extension's trigger package to be loaded. Without loading the weakdeps here,
# BipartiteGraphsSparseArraysExt is silently skipped by the QA checks.
using SparseArrays

# ExplicitImports silently skips an extension that fails to load, so assert the
# extension modules actually exist rather than trusting a green run_qa.
@testset "Extensions loaded" begin
    @test Base.get_extension(BipartiteGraphs, :BipartiteGraphsSparseArraysExt) !== nothing
end

run_qa(BipartiteGraphs)
