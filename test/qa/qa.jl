using BipartiteGraphs
using Aqua
using JET
using Test

@testset "Aqua" begin
    Aqua.test_all(BipartiteGraphs)
end

@testset "JET" begin
    JET.test_package(BipartiteGraphs; target_defined_modules = true)
end
