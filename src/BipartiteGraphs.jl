module BipartiteGraphs

using DocStringExtensions
using UnPack
using Graphs

export Matching, Unassigned, unassigned
include("matching.jl")

export BipartiteEdge, BipartiteGraph
export 𝑠vertices, 𝑑vertices, has_𝑠vertex, has_𝑑vertex, 𝑠neighbors, 𝑑neighbors,
       𝑠edges, 𝑑edges, nsrcs, ndsts, SRC, DST, set_neighbors!, invview,
       delete_srcs!, delete_dsts!, complete, require_complete
include("bipartite_graph.jl")
include("pretty_printing.jl")

export maximal_matching, construct_augmenting_path!
include("maximal_matching.jl")

export DiCMOBiGraph
include("dicmobigraph.jl")

export InducedCondensationGraph, MatchedCondensationGraph
include("condensation_graphs.jl")

end
