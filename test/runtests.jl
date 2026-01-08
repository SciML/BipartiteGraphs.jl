using BipartiteGraphs
using Graphs
using Test

@testset "BipartiteGraphs.jl" begin
    @testset "Matching" include("matching.jl")
    @testset "BipartiteGraph" include("bipartite_graph.jl")
    @testset "`maximal_matching`" include("maximal_matching.jl")
    @testset "DiCMOBiGraph" include("dicmobigraph.jl")
    @testset "Condensation graphs" include("condensation_graphs.jl")
    @testset "Pretty printing" include("pretty_printing.jl")
    @testset "HyperGraph" include("hypergraph.jl")
    @testset "Integration tests" include("integration.jl")
end

# Allocation tests run separately to avoid interference with precompilation
if get(ENV, "GROUP", "all") == "all" || get(ENV, "GROUP", "all") == "nopre"
    @testset "Allocation Tests" begin
        include("alloc_tests.jl")
    end
end
