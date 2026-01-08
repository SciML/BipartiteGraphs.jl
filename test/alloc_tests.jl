using BipartiteGraphs
using Graphs
using BipartiteGraphs: 𝑠neighbors, 𝑑neighbors, construct_augmenting_path!, _always_true, nsrcs, ndsts

@testset "Allocation Tests - Zero Allocations in Hot Paths" begin
    # Test that construct_augmenting_path! doesn't allocate when called with pre-allocated buffers
    @testset "construct_augmenting_path! zero allocations" begin
        # Create a small test graph
        g = BipartiteGraph(10, 10)
        for i in 1:10
            for j in 1:10
                if (i + j) % 3 == 0
                    Graphs.add_edge!(g, i, j)
                end
            end
        end

        matching = Matching{Unassigned}(max(nsrcs(g), ndsts(g)))
        dcolor = falses(ndsts(g))

        # Warm up
        fill!(dcolor, false)
        construct_augmenting_path!(matching, g, 1, _always_true, dcolor, nothing)

        # Test that the function doesn't allocate
        fill!(dcolor, false)
        allocs = @allocated construct_augmenting_path!(matching, g, 1, _always_true, dcolor, nothing)
        @test allocs == 0
    end

    @testset "𝑠neighbors zero allocations" begin
        g = BipartiteGraph(10, 10)
        Graphs.add_edge!(g, 1, 1)
        Graphs.add_edge!(g, 1, 2)

        # Warm up
        𝑠neighbors(g, 1)

        # Test that 𝑠neighbors doesn't allocate
        allocs = @allocated 𝑠neighbors(g, 1)
        @test allocs == 0
    end

    @testset "𝑑neighbors zero allocations" begin
        g = BipartiteGraph(10, 10)
        Graphs.add_edge!(g, 1, 1)
        Graphs.add_edge!(g, 2, 1)

        # Warm up
        𝑑neighbors(g, 1)

        # Test that 𝑑neighbors doesn't allocate
        allocs = @allocated 𝑑neighbors(g, 1)
        @test allocs == 0
    end
end
