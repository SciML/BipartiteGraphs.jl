using BipartiteGraphs
using Graphs
using Test

@testset "MatchedCondensationGraph construction" begin
    fadjlist = [[1, 2], [2, 3], [3]]
    g = BipartiteGraph(fadjlist, 3)
    m = Matching(3)
    m[1] = 1
    m[2] = 2
    m[3] = 3

    dmog = DiCMOBiGraph{false}(complete(g), m)

    # Create SCCs
    sccs = [[1], [2], [3]]
    mcg = MatchedCondensationGraph(dmog, sccs)

    @test nv(mcg) == 3
    @test is_directed(mcg)
    @test vertices(mcg) == 1:3
end

@testset "InducedCondensationGraph construction" begin
    fadjlist = [[1, 2], [2, 3], [3]]
    g = BipartiteGraph(fadjlist, 3)

    sccs = [[1], [2], [3]]
    icg = InducedCondensationGraph(complete(g), sccs)

    @test nv(icg) == 3
    @test is_directed(icg)
    @test vertices(icg) == 1:3
end

@testset "Condensation graph with non-trivial SCCs" begin
    fadjlist = [[1, 2], [2, 3], [3, 1]]
    g = BipartiteGraph(fadjlist, 3)

    # All vertices in one SCC (cycle)
    sccs = [[1, 2, 3]]
    icg = InducedCondensationGraph(complete(g), sccs)

    @test nv(icg) == 1

    # Mixed: one non-trivial SCC and one singleton
    sccs2 = [[1, 2], [3]]
    icg2 = InducedCondensationGraph(complete(g), sccs2)
    @test nv(icg2) == 2
end

@testset "Neighbors in condensation graphs" begin
    fadjlist = [[1], [2], [1, 2]]
    g = BipartiteGraph(fadjlist, 2)

    sccs = [[1], [2]]  # Each dest is its own SCC
    icg = InducedCondensationGraph(complete(g), sccs)

    # Check that we can iterate neighbors
    out_neighs_1 = collect(outneighbors(icg, 1))
    @test out_neighs_1 isa Vector

    in_neighs_2 = collect(inneighbors(icg, 2))
    @test in_neighs_2 isa Vector
end

@testset "MatchedCondensationGraph neighbors" begin
    fadjlist = [[1, 2], [2, 3], [1, 3]]
    g = BipartiteGraph(fadjlist, 3)
    m = Matching(3)
    m[1] = 1
    m[2] = 2
    m[3] = 3
    m = complete(m, 3)  # Complete the matching

    dmog = DiCMOBiGraph{false}(complete(g), m)
    sccs = [[1], [2], [3]]
    mcg = MatchedCondensationGraph(dmog, sccs)

    # Test outneighbors iterator type
    out_neighs_iter = outneighbors(mcg, 1)
    @test out_neighs_iter isa Base.Iterators.Flatten

    # Test inneighbors iterator type
    in_neighs_iter = inneighbors(mcg, 1)
    @test in_neighs_iter isa Base.Iterators.Flatten
end

@testset "InducedCondensationGraph with mixed SCCs" begin
    fadjlist = [[1], [1, 2], [2, 3], [3]]
    g = BipartiteGraph(fadjlist, 3)

    # Test with Union type (int inline)
    sccs = Union{Int, Vector{Int}}[1, [2, 3]]
    icg = InducedCondensationGraph(complete(g), sccs)
    @test nv(icg) == 2
end
