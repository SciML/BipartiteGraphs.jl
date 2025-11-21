using BipartiteGraphs
using Test

@testset "Unassigned type" begin
    @test unassigned isa Unassigned
    @test length(unassigned) == 1
    @test size(unassigned) == ()
    @test collect(unassigned) == [unassigned]
end

@testset "Matching construction" begin
    # Test empty matching
    m = Matching(5)
    @test length(m) == 5
    @test all(x -> x === unassigned, m)

    # Test from vector
    v = Union{Int, Unassigned}[1, unassigned, 3, unassigned, 5]
    m = Matching(v)
    @test m[1] == 1
    @test m[2] === unassigned
    @test m[3] == 3

    # Test type conversion
    m2 = Matching{Unassigned}(m)
    @test eltype(m2) == Union{Unassigned, Int}
end

@testset "Matching operations" begin
    m = Matching(5)

    # Test setindex!
    m[1] = 2
    @test m[1] == 2
    m[2] = unassigned
    @test m[2] === unassigned

    # Test push!
    push!(m, 3)
    @test length(m) == 6
    @test m[6] == 3

    # Test copy
    m_copy = copy(m)
    m_copy[1] = 10
    @test m[1] == 2  # Original unchanged
    @test m_copy[1] == 10

    # Test iteration
    @test collect(m) isa Vector
end

@testset "Matching completion" begin
    m = Matching(5)
    m[1] = 2
    m[2] = 1
    m[3] = 3

    # Complete the matching
    m_complete = complete(m, 3)
    @test m_complete.inv_match !== nothing
    @test m_complete.inv_match[2] == 1
    @test m_complete.inv_match[1] == 2
    @test m_complete.inv_match[3] == 3

    # Test invview
    m_inv = invview(m_complete)
    @test m_inv[2] == 1
    @test m_inv[1] == 2
end

@testset "Matching with inverse" begin
    m = Matching(5)
    m_complete = complete(m, 5)

    # Setting with inverse should update both
    m_complete[1] = 2
    @test m_complete[1] == 2
    @test m_complete.inv_match[2] == 1

    m_complete[1] = 3
    @test m_complete[1] == 3
    @test m_complete.inv_match[3] == 1
    @test m_complete.inv_match[2] === unassigned
end

@testset "Matching with custom unassigned type" begin
    m = Matching{Symbol}(3)
    @test length(m) == 3
    @test all(x -> x === unassigned, m)
end

@testset "Push! with inverse matching" begin
    m = Matching(2)
    m = complete(m, 2)
    push!(m, 1)
    @test length(m) == 3
    @test m[3] == 1
    @test m.inv_match[1] == 3
end

@testset "Setindex! edge cases" begin
    m = Matching(3)
    m = complete(m, 3)

    # Set to a value beyond current inv_match length
    m[1] = 5
    @test m[1] == 5
    @test length(m.inv_match) >= 5

    # Reassign
    m[2] = 5
    @test m[2] == 5
    @test m[1] === unassigned  # Previous assignment should be unassigned
end

@testset "Matching require_complete" begin
    m = Matching(3)
    @test_throws ArgumentError require_complete(m)

    m_complete = complete(m)
    require_complete(m_complete)  # Should not throw
    @test true
end
