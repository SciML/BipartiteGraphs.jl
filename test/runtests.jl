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
    @testset "Integration tests" include("integration.jl")
end
