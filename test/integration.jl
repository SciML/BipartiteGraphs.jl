using BipartiteGraphs
using Graphs
using Test

@testset "Complete workflow: graph -> matching -> DiCMO -> condensation" begin
    # Create a bipartite graph
    fadjlist = [[1], [1, 2], [2, 3], [3]]
    g = BipartiteGraph(fadjlist, 3)
    g = complete(g)

    # Find maximal matching
    m = maximal_matching(g)
    @test count(x -> x isa Int, m) >= 2

    # Create DiCMOBiGraph
    dmog = DiCMOBiGraph{false}(g, m)
    @test nv(dmog) == nsrcs(g)

    # Create simple condensation (trivial SCCs)
    sccs = [[i] for i in 1:ndsts(g)]
    mcg = MatchedCondensationGraph(dmog, sccs)
    @test nv(mcg) == ndsts(g)
end

@testset "Edge cases" begin
    # Empty graph
    g_empty = BipartiteGraph(0, 0)
    @test ne(g_empty) == 0
    @test nsrcs(g_empty) == 0
    @test ndsts(g_empty) == 0

    # Graph with no edges
    g_no_edges = BipartiteGraph(3, 2)
    @test ne(g_no_edges) == 0
    m = maximal_matching(g_no_edges)
    @test all(x -> x === unassigned, m)

    # Single vertex
    g_single = BipartiteGraph(1, 1)
    add_edge!(g_single, 1, 1)
    @test ne(g_single) == 1
    m = maximal_matching(g_single)
    @test m[1] == 1
end

@testset "Large graph stress test" begin
    # Create a larger graph
    n_src, n_dst = 100, 50
    g_large = BipartiteGraph(n_src, n_dst)

    # Add random edges
    for i in 1:n_src
        for j in 1:min(5, n_dst)
            dst = mod1(i + j, n_dst)
            add_edge!(g_large, i, dst)
        end
    end

    @test ne(g_large) > 0
    m = maximal_matching(g_large)
    @test m isa Matching
    @test length(m) >= n_dst
end
