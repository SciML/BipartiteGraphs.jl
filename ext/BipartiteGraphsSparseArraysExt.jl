module BipartiteGraphsSparseArraysExt

using BipartiteGraphs: BipartiteGraph, 𝑠vertices, 𝑠neighbors, nsrcs, ndsts
using Graphs: Graphs
using SparseArrays: sparse
using DocStringExtensions: TYPEDSIGNATURES

"""
    $TYPEDSIGNATURES

Obtain the incidence matrix for the [`BipartiteGraph`](@ref) `g`. `val` indicates the value
to be used in non-zero entries of the returned sparse matrix.
"""
function Graphs.incidence_matrix(g::BipartiteGraph, val = true)
    I = Int[]
    J = Int[]
    for i in 𝑠vertices(g), n in 𝑠neighbors(g, i)

        push!(I, i)
        push!(J, n)
    end
    return S = sparse(I, J, val, nsrcs(g), ndsts(g))
end

end
