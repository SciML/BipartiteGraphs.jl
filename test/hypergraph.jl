using BipartiteGraphs
using Graphs
using Test

@testset "HyperGraph Construction" begin
    # Test empty construction
    hg = HyperGraph{String}()
    @test Graphs.nv(hg) == 0
    @test Graphs.ne(hg) == 0
    @test eltype(typeof(hg)) == String
end

@testset "Adding vertices and edges" begin
    hg = HyperGraph{Symbol}()

    # Add vertices
    @test Graphs.add_vertex!(hg, :a) == 1
    @test Graphs.add_vertex!(hg, :b) == 2
    @test Graphs.add_vertex!(hg, :c) == 3

    @test Graphs.nv(hg) == 3
    @test Graphs.ne(hg) == 0

    # Add duplicate vertex (should be no-op)
    @test Graphs.add_vertex!(hg, :a) == 1
    @test Graphs.nv(hg) == 3

    # Add hyperedges
    e1 = Graphs.add_edge!(hg, [:a, :b])
    @test e1 == 1
    @test Graphs.ne(hg) == 1

    e2 = Graphs.add_edge!(hg, [:b, :c])
    @test e2 == 2
    @test Graphs.ne(hg) == 2

    # Add hyperedge with new vertex
    e3 = Graphs.add_edge!(hg, [:a, :c, :d])
    @test e3 == 3
    @test Graphs.nv(hg) == 4  # :d was added
    @test Graphs.ne(hg) == 3
end

@testset "Vertex queries" begin
    hg = HyperGraph{Int}()
    Graphs.add_edge!(hg, [1, 2, 3])
    Graphs.add_edge!(hg, [2, 3, 4])

    # Test vertices
    @test Graphs.vertices(hg) == [1, 2, 3, 4]
    @test Graphs.nv(hg) == 4

    # Test has_vertex
    @test Graphs.has_vertex(hg, 1) == true
    @test Graphs.has_vertex(hg, 2) == true
    @test Graphs.has_vertex(hg, 3) == true
    @test Graphs.has_vertex(hg, 4) == true
    @test Graphs.has_vertex(hg, 5) == false
    @test Graphs.has_vertex(hg, 0) == false
end

@testset "Edge queries" begin
    hg = HyperGraph{String}()
    Graphs.add_edge!(hg, ["a", "b", "c"])
    Graphs.add_edge!(hg, ["b", "c", "d"])
    Graphs.add_edge!(hg, ["a", "d"])

    # Test ne
    @test Graphs.ne(hg) == 3

    # Test edgetype
    @test Graphs.edgetype(hg) == BipartiteGraphs.HyperEdge{String}

    # Test has_edge with vector
    @test Graphs.has_edge(hg, ["a", "b", "c"]) == true
    @test Graphs.has_edge(hg, ["b", "c", "d"]) == true
    @test Graphs.has_edge(hg, ["a", "d"]) == true
    @test Graphs.has_edge(hg, ["a", "b"]) == false
    @test Graphs.has_edge(hg, ["a", "b", "c", "d"]) == false

    # Test has_edge with tuple
    @test Graphs.has_edge(hg, ("a", "b", "c")) == true
    @test Graphs.has_edge(hg, ("a", "b")) == false

    # Test has_edge with set
    @test Graphs.has_edge(hg, Set(["a", "b", "c"])) == true
    @test Graphs.has_edge(hg, Set(["a", "b"])) == false

    # Test has_edge with non-existent vertices
    @test Graphs.has_edge(hg, ["x", "y", "z"]) == false
end

@testset "Edge iteration" begin
    hg = HyperGraph{Symbol}()
    e1 = Graphs.add_edge!(hg, [:a, :b, :c])
    e2 = Graphs.add_edge!(hg, [:b, :c, :d])
    e3 = Graphs.add_edge!(hg, [:a, :d])

    edges = collect(Graphs.edges(hg))
    @test length(edges) == 3
    @test edges[1].id == 1
    @test Set(edges[1].vertices) == Set([:a, :b, :c])
    @test edges[2].id == 2
    @test Set(edges[2].vertices) == Set([:b, :c, :d])
    @test edges[3].id == 3
    @test Set(edges[3].vertices) == Set([:a, :d])

    # Test iterator protocol
    edge_iter = Graphs.edges(hg)
    @test length(edge_iter) == 3
    @test eltype(edge_iter) == BipartiteGraphs.HyperEdge{Symbol}
