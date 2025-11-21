using BipartiteGraphs
using Test

@testset "BipartiteGraph printing" begin
    fadjlist = [[1, 2], [2]]
    badjlist = [[1], [1, 2]]
    g = BipartiteGraph(fadjlist, badjlist)

    # Test that show doesn't error
    io = IOBuffer()
    show(io, g)
    str = String(take!(io))
    @test contains(str, "BipartiteGraph")
    @test contains(str, "2")  # number of src or dst vertices
end

@testset "BipartiteEdge printing" begin
    e = BipartiteEdge(1, 2)
    io = IOBuffer()
    show(io, e)
    str = String(take!(io))
    @test contains(str, "src")
    @test contains(str, "dst")
    @test contains(str, "1")
    @test contains(str, "2")
end

@testset "Unassigned printing" begin
    io = IOBuffer()
    show(io, unassigned)
    str = String(take!(io))
    @test !isempty(str)
end

@testset "BipartiteAdjacencyList printing" begin
    # Test with nothing
    io = IOBuffer()
    bal = BipartiteGraphs.BipartiteAdjacencyList(nothing)
    show(io, bal)
    str = String(take!(io))
    @test !isempty(str)

    # Test with empty vector
    io = IOBuffer()
    bal = BipartiteGraphs.BipartiteAdjacencyList(Int[])
    show(io, bal)
    str = String(take!(io))
    @test !isempty(str)

    # Test with values
    io = IOBuffer()
    bal = BipartiteGraphs.BipartiteAdjacencyList([1, 2, 3])
    show(io, bal)
    str = String(take!(io))
    @test contains(str, "1")
end

@testset "Label printing" begin
    l = BipartiteGraphs.Label("test")
    io = IOBuffer()
    show(io, l)
    str = String(take!(io))
    @test contains(str, "test")
end
