"""
    struct DiCMOBiGraph

This data structure implements a "directed, contracted, matching-oriented" view of an
original (undirected) bipartite graph. It has two modes, depending on the `Transposed`
flag, which switches the direction of the induced matching.

Essentially the graph adapter performs two largely orthogonal functions
[`Transposed == true` differences are indicated in square brackets]:

 1. It pairs an undirected bipartite graph with a matching of the destination vertex.

    This matching is used to induce an orientation on the otherwise undirected graph:
    Matched edges pass from destination to source [source to destination], all other edges
    pass in the opposite direction.

 2. It exposes the graph view obtained by contracting the destination [source] vertices
    along the matched edges.

The result of this operation is an induced, directed graph on the source [destination] vertices.
The resulting graph has a few desirable properties. In particular, this graph
is acyclic if and only if the induced directed graph on the original bipartite
graph is acyclic.

# Hypergraph interpretation

Consider the bipartite graph `B` as the incidence graph of some hypergraph `H`.
Note that a matching `M` on `B` in the above sense is equivalent to determining
an (1,n)-orientation on the hypergraph (i.e. each directed hyperedge has exactly
one head, but any arbitrary number of tails). In this setting, this is simply
the graph formed by expanding each directed hyperedge into `n` ordinary edges
between the same vertices.
"""
mutable struct DiCMOBiGraph{Transposed, I, G <: BipartiteGraph{I}, M <: Matching} <:
               Graphs.AbstractGraph{I}
    graph::G
    ne::Union{Missing, Int}
    matching::M
    function DiCMOBiGraph{Transposed}(g::G, ne::Union{Missing, Int},
            m::M) where {Transposed, I, G <: BipartiteGraph{I}, M}
        new{Transposed, I, G, M}(g, ne, m)
    end
end

"""
    $TYPEDSIGNATURES

Construct a [`DiCMOBiGraph`](@ref) from a bipartite graph with an empty matching.
"""
function DiCMOBiGraph{Transposed}(g::BipartiteGraph) where {Transposed}
    DiCMOBiGraph{Transposed}(g, 0, Matching(ndsts(g)))
end

"""
    $TYPEDSIGNATURES

Construct a [`DiCMOBiGraph`](@ref) from a bipartite graph and a matching.
"""
function DiCMOBiGraph{Transposed}(g::BipartiteGraph, m::M) where {Transposed, M}
    DiCMOBiGraph{Transposed}(g, missing, m)
end

"""
    $TYPEDSIGNATURES

Return a [`DiCMOBiGraph`](@ref) with the source and destination vertices swapped. The
returned graph aliases `g`.
"""
function invview(g::DiCMOBiGraph{Transposed}) where {Transposed}
    DiCMOBiGraph{!Transposed}(invview(g.graph), g.ne, invview(g.matching))
end

Graphs.is_directed(::Type{<:DiCMOBiGraph}) = true
function Graphs.nv(g::DiCMOBiGraph{Transposed}) where {Transposed}
    Transposed ? ndsts(g.graph) : nsrcs(g.graph)
end
function Graphs.vertices(g::DiCMOBiGraph{Transposed}) where {Transposed}
    Transposed ? 𝑑vertices(g.graph) : 𝑠vertices(g.graph)
end

"""
    $TYPEDEF

An iterator for neighbors in a [`DiCMOBiGraph`](@ref).
"""
struct CMONeighbors{Transposed, V}
    g::DiCMOBiGraph{Transposed}
    """
    The vertex whose neighbors are being iterated over.
    """
    v::V
    function CMONeighbors{Transposed}(g::DiCMOBiGraph{Transposed},
            v::V) where {Transposed, V}
        new{Transposed, V}(g, v)
    end
end

Graphs.outneighbors(g::DiCMOBiGraph{false}, v) = CMONeighbors{false}(g, v)
Graphs.inneighbors(g::DiCMOBiGraph{false}, v) = inneighbors(invview(g), v)
Base.iterate(c::CMONeighbors{false}) = iterate(c, (c.g.graph.fadjlist[c.v],))
function Base.iterate(c::CMONeighbors{false}, (l, state...))
    while true
        r = iterate(l, state...)
        r === nothing && return nothing
        # If this is a matched edge, skip it, it's reversed in the induced
        # directed graph. Otherwise, if there is no matching for this destination
        # edge, also skip it, since it got deleted in the contraction.
        vsrc = c.g.matching[r[1]]
        if vsrc === c.v || !isa(vsrc, Int)
            state = (r[2],)
            continue
        end
        return vsrc, (l, r[2])
    end
end
Base.length(c::CMONeighbors{false}) = count(_ -> true, c)

@inline _vsrc(c::CMONeighbors{true}) = c.g.matching[c.v]
function _neighbors(c::CMONeighbors{true})
    vsrc = _vsrc(c)
    if vsrc isa Int
        return c.g.graph.fadjlist[vsrc]
    else
        return nothing
    end
end
function Base.length(c::CMONeighbors{true})
    nbors = _neighbors(c)
    length(@something(nbors, 1)) - 1
end

Graphs.inneighbors(g::DiCMOBiGraph{true}, v) = CMONeighbors{true}(g, v)
Graphs.outneighbors(g::DiCMOBiGraph{true}, v) = outneighbors(invview(g), v)
function Base.iterate(c::CMONeighbors{true})
    nbors = _neighbors(c)
    nbors === nothing && return nothing
    iterate(c, (nbors,))
end
function Base.iterate(c::CMONeighbors{true}, (l, state...))
    while true
        r = iterate(l, state...)
        r === nothing && return nothing
        if r[1] === c.v
            state = (r[2],)
            continue
        end
        return r[1], (l, r[2])
    end
end

function _edges(g::DiCMOBiGraph{Transposed}) where {Transposed}
    Transposed ?
    ((w => v for w in inneighbors(g, v)) for v in vertices(g)) :
    ((v => w for w in outneighbors(g, v)) for v in vertices(g))
end

Graphs.edges(g::DiCMOBiGraph) = (Graphs.SimpleEdge(p) for p in Iterators.flatten(_edges(g)))
function Graphs.ne(g::DiCMOBiGraph)
    if g.ne === missing
        g.ne = mapreduce(x -> length(x.iter), +, _edges(g))
    end
    return g.ne
end

Graphs.has_edge(g::DiCMOBiGraph{true}, a, b) = a in inneighbors(g, b)
Graphs.has_edge(g::DiCMOBiGraph{false}, a, b) = b in outneighbors(g, a)

# Required for `induced_subgraph` compatibility.
(::Type{<:DiCMOBiGraph})(n::Integer) = SimpleDiGraph(n)
