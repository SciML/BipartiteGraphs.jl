using Pkg
using BipartiteGraphs
using Graphs
using Test
using SafeTestsets

const GROUP = get(ENV, "GROUP", "All")

if GROUP == "QA"
    Pkg.activate(joinpath(@__DIR__, "qa"))
    Pkg.instantiate()
    include("qa/qa.jl")
else
    @testset "BipartiteGraphs.jl" begin
        @safetestset "Matching" begin include("matching.jl") end
        @safetestset "BipartiteGraph" begin include("bipartite_graph.jl") end
        @safetestset "`maximal_matching`" begin include("maximal_matching.jl") end
        @safetestset "DiCMOBiGraph" begin include("dicmobigraph.jl") end
        @safetestset "Condensation graphs" begin include("condensation_graphs.jl") end
        @safetestset "Pretty printing" begin include("pretty_printing.jl") end
        @safetestset "HyperGraph" begin include("hypergraph.jl") end
        @safetestset "Integration tests" begin include("integration.jl") end
    end

    # Allocation tests run separately to avoid interference with precompilation
    @safetestset "Allocation Tests" begin include("alloc_tests.jl") end
end
