module BipartiteGraphsSparseArraysExt

using BipartiteGraphs
using Graphs
using SparseArrays: sparse

function Graphs.incidence_matrix(g::BipartiteGraph, val = true)
    I = Int[]
    J = Int[]
    for i in 𝑠vertices(g), n in 𝑠neighbors(g, i)

        push!(I, i)
        push!(J, n)
    end
    S = sparse(I, J, val, nsrcs(g), ndsts(g))
end

end
