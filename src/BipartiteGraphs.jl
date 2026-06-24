module BipartiteGraphs

using DocStringExtensions: DocStringExtensions, FIELDS, METHODLIST, TYPEDEF,
    TYPEDFIELDS, TYPEDSIGNATURES
using Graphs: Graphs, AbstractGraph, connected_components, dst, edges, edgetype,
    has_edge, has_vertex, inneighbors, ne, nv, outneighbors, src, vertices
using Graphs.SimpleGraphs: SimpleDiGraph, SimpleEdge, add_edge!, add_vertex!, rem_edge!
using DataStructures: DataStructures
# DataStructures renamed `IntDisjointSets` to `IntDisjointSet` in v0.19; alias both
# spellings to a single internal name so the explicit import is used on either version
# (and so the alias does not shadow the imported name, which would make ExplicitImports
# flag the import as stale).
@static if pkgversion(DataStructures) >= v"0.19"
    using DataStructures: IntDisjointSet as _IntDisjointSet
else
    using DataStructures: IntDisjointSets as _IntDisjointSet
end

export Matching, Unassigned, unassigned
include("matching.jl")

export BipartiteEdge, BipartiteGraph
export 𝑠vertices, 𝑑vertices, has_𝑠vertex, has_𝑑vertex, 𝑠neighbors, 𝑑neighbors,
    𝑠edges, 𝑑edges, nsrcs, ndsts, SRC, DST, set_neighbors!, invview,
    delete_srcs!, delete_dsts!, complete, require_complete
include("bipartite_graph.jl")

export maximal_matching, construct_augmenting_path!
include("maximal_matching.jl")

export DiCMOBiGraph
include("dicmobigraph.jl")

export InducedCondensationGraph, MatchedCondensationGraph
include("condensation_graphs.jl")

export HyperGraph, HyperEdge, HyperGraphEdge, neighbors, incident_edges
include("hypergraph.jl")

include("pretty_printing.jl")

include("deprecations.jl")

include("precompilation.jl")

end
