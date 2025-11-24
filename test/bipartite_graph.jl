using BipartiteGraphs
using Graphs
using Test

@testset "Construction" begin
    e = BipartiteEdge(1, 2)
    @test src(e) == 1
    @test dst(e) == 2

    # Test type promotion
    e2 = BipartiteEdge(Int32(1), Int64(2))
    @test src(e2) isa Int64
    @test dst(e2) isa Int64
end

@testset "Equality" begin
    e1 = BipartiteEdge(1, 2)
    e2 = BipartiteEdge(1, 2)
    e3 = BipartiteEdge(1, 3)

    @test e1 == e2
    @test e1 != e3
end

@testset "Construction from adjacency lists" begin
    # Simple bipartite graph
    fadjlist = [[1], [1], [2], [2], [1], [1, 2]]
    badjlist = [[1, 2, 5, 6], [3, 4, 6]]

    g = BipartiteGraph(7, fadjlist, badjlist)
    @test ne(g) == 7
    @test nsrcs(g) == 6
    @test ndsts(g) == 2

    # Test inferred ne
    g2 = BipartiteGraph(fadjlist, badjlist)
    @test ne(g2) == 7

    # Test without backward adjacency
    g3 = BipartiteGraph(fadjlist, 2)
    @test ndsts(g3) == 2
    @test g3.badjlist isa Int
end

@testset "Empty graph construction" begin
    g = BipartiteGraph(5, 3)
    @test nsrcs(g) == 5
    @test ndsts(g) == 3
    @test ne(g) == 0
    @test g.badjlist isa AbstractVector

    # Test without backedges
    g2 = BipartiteGraph(5, 3, Val(false))
    @test g2.badjlist isa Int
end

@testset "Graph queries" begin
    fadjlist = [[1, 2], [2], [1]]
    badjlist = [[1, 3], [1, 2]]
    g = BipartiteGraph(fadjlist, badjlist)

    @test 𝑠vertices(g) == 1:3
    @test 𝑑vertices(g) == 1:2
    @test vertices(g) == (1:3, 1:2)
    @test nv(g) == 5

    @test has_𝑠vertex(g, 1)
    @test has_𝑠vertex(g, 3)
    @test !has_𝑠vertex(g, 4)

    @test has_𝑑vertex(g, 1)
    @test has_𝑑vertex(g, 2)
    @test !has_𝑑vertex(g, 3)

    @test 𝑠neighbors(g, 1) == [1, 2]
    @test 𝑠neighbors(g, 2) == [2]
    @test 𝑠neighbors(g, 3) == [1]

    @test 𝑑neighbors(g, 1) == [1, 3]
    @test 𝑑neighbors(g, 2) == [1, 2]
end

@testset "Edge operations" begin
    g = BipartiteGraph(3, 2)

    # Add edges
    @test add_edge!(g, 1, 1)
    @test ne(g) == 1
    @test has_edge(g, BipartiteEdge(1, 1))

    @test add_edge!(g, 1, 2)
    @test ne(g) == 2

    # Adding existing edge should return false
    @test !add_edge!(g, 1, 1)
    @test ne(g) == 2

    # Test with BipartiteEdge
    @test add_edge!(g, BipartiteEdge(2, 1))
    @test ne(g) == 3

    # Remove edge
    @test rem_edge!(g, 1, 1)
    @test ne(g) == 2
    @test !has_edge(g, BipartiteEdge(1, 1))

    @test rem_edge!(g, BipartiteEdge(2, 1))
    @test ne(g) == 1
end

@testset "Vertex operations" begin
    g = BipartiteGraph(2, 2)

    # Add source vertex
    new_src = add_vertex!(g, SRC)
    @test new_src == 3
    @test nsrcs(g) == 3

    # Add destination vertex
    new_dst = add_vertex!(g, DST)
    @test new_dst == 3
    @test ndsts(g) == 3
end

@testset "set_neighbors!" begin
    g = BipartiteGraph(3, 3)
    add_edge!(g, 1, 1)
    add_edge!(g, 1, 2)

    # Change neighbors
    set_neighbors!(g, 1, [2, 3])
    @test 𝑠neighbors(g, 1) == [2, 3]
    @test !has_edge(g, BipartiteEdge(1, 1))
    @test has_edge(g, BipartiteEdge(1, 3))

    # Clear neighbors
    set_neighbors!(g, 1, ())
    @test isempty(𝑠neighbors(g, 1))
end

@testset "Edge iteration" begin
    fadjlist = [[1, 2], [2], [1]]
    g = BipartiteGraph(fadjlist, 2)

    edges_vec = collect(edges(g))
    @test length(edges_vec) == 4

    # Test source edge iteration
    sedges = collect(𝑠edges(g))
    @test length(sedges) == 4
    @test all(e -> e isa BipartiteEdge, sedges)

    # Test destination edge iteration (requires complete)
    g_complete = complete(g)
    dedges = collect(𝑑edges(g_complete))
    @test length(dedges) == 4