end

@testset "Edge removal" begin
    hg = HyperGraph{Int}()
    Graphs.add_edge!(hg, [1, 2, 3])
    Graphs.add_edge!(hg, [2, 3, 4])
    Graphs.add_edge!(hg, [1, 4])

    @test Graphs.ne(hg) == 3

    # Remove an edge by vertices
    @test Graphs.rem_edge!(hg, [2, 3, 4]) == true
    @test Graphs.ne(hg) == 2
    @test Graphs.has_edge(hg, [2, 3, 4]) == false
    @test Graphs.has_edge(hg, [1, 2, 3]) == true
    @test Graphs.has_edge(hg, [1, 4]) == true

    # Try to remove non-existent edge
    @test Graphs.rem_edge!(hg, [2, 3, 4]) == false
    @test Graphs.rem_edge!(hg, [5, 6]) == false

    # Remove edge by HyperEdge object
    edges = collect(Graphs.edges(hg))
    edge_to_remove = edges[1]
    @test Graphs.rem_edge!(hg, edge_to_remove) == true
    @test Graphs.ne(hg) == 1

    # Verify remaining edge
    remaining_edges = collect(Graphs.edges(hg))
    @test length(remaining_edges) == 1
    @test Set(remaining_edges[1].vertices) == Set([1, 4])
end

@testset "Graph properties" begin
    hg = HyperGraph{Float64}()

    # Test is_directed
    @test Graphs.is_directed(hg) == false
    @test Graphs.is_directed(typeof(hg)) == false

    # Test has_contiguous_vertices (if defined in Graphs)
    if isdefined(Graphs, :has_contiguous_vertices)
        @test Graphs.has_contiguous_vertices(typeof(hg)) == false
    end

    # Test length error
    @test_throws ErrorException length(hg)
end

@testset "Neighbors and incident edges" begin
    hg = HyperGraph{String}()
    Graphs.add_edge!(hg, ["a", "b", "c"])
    Graphs.add_edge!(hg, ["b", "c", "d"])
    Graphs.add_edge!(hg, ["a", "d", "e"])

    # Test neighbors by edge ID
    @test Set(BipartiteGraphs.neighbors(hg, 1)) == Set(["a", "b", "c"])
    @test Set(BipartiteGraphs.neighbors(hg, 2)) == Set(["b", "c", "d"])
    @test Set(BipartiteGraphs.neighbors(hg, 3)) == Set(["a", "d", "e"])

    # Test neighbors by HyperEdge
    edges = collect(Graphs.edges(hg))
    @test Set(BipartiteGraphs.neighbors(hg, edges[1])) == Set(["a", "b", "c"])

    # Test neighbors with invalid ID
    @test_throws BoundsError BipartiteGraphs.neighbors(hg, 10)

    # Test incident_edges
    incident_b = BipartiteGraphs.incident_edges(hg, "b")
    @test length(incident_b) == 2
    incident_b_sets = [Set(e.vertices) for e in incident_b]
    @test Set(["a", "b", "c"]) in incident_b_sets
    @test Set(["b", "c", "d"]) in incident_b_sets

    incident_a = BipartiteGraphs.incident_edges(hg, "a")
    @test length(incident_a) == 2
    incident_a_sets = [Set(e.vertices) for e in incident_a]
    @test Set(["a", "b", "c"]) in incident_a_sets
    @test Set(["a", "d", "e"]) in incident_a_sets

    incident_e = BipartiteGraphs.incident_edges(hg, "e")
    @test length(incident_e) == 1
    @test Set(incident_e[1].vertices) == Set(["a", "d", "e"])

    # Test incident_edges with non-existent vertex
    @test_throws ArgumentError BipartiteGraphs.incident_edges(hg, "z")
end

@testset "Empty graph" begin
    hg = HyperGraph{Symbol}()
    Graphs.add_edge!(hg, [:a, :b, :c])
    Graphs.add_edge!(hg, [:d, :e])

    @test Graphs.nv(hg) == 5
    @test Graphs.ne(hg) == 2

    # Empty the graph
    empty!(hg)

    @test Graphs.nv(hg) == 0
    @test Graphs.ne(hg) == 0
    @test length(Graphs.vertices(hg)) == 0
    @test length(collect(Graphs.edges(hg))) == 0

    # Can add to empty graph again
    Graphs.add_edge!(hg, [:x, :y])
    @test Graphs.nv(hg) == 2
    @test Graphs.ne(hg) == 1
