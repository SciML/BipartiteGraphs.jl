"""
    $TYPEDEF

A hyperedge in a [`HyperGraph`](@ref), represented as a set of vertices.
"""
struct HyperEdge{V}
    """
    The integer ID of this hyperedge in the underlying bipartite graph.
    """
    id::Int
    """
    The set of vertices in this hyperedge.
    """
    vertices::Vector{V}
end

Base.:(==)(a::HyperEdge, b::HyperEdge) = a.id == b.id && a.vertices == b.vertices

function Base.show(io::IO, edge::HyperEdge)
    print(io, "HyperEdge(", edge.id, ", ", edge.vertices, ")")
end

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

Base.eltype(::Type{<:HyperGraph{V}}) where {V} = V

if isdefined(Graphs, :has_contiguous_vertices)
    Graphs.has_contiguous_vertices(::Type{<:HyperGraph}) = false
end

"""
    $TYPEDSIGNATURES

Hypergraphs are undirected.
"""
Graphs.is_directed(::Type{<:HyperGraph}) = false

"""
    $TYPEDSIGNATURES

Get all vertices in the hypergraph.
"""
Graphs.vertices(g::HyperGraph) = g.invmap

"""
    $TYPEDSIGNATURES

Get the number of vertices in the hypergraph.
"""
Graphs.nv(g::HyperGraph) = length(g.invmap)

"""
    $TYPEDSIGNATURES

Check if vertex `v` exists in the hypergraph.
"""
Graphs.has_vertex(g::HyperGraph{V}, v::V) where {V} = haskey(g.labels, v)

"""
    $TYPEDSIGNATURES

Get the number of hyperedges in the hypergraph. Only counts non-empty hyperedges.
"""
function Graphs.ne(g::HyperGraph)
    count(!isempty ∘ Base.Fix1(𝑠neighbors, g.graph), 𝑠vertices(g.graph))
end

Graphs.edgetype(::HyperGraph{V}) where {V} = HyperEdge{V}

"""
    $METHODLIST

Check if a hyperedge exists in the hypergraph. The edge can be specified as a `HyperEdge`
or as a collection of vertices.
"""
function Graphs.has_edge(g::HyperGraph{V}, edge::HyperEdge{V}) where {V}
    edge.id in 𝑠vertices(g.graph) || return false
    Graphs.has_edge(g, edge.vertices)
end

function Graphs.has_edge(g::HyperGraph{V}, vertices::HyperGraphEdge{V}) where {V}
    _edge_idx(g, vertices) !== nothing
end

function _edge_idx(g::HyperGraph{V}, vertices::HyperGraphEdge{V}) where {V}
    # Check if all vertices exist
    all(Base.Fix1(haskey, g.labels), vertices) || return nothing
    # Convert to integer IDs
    vertex_ids = [g.labels[v] for v in vertices]
    sort!(vertex_ids)
    # Search through all hyperedges
    for i in 𝑠vertices(g.graph)
        neighbors = 𝑠neighbors(g.graph, i)
        if neighbors == vertex_ids
            return i
        end
    end
    return nothing
end

"""
    $METHODLIST

Remove a hyperedge from the hypergraph. The edge can be specified as a `HyperEdge` or as a
collection of vertices. Returns `true` if the edge was removed, `false` if it did not exist.
"""
function Graphs.rem_edge!(g::HyperGraph, edge::HyperEdge)
    edge.id in 𝑠vertices(g.graph) || return false
    # Remove all edges from this hyperedge to its vertices
    set_neighbors!(g.graph, edge.id, ())
    return true
end

function Graphs.rem_edge!(g::HyperGraph{V}, vertices::HyperGraphEdge{V}) where {V}
    # Find the hyperedge with these vertices
    idx = _edge_idx(g, vertices)
    if idx isa Int
        set_neighbors!(g.graph, idx, ())
        return true
    end
    return false
end

"""
    $TYPEDSIGNATURES

Iterate over all hyperedges in the hypergraph.
"""
Graphs.edges(g::HyperGraph{V}) where {V} = HyperEdgeIter(g)

"""
An iterator for hyperedges in a [`HyperGraph`](@ref).
"""
struct HyperEdgeIter{V, G <: HyperGraph{V}}
    g::G
end

Base.length(it::HyperEdgeIter) = Graphs.ne(it.g)
Base.eltype(it::HyperEdgeIter{V}) where {V} = HyperEdge{V}

function Base.iterate(it::HyperEdgeIter{V}, state = 1) where {V}
    (; g) = it
    nsrcs_val = nsrcs(g.graph)
    nsrcs_val == 0 && return nothing

    # Find the next non-empty hyperedge
    while state <= nsrcs_val
        neighbor_ids = 𝑠neighbors(g.graph, state)
        if !isempty(neighbor_ids)
            vertices = [g.invmap[j] for j in neighbor_ids]
            edge = HyperEdge(state, vertices)
            return edge, state + 1
        end
        state += 1
    end

    return nothing
end

"""
    $TYPEDSIGNATURES

Remove all hyperedges and vertices from the hypergraph.
"""
function Base.empty!(g::HyperGraph)
    empty!(g.labels)
    empty!(g.invmap)
    # Fully clear the underlying bipartite graph
    empty!(g.graph.fadjlist)
    if g.graph.badjlist isa AbstractVector
        empty!(g.graph.badjlist)
    else
        g.graph.badjlist = 0
    end
    g.graph.ne = 0
    return g
end

"""
    $TYPEDSIGNATURES

Get the vertices in a hyperedge (specified by its integer ID).
"""
function neighbors(g::HyperGraph, edge_id::Int)
    edge_id in 𝑠vertices(g.graph) || throw(BoundsError(g, edge_id))
    neighbor_ids = 𝑠neighbors(g.graph, edge_id)
    [g.invmap[j] for j in neighbor_ids]
end

"""
    $TYPEDSIGNATURES

Get the vertices in a hyperedge.
"""
neighbors(g::HyperGraph, edge::HyperEdge) = edge.vertices

"""
    $TYPEDSIGNATURES

Get all hyperedges that contain vertex `v`.
"""
function incident_edges(g::HyperGraph{V}, v::V) where {V}
    haskey(g.labels, v) || throw(ArgumentError("Vertex $v not in graph"))
    v_id = g.labels[v]
    edge_ids = 𝑑neighbors(g.graph, v_id)
    [HyperEdge(i, neighbors(g, i)) for i in edge_ids]
end

Base.length(::HyperGraph) = error("length is not well defined! Use `ne` or `nv`.")

"""
    $TYPEDSIGNATURES

Find the connected components of the given hypergraph.
"""
function Graphs.connected_components(graph::HyperGraph{V}) where {V}
    bigraph = graph.graph
    invmap = graph.invmap

    # union all of the hyperedges
    disjoint_sets = IntDisjointSet(length(invmap))
    for edge_i in 𝑠vertices(bigraph)
        hyperedge = 𝑠neighbors(bigraph, edge_i)
        isempty(hyperedge) && continue
        root, rest = Iterators.peel(hyperedge)
        for vert in rest
            union!(disjoint_sets, root, vert)
        end
    end

    # maps the root of a vertex in `disjoint_sets` to the index of the corresponding set
    # in `vertex_sets`
    root_to_set = Dict{Int, Int}()
    vertex_sets = Vector{V}[]
    for (vert_i, vert) in enumerate(invmap)
        root = DataStructures.find_root!(disjoint_sets, vert_i)
        set_i = get!(root_to_set, root) do
            push!(vertex_sets, V[])
            return length(vertex_sets)
        end
        push!(vertex_sets[set_i], vert)
    end

    return vertex_sets
end