end

@testset "Graph completion" begin
    fadjlist = [[1, 2], [2], [1]]
    g = BipartiteGraph(fadjlist, 2)
    @test g.badjlist isa Int

    g_complete = complete(g)
    @test g_complete.badjlist isa AbstractVector
    @test length(g_complete.badjlist) == 2

    # Completing again should not change
    g_complete2 = complete(g_complete)
    @test g_complete2 === g_complete
end

@testset "invview" begin
    fadjlist = [[1, 2], [2], [1]]
    badjlist = [[1, 3], [1, 2]]
    g = BipartiteGraph(fadjlist, badjlist)

    g_inv = invview(g)
    @test nsrcs(g_inv) == 2
    @test ndsts(g_inv) == 3
    @test 𝑠neighbors(g_inv, 1) == [1, 3]
    @test 𝑠neighbors(g_inv, 2) == [1, 2]
end

@testset "copy and empty!" begin
    fadjlist = [[1, 2], [2]]
    badjlist = [[1], [1, 2]]
    g = BipartiteGraph(fadjlist, badjlist)

    # Test copy
    g_copy = copy(g)
    add_edge!(g_copy, 2, 1)
    @test ne(g_copy) == 4
    @test ne(g) == 3  # Original unchanged

    # Test empty!
    empty!(g_copy)
    @test ne(g_copy) == 0
    @test all(isempty, g_copy.fadjlist)
end

@testset "isequal" begin
    fadjlist = [[1], [2]]
    badjlist = [[1], [2]]
    g1 = BipartiteGraph(fadjlist, badjlist)
    g2 = BipartiteGraph(fadjlist, badjlist)

    @test isequal(g1, g2)

    add_edge!(g2, 1, 2)
    @test !isequal(g1, g2)
end

@testset "delete_srcs! and delete_dsts!" begin
    fadjlist = [[1], [1, 2], [2], [1, 2]]
    g = BipartiteGraph(fadjlist, 2)
    g = complete(g)
    initial_ne = ne(g)

    # Delete source vertices (remove edges only)
    delete_srcs!(g, [2])
    @test ne(g) <= initial_ne
    @test 𝑠neighbors(g, 2) == []

    # Delete with vertex removal
    g2 = BipartiteGraph([[1], [1, 2], [2], [1, 2]], 2)
    g2 = complete(g2)
    delete_srcs!(g2, [2]; rm_verts = true)
    @test nsrcs(g2) == 3

    # Delete destination vertices
    g3 = BipartiteGraph([[1], [1, 2], [2]], 2)
    g3 = complete(g3)
    delete_dsts!(g3, [1])
    @test 𝑠neighbors(g3, 1) == []
end

@testset "require_complete errors" begin
    g = BipartiteGraph([[1], [2]], 2)
    @test_throws ArgumentError require_complete(g)

    g_complete = complete(g)
    require_complete(g_complete)  # Should not throw
    @test true
end

@testset "Edge out of bounds" begin
    g = BipartiteGraph(2, 2)
    @test_throws Exception add_edge!(g, 3, 1)  # Source out of bounds
    @test_throws Exception add_edge!(g, 1, 3)  # Dest out of bounds
end

@testset "Remove non-existent edge" begin
    g = BipartiteGraph(2, 2)
    add_edge!(g, 1, 1)
    @test_throws Exception rem_edge!(g, 1, 2)  # Edge doesn't exist
end

@testset "Invalid vertex type" begin
    g = BipartiteGraph(2, 2)
    # This should error with invalid type
    @test_throws Exception add_vertex!(g, :INVALID)
end

@testset "BipartiteGraph length error" begin
    g = BipartiteGraph(2, 2)
    @test_throws ErrorException length(g)
end

@testset "Graph with metadata" begin
    fadjlist = [[1], [2]]
    g = BipartiteGraph(fadjlist, 2; metadata = [[1.0], [2.0]])
    @test g.metadata !== nothing

    # Test 𝑠neighbors with metadata
    neighs_with_meta = 𝑠neighbors(g, 1, Val(true))
    @test neighs_with_meta isa Base.Iterators.Zip

    # Test add_edge with metadata
    add_edge!(g, 1, 2, 1.5)
    @test ne(g) == 3

    # Test empty! with metadata
    empty!(g)
    @test ne(g) == 0
end

@testset "BipartiteGraph copy with metadata" begin
    fadjlist = [[1], [2]]
    g = BipartiteGraph(fadjlist, 2; metadata = [[1.0], [2.0]])
    g_copy = copy(g)
    @test g_copy.metadata !== nothing
    @test g_copy.metadata !== g.metadata  # Should be deep copied
end

@testset "eltype" begin
    g = BipartiteGraph(Int32(2), Int32(2))
    @test eltype(g) == Int32
end