end

@testset "HyperEdge equality and display" begin
    # Test HyperEdge equality
    e1 = BipartiteGraphs.HyperEdge(1, [1, 2, 3])
    e2 = BipartiteGraphs.HyperEdge(1, [1, 2, 3])
    e3 = BipartiteGraphs.HyperEdge(2, [1, 2, 3])
    e4 = BipartiteGraphs.HyperEdge(1, [1, 2, 4])

    @test e1 == e2
    @test e1 != e3  # different id
    @test e1 != e4  # different vertices

    # Test display (just ensure it doesn't error)
    io = IOBuffer()
    show(io, e1)
    str = String(take!(io))
    @test occursin("HyperEdge", str)
    @test occursin("1", str)
end

@testset "Edge iteration after removal" begin
    hg = HyperGraph{Int}()
    Graphs.add_edge!(hg, [1, 2])
    Graphs.add_edge!(hg, [3, 4])
    Graphs.add_edge!(hg, [5, 6])

    # Remove middle edge
    Graphs.rem_edge!(hg, [3, 4])

    # Iteration should skip empty edge
    edges = collect(Graphs.edges(hg))
    @test length(edges) == 2
    @test Graphs.ne(hg) == 2

    # Verify the remaining edges are correct
    edge_sets = [Set(e.vertices) for e in edges]
    @test Set([1, 2]) in edge_sets
    @test Set([5, 6]) in edge_sets
    @test !(Set([3, 4]) in edge_sets)
end

@testset "Different vertex types" begin
    # Test with strings
    hg_str = HyperGraph{String}()
    Graphs.add_edge!(hg_str, ["alice", "bob", "charlie"])
    @test Graphs.nv(hg_str) == 3
    @test Graphs.ne(hg_str) == 1

    # Test with symbols
    hg_sym = HyperGraph{Symbol}()
    Graphs.add_edge!(hg_sym, [:x, :y, :z])
    @test Graphs.nv(hg_sym) == 3
    @test Graphs.ne(hg_sym) == 1

    # Test with integers
    hg_int = HyperGraph{Int}()
    Graphs.add_edge!(hg_int, [10, 20, 30])
    @test Graphs.nv(hg_int) == 3
    @test Graphs.ne(hg_int) == 1

    # Test with tuples (as vertex type)
    hg_tuple = HyperGraph{Tuple{Int, Int}}()
    Graphs.add_edge!(hg_tuple, [(1, 1), (2, 2), (3, 3)])
    @test Graphs.nv(hg_tuple) == 3
    @test Graphs.ne(hg_tuple) == 1
end

@testset "Single vertex hyperedges" begin
    hg = HyperGraph{Int}()

    # Add hyperedge with single vertex
    e1 = Graphs.add_edge!(hg, [1])
    @test Graphs.ne(hg) == 1
    @test Graphs.nv(hg) == 1

    # Check edge exists
    @test Graphs.has_edge(hg, [1]) == true

    # Get neighbors
    @test BipartiteGraphs.neighbors(hg, 1) == [1]

    # Remove single vertex hyperedge
    @test Graphs.rem_edge!(hg, [1]) == true
    @test Graphs.ne(hg) == 0
end

@testset "Large hyperedges" begin
    hg = HyperGraph{Int}()

    # Create a large hyperedge
    vertices = collect(1:100)
    e1 = Graphs.add_edge!(hg, vertices)

    @test Graphs.nv(hg) == 100
    @test Graphs.ne(hg) == 1
    @test Graphs.has_edge(hg, vertices) == true
    @test length(BipartiteGraphs.neighbors(hg, 1)) == 100

    # All vertices should be incident to this edge
    for v in vertices
        incident = BipartiteGraphs.incident_edges(hg, v)
        @test length(incident) == 1
        @test incident[1].id == e1
    end
end

@testset "Empty hyperedge handling" begin
    hg = HyperGraph{Int}()

    # Add edges
    Graphs.add_edge!(hg, [1, 2])
    Graphs.add_edge!(hg, [3, 4])

    # Remove first edge
    Graphs.rem_edge!(hg, [1, 2])

    # Add new edge (should get ID 3, not reuse ID 1)
    e3 = Graphs.add_edge!(hg, [5, 6])
    @test e3 == 3

    # Verify edge count is correct
    @test Graphs.ne(hg) == 2

    # Verify iteration skips empty edge at ID 1
    edges = collect(Graphs.edges(hg))
    edge_ids = [e.id for e in edges]
    @test 1 ∉ edge_ids
    @test 2 in edge_ids
    @test 3 in edge_ids
