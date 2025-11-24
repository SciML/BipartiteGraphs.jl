using BipartiteGraphs
using Test

@testset "construct_augmenting_path!" begin
    # Simple matching scenario
    fadjlist = [[1], [2], [1, 2]]
    g = BipartiteGraph(fadjlist, 2)
    m = Matching(2)

    # Find augmenting path from source 1
    found = construct_augmenting_path!(m, g, 1, x -> true)
    @test found
    @test m[1] == 1

    # Reset and try from source 2
    m2 = Matching(2)
    found = construct_augmenting_path!(m2, g, 2, x -> true)
    @test found
    @test m2[2] == 2

    # Test with source 3 when dest 1 is already matched
    m3 = Matching(2)
    m3[1] = 1  # dest 1 is matched to source 1
    # Source 3 can connect to both 1 and 2, try to match to unassigned dest 2
    found = construct_augmenting_path!(m3, g, 3, x -> true)
    @test found  # Should match source 3 to dest 2 or reroute
end

@testset "maximal_matching" begin
    # Example from docs
    fadjlist = [[1], [1], [2], [2], [1], [1, 2]]
    g = BipartiteGraph(fadjlist, 2)

    m = maximal_matching(g)
    @test m isa Matching

    # Count matched vertices
    matched_count = count(x -> x isa Int, m)
    @test matched_count <= 2  # Can't match more than ndsts

    # Test with filters
    m2 = maximal_matching(g, s -> s <= 3, d -> true)
    @test m2 isa Matching

    # Test filtering out destination
    m3 = maximal_matching(g, s -> true, d -> d == 1)
    matched = [x for x in m3 if x isa Int]
    @test all(x == 1 for x in matched)
end

@testset "maximal_matching on larger graph" begin
    # More complex matching
    fadjlist = [[1, 2], [2, 3], [3, 4], [4, 5], [1, 5]]
    g = BipartiteGraph(fadjlist, 5)

    m = maximal_matching(g)
    matched_count = count(x -> x isa Int, m)
    @test matched_count >= 3  # Should find a good matching
end
