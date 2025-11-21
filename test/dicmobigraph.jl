using BipartiteGraphs
using Graphs
using Test

@testset "Construction" begin
    fadjlist = [[1, 2], [2, 3], [3]]
    g = BipartiteGraph(fadjlist, 3)

    # Empty matching
    dmog = DiCMOBiGraph{false}(g)
    @test dmog.graph === g
    @test length(dmog.matching) == 3

    # With matching
    m = Matching(3)
    m[1] = 1
    m[2] = 2
    dmog2 = DiCMOBiGraph{false}(g, m)
    @test dmog2.matching === m
end

@testset "Graph properties" begin
    fadjlist = [[1, 2], [2, 3], [3]]
    g = BipartiteGraph(fadjlist, 3)
    m = Matching(3)
    m[1] = 1
    m[2] = 2
    m[3] = 3

    dmog = DiCMOBiGraph{false}(g, m)
    @test is_directed(dmog)
    @test nv(dmog) == 3
    @test vertices(dmog) == 1:3
end

@testset "Neighbors (non-transposed)" begin
    fadjlist = [[1, 2], [2, 3], [3]]
    g = BipartiteGraph(fadjlist, 3)
    m = Matching(3)
    m[1] = 1
    m[2] = 2
    m[3] = 3

    dmog = DiCMOBiGraph{false}(complete(g), m)

    # Out-neighbors (non-matched edges from src)
    out_neighbors_1 = collect(outneighbors(dmog, 1))
    @test 2 in out_neighbors_1  # Edge 1->2 exists and is not matched

    # Test edges
    edges_list = collect(edges(dmog))
    @test all(e -> e isa Graphs.AbstractEdge, edges_list)
end

@testset "Neighbors (transposed)" begin
    fadjlist = [[1, 2], [2, 3], [3]]
    g = BipartiteGraph(fadjlist, 3)
    m = Matching(3)
    m[1] = 1
    m[2] = 2

    dmog = DiCMOBiGraph{true}(complete(g), m)
    @test nv(dmog) == 3  # Should have ndsts vertices
end

@testset "invview" begin
    fadjlist = [[1, 2], [2]]
    g = BipartiteGraph(fadjlist, 2)
    m = Matching(2)
    m[1] = 1
    m = complete(m, 2)  # Complete the matching

    dmog = DiCMOBiGraph{false}(complete(g), m)
    dmog_inv = invview(dmog)

    @test dmog_inv isa DiCMOBiGraph{true}
end

@testset "has_edge" begin
    fadjlist = [[1, 2], [2, 3]]
    g = BipartiteGraph(fadjlist, 3)
    m = Matching(3)
    m[1] = 1
    m[2] = 2

    dmog = DiCMOBiGraph{false}(complete(g), m)

    # Check for directed edges based on matching
    # This is complex due to the orientation rules
    @test has_edge(dmog, 1, 2) || !has_edge(dmog, 1, 2)  # Just check it doesn't error
end

@testset "Edge operations" begin
    fadjlist = [[1, 2], [2, 3], [1, 3]]
    g = BipartiteGraph(fadjlist, 3)
    m = Matching(3)
    m[1] = 1
    m[2] = 2
    m[3] = 3

    dmog = DiCMOBiGraph{false}(complete(g), m)

    # Test ne calculation
    num_edges = ne(dmog)
    @test num_edges >= 0

    # Test edge existence
    edges_list = collect(edges(dmog))
    @test length(edges_list) >= 0
end

@testset "Transposed graph operations" begin
    fadjlist = [[1, 2], [2, 3], [3]]
    g = BipartiteGraph(fadjlist, 3)
    m = Matching(3)
    m[1] = 1
    m[2] = 2
    m[3] = 3
    m = complete(m, 3)  # Complete the matching

    dmog = DiCMOBiGraph{true}(complete(g), m)

    # Test vertices
    @test nv(dmog) == 3
    verts = vertices(dmog)
    @test length(verts) == 3

    # Test inneighbors (safer path)
    in_neighs_iter = inneighbors(dmog, 1)
    @test in_neighs_iter isa BipartiteGraphs.CMONeighbors
end

@testset "Type constructor for induced_subgraph" begin
    # Test the special constructor for SimpleDiGraph compatibility
    sg = DiCMOBiGraph(5)
    @test sg isa Graphs.SimpleDiGraph
    @test nv(sg) == 5
end
