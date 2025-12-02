"""
    $(TYPEDEF)

A hypergraph represented using a [`BipartiteGraph`](@ref). Vertices of this graph are of
type `V`.

## Fields

$(TYPEDFIELDS)
"""
struct HyperGraph{V}
    """
    Mapping from vertices to their integer ID.
    """
    labels::Dict{V, Int}
    """
    Reverse mapping from integer ID to vertices.
    """
    invmap::Vector{V}
    """
    Core data structure for storing the hypergraph. Each hyperedge is a source vertex and
    has bipartite edges to the connection vertices it is incident on.
    """
    graph::BipartiteGraph{Int, Nothing}
end

"""
    $(TYPEDSIGNATURES)

Create an empty `ConnectionGraph`.
"""
function HyperGraph{V}() where {V}
    graph = BipartiteGraph(0, 0, Val(true))
    return HyperGraph{V}(Dict{V, Int}(), V[], graph)
end

"""
    $(TYPEDSIGNATURES)

Add the given vertex to the connection graph. Return the integer ID of the added vertex.
No-op if the vertex already exists.
"""
function Graphs.add_vertex!(graph::HyperGraph{V}, dst::V) where {V}
    j = get(graph.labels, dst, 0)
    iszero(j) || return j
    j = Graphs.add_vertex!(graph.graph, DST)
    push!(graph.invmap, dst)
    @assert length(graph.invmap) == j
    graph.labels[dst] = j
    return j
end

"""
    $TYPEDEF

Valid type to specify the edge of a `HyperGraph`.
"""
const HyperGraphEdge{V} = Union{Vector{V}, Tuple{Vararg{V}}, Set{V}}

"""
    $(TYPEDSIGNATURES)

Add the given hyperedge to the connection graph. Adds all vertices in the given edge if
they do not exist. Returns the integer ID of the added edge.
"""
function Graphs.add_edge!(graph::HyperGraph{V}, src::HyperGraphEdge{V}) where {V}
    i = Graphs.add_vertex!(graph.graph, SRC)
    for vert in src
        j = Graphs.add_vertex!(graph, vert)
        Graphs.add_edge!(graph.graph, i, j)
    end
    return i
end