end

@testset "Connected components" begin
    # Test 1: Single connected component
    hg1 = HyperGraph{String}()
    Graphs.add_edge!(hg1, ["a", "b", "c"])
    Graphs.add_edge!(hg1, ["c", "d"])
    Graphs.add_edge!(hg1, ["d", "e"])

    components1 = Graphs.connected_components(hg1)
    @test length(components1) == 1
    @test Set(components1[1]) == Set(["a", "b", "c", "d", "e"])

    # Test 2: Multiple disconnected components
    hg2 = HyperGraph{Int}()
    Graphs.add_edge!(hg2, [1, 2, 3])
    Graphs.add_edge!(hg2, [4, 5])
    Graphs.add_edge!(hg2, [6, 7, 8])

    components2 = Graphs.connected_components(hg2)
    @test length(components2) == 3

    # Convert to sets for comparison (order doesn't matter)
    comp_sets = [Set(c) for c in components2]
    @test Set([1, 2, 3]) in comp_sets
    @test Set([4, 5]) in comp_sets
    @test Set([6, 7, 8]) in comp_sets

    # Test 3: Components connected through a chain of hyperedges
    hg3 = HyperGraph{Symbol}()
    Graphs.add_edge!(hg3, [:a, :b])
    Graphs.add_edge!(hg3, [:b, :c])
    Graphs.add_edge!(hg3, [:c, :d])
    Graphs.add_edge!(hg3, [:x, :y])  # separate component

    components3 = Graphs.connected_components(hg3)
    @test length(components3) == 2

    comp_sets3 = [Set(c) for c in components3]
    @test Set([:a, :b, :c, :d]) in comp_sets3
    @test Set([:x, :y]) in comp_sets3

    # Test 4: Single vertex in a hyperedge
    hg4 = HyperGraph{String}()
    Graphs.add_edge!(hg4, ["a"])
    Graphs.add_edge!(hg4, ["b", "c"])

    components4 = Graphs.connected_components(hg4)
    @test length(components4) == 2

    comp_sets4 = [Set(c) for c in components4]
    @test Set(["a"]) in comp_sets4
    @test Set(["b", "c"]) in comp_sets4

    # Test 5: Empty graph
    hg5 = HyperGraph{Int}()
    components5 = Graphs.connected_components(hg5)
    @test length(components5) == 0
    @test components5 == []

    # Test 6: Components merge through a shared vertex
    hg6 = HyperGraph{Int}()
    Graphs.add_edge!(hg6, [1, 2])
    Graphs.add_edge!(hg6, [3, 4])
    Graphs.add_edge!(hg6, [2, 3])  # connects the two previous components
    Graphs.add_edge!(hg6, [5, 6])  # separate component

    components6 = Graphs.connected_components(hg6)
    @test length(components6) == 2

    comp_sets6 = [Set(c) for c in components6]
    @test Set([1, 2, 3, 4]) in comp_sets6
    @test Set([5, 6]) in comp_sets6

    # Test 7: Large hyperedge connecting multiple vertices
    hg7 = HyperGraph{String}()
    Graphs.add_edge!(hg7, ["a", "b", "c", "d", "e", "f"])
    Graphs.add_edge!(hg7, ["x", "y"])

    components7 = Graphs.connected_components(hg7)
    @test length(components7) == 2

    comp_sets7 = [Set(c) for c in components7]
    @test Set(["a", "b", "c", "d", "e", "f"]) in comp_sets7
    @test Set(["x", "y"]) in comp_sets7

    # Test 8: Graph with removed edges (empty hyperedges should be skipped)
    hg8 = HyperGraph{Symbol}()
    Graphs.add_edge!(hg8, [:a, :b])
    Graphs.add_edge!(hg8, [:c, :d])
    Graphs.add_edge!(hg8, [:e, :f])

    # Remove middle edge
    Graphs.rem_edge!(hg8, [:c, :d])

    components8 = Graphs.connected_components(hg8)
    @test length(components8) == 4  # a-b, c, d, e-f

    comp_sets8 = [Set(c) for c in components8]
    @test Set([:a, :b]) in comp_sets8
    @test Set([:c]) in comp_sets8
    @test Set([:d]) in comp_sets8
    @test Set([:e, :f]) in comp_sets8
end
