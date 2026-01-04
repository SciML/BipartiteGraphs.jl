"""
Abstract base type for condensation graph representations.

```julia
    (::Type{<:AbstractCondensationGraph})(g, sccs::Vector{Vector{Int}})
```

Construct an [`AbstractCondensationGraph`](@ref) from a graph and strongly connected components.
"""
abstract type AbstractCondensationGraph <: AbstractGraph{Int} end
function (T::Type{<:AbstractCondensationGraph})(g, sccs::Vector{Union{Int, Vector{Int}}})
    scc_assignment = Vector{Int}(undef, isa(g, BipartiteGraph) ? ndsts(g) : nv(g))
    for (i, c) in enumerate(sccs)
        for v in c
            scc_assignment[v] = i
        end
    end
    return T(g, sccs, scc_assignment)
end
function (T::Type{<:AbstractCondensationGraph})(g, sccs::Vector{Vector{Int}})
    return T(g, Vector{Union{Int, Vector{Int}}}(sccs))
end

Graphs.is_directed(::Type{<:AbstractCondensationGraph}) = true

"""
    $TYPEDSIGNATURES

Get the number of vertices (strongly connected components) in the condensation graph.
"""
Graphs.nv(icg::AbstractCondensationGraph) = length(icg.sccs)
Graphs.vertices(icg::AbstractCondensationGraph) = Base.OneTo(nv(icg))

"""
    $TYPEDEF

For some bipartite-graph and an orientation induced on its destination contraction,
records the condensation DAG of the digraph formed by the orientation. I.e. this
is a DAG of connected components formed by the destination vertices of some
underlying bipartite graph.
N.B.: This graph does not store explicit neighbor relations of the sccs.
Therefor, the edge multiplicity is derived from the underlying bipartite graph,
i.e. this graph is not strict.
"""
struct MatchedCondensationGraph{G <: DiCMOBiGraph} <: AbstractCondensationGraph
    graph::G
    # Records the members of a strongly connected component. For efficiency,
    # trivial sccs (with one vertex member) are stored inline. Note: the sccs
    # here need not be stored in topological order.
    sccs::Vector{Union{Int, Vector{Int}}}
    # Maps the vertices back to the scc of which they are a part
    scc_assignment::Vector{Int}
end

function Graphs.outneighbors(mcg::MatchedCondensationGraph, cc::Integer)
    return Iterators.flatten(
        (
                mcg.scc_assignment[v′]
                for v′ in outneighbors(mcg.graph, v) if mcg.scc_assignment[v′] != cc
            )
            for v in mcg.sccs[cc]
    )
end

function Graphs.inneighbors(mcg::MatchedCondensationGraph, cc::Integer)
    return Iterators.flatten(
        (
                mcg.scc_assignment[v′]
                for v′ in inneighbors(mcg.graph, v) if mcg.scc_assignment[v′] != cc
            )
            for v in mcg.sccs[cc]
    )
end

"""
    $TYPEDEF

For some bipartite-graph and a topologicall sorted list of connected components,
represents the condensation DAG of the digraph formed by the orientation. I.e. this
is a DAG of connected components formed by the destination vertices of some
underlying bipartite graph.
N.B.: This graph does not store explicit neighbor relations of the sccs.
Therefor, the edge multiplicity is derived from the underlying bipartite graph,
i.e. this graph is not strict.
"""
struct InducedCondensationGraph{G <: BipartiteGraph} <: AbstractCondensationGraph
    graph::G
    # Records the members of a strongly connected component. For efficiency,
    # trivial sccs (with one vertex member) are stored inline. Note: the sccs
    # here are stored in topological order.
    sccs::Vector{Union{Int, Vector{Int}}}
    # Maps the vertices back to the scc of which they are a part
    scc_assignment::Vector{Int}
end

function _neighbors(icg::InducedCondensationGraph, cc::Integer)
    return Iterators.flatten(
        Iterators.flatten(
                icg.graph.fadjlist[vsrc]
                for vsrc in icg.graph.badjlist[v]
            )
            for v in icg.sccs[cc]
    )
end

function Graphs.outneighbors(icg::InducedCondensationGraph, v::Integer)
    return (icg.scc_assignment[n] for n in _neighbors(icg, v) if icg.scc_assignment[n] > v)
end

function Graphs.inneighbors(icg::InducedCondensationGraph, v::Integer)
    return (icg.scc_assignment[n] for n in _neighbors(icg, v) if icg.scc_assignment[n] < v)
end
