"""
    @enum VertTyoe SRC DST

An enum for the two types of vertices (source and destination) in  a [`BipartiteGraph`](@ref).
"""
@enum VertType SRC DST

"""
    $TYPEDEF

The edge of a [`BipartiteGraph`](@ref). Use `Graphs.src` and `Graphs.dst` to get the source
and destination vertices.
"""
struct BipartiteEdge{I <: Integer} <: Graphs.AbstractEdge{I}
    src::I
    """
    The index of the destination vertex
    """
    dst::I
    function BipartiteEdge(src::I, dst::V) where {I, V}
        T = promote_type(I, V)
        new{T}(T(src), T(dst))
    end
end

"""
    $TYPEDSIGNATURES

Obtain the source vertex of a [`BipartiteEdge`](@ref).
"""
Graphs.src(edge::BipartiteEdge) = edge.src

"""
    $TYPEDSIGNATURES

Obtain the destination vertex of a [`BipartiteEdge`](@ref).
"""
Graphs.dst(edge::BipartiteEdge) = edge.dst

function Base.show(io::IO, edge::BipartiteEdge)
    @unpack src, dst = edge
    print(io, "[src: ", src, "] => [dst: ", dst, "]")
end

Base.:(==)(a::BipartiteEdge, b::BipartiteEdge) = src(a) == src(b) && dst(a) == dst(b)

"""
$(TYPEDEF)

A bipartite graph representation between two, possibly distinct, sets of vertices
(source and dependencies). Maps source vertices, labelled `1:N₁`, to vertices
on which they depend (labelled `1:N₂`).

# Fields
$(FIELDS)

# Example
```julia
using BipartiteGraphs

# six source vertices
fadjlist = [[1],[1],[2],[2],[1],[1,2]]

# two vertices they depend on
badjlist = [[1,2,5,6],[3,4,6]]

bg = BipartiteGraph(7, fadjlist, badjlist)
```
"""
mutable struct BipartiteGraph{I <: Integer, M} <: Graphs.AbstractGraph{I}
    ne::Int
    fadjlist::Vector{Vector{I}} # `fadjlist[src] => dsts`
    badjlist::Union{Vector{Vector{I}}, I} # `badjlist[dst] => srcs` or `ndsts`
    metadata::M
end

"""
    $METHODLIST

Construct a bipartite graph with `ne` edges, given the forward and backward
adjacency lists. Instead of the backward adjacency list, an integer may be given
indicating the number of destination vertices. If this is not provided, the number
of destination vertices is inferred from the forward adjacency list. If the backward
adjacency list is not provided, it will not be stored and instead backward adjacency
will be computed lazily. Use [`complete`](@ref) to compute and store
the backward adjacency post-facto. A completed graph offers faster backward adjacency
lookup at the cost of slower edge insertion.

`ne` may be omitted, in which case it is inferred from the forward adjacency list.
"""
function BipartiteGraph(ne::Integer, fadj::AbstractVector,
        badj::Union{AbstractVector, Integer} = maximum(maximum, fadj);
        metadata = nothing)
    BipartiteGraph(ne, fadj, badj, metadata)
end

function BipartiteGraph(fadj::AbstractVector,
        badj::Union{AbstractVector, Integer} = maximum(maximum, fadj);
        metadata = nothing)
    BipartiteGraph(mapreduce(length, +, fadj; init = 0), fadj, badj, metadata)
end

"""
    $TYPEDSIGNATURES

Utility function to throw an error if the graph `g` is not [`complete`](@ref).
"""
@noinline function require_complete(g::BipartiteGraph)
    g.badjlist isa AbstractVector ||
        throw(ArgumentError("The graph has no back edges. Use `complete`."))
end

"""
    $TYPEDSIGNATURES

Return a `BipartiteGraph` with the source and destination vertices swapped. Note that the
returned graph aliases `g`. Requires that `g` is [`complete`](@ref).
"""
function invview(g::BipartiteGraph)
    require_complete(g)
    BipartiteGraph(g.ne, g.badjlist, g.fadjlist)
end

"""
    $TYPEDSIGNATURES

Populate the backward adjacency list of `g`, if it is not already stored.
"""
function complete(g::BipartiteGraph{I}) where {I}
    isa(g.badjlist, AbstractVector) && return g
    badjlist = Vector{I}[Vector{I}() for _ in 1:(g.badjlist)]
    for (s, l) in enumerate(g.fadjlist)
        for d in l
            push!(badjlist[d], s)
        end
    end
    BipartiteGraph(g.ne, g.fadjlist, badjlist)
end

"""
    $TYPEDSIGNATURES

Test whether two [`BipartiteGraph`](@ref)s are equal.
"""
function Base.isequal(bg1::BipartiteGraph{T}, bg2::BipartiteGraph{T}) where {T <: Integer}
    iseq = (bg1.ne == bg2.ne)
    iseq &= (bg1.fadjlist == bg2.fadjlist)
    iseq &= (bg1.badjlist == bg2.badjlist)
    iseq
end

"""
    $(TYPEDSIGNATURES)

Build an empty [`BipartiteGraph`](@ref) with `nsrcs` sources and `ndsts` destinations.
By default, the constructed graph is [`complete`](@ref)d. To avoid this
and lazily compute backward adjacency, pass `Val(false)` as the third argument.
"""
function BipartiteGraph(nsrcs::T, ndsts::T, backedge::Val{B} = Val(true);
        metadata = nothing) where {T, B}
    fadjlist = map(_ -> T[], 1:nsrcs)
    badjlist = B ? map(_ -> T[], 1:ndsts) : ndsts
    BipartiteGraph(0, fadjlist, badjlist, metadata)
end

function Base.copy(bg::BipartiteGraph)
    BipartiteGraph(bg.ne, map(copy, bg.fadjlist), map(copy, bg.badjlist),
        deepcopy(bg.metadata))
end
Base.eltype(::Type{<:BipartiteGraph{I}}) where {I} = I

"""
    $TYPEDSIGNATURES

Remove all edges from the graph, retaining the source and destination vertices.
"""
function Base.empty!(g::BipartiteGraph)
    foreach(empty!, g.fadjlist)
    g.badjlist isa AbstractVector && foreach(empty!, g.badjlist)
    g.ne = 0
    if g.metadata !== nothing
        foreach(empty!, g.metadata)
    end
    g
end
Base.length(::BipartiteGraph) = error("length is not well defined! Use `ne` or `nv`.")

if isdefined(Graphs, :has_contiguous_vertices)
    Graphs.has_contiguous_vertices(::Type{<:BipartiteGraph}) = false
end
Graphs.is_directed(::Type{<:BipartiteGraph}) = false

"""
    $TYPEDSIGNATURES

Obtain both source and destination vertices of the graph as a tuple.
"""
Graphs.vertices(g::BipartiteGraph) = (𝑠vertices(g), 𝑑vertices(g))
"""
    $TYPEDSIGNATURES

Obtain the number of source vertices in the graph.
"""
𝑠vertices(g::BipartiteGraph) = axes(g.fadjlist, 1)
"""
    $TYPEDSIGNATURES

Obtain the number of destination vertices in the graph.
"""
function 𝑑vertices(g::BipartiteGraph)
    g.badjlist isa AbstractVector ? axes(g.badjlist, 1) : Base.OneTo(g.badjlist)
end
"""
    $TYPEDSIGNATURES

Check if `v` is a source vertex of `g`.
"""
has_𝑠vertex(g::BipartiteGraph, v::Integer) = v in 𝑠vertices(g)
"""
    $TYPEDSIGNATURES

Check if `v` is a destination vertex of `g`.
"""
has_𝑑vertex(g::BipartiteGraph, v::Integer) = v in 𝑑vertices(g)
"""
    $TYPEDSIGNATURES

Obtain the neighbors of source vertex `i` in graph `g`.
"""
function 𝑠neighbors(g::BipartiteGraph, i::Integer,
        with_metadata::Val{M} = Val(false)) where {M}
    M ? zip(g.fadjlist[i], g.metadata[i]) : g.fadjlist[i]
end
"""
    $TYPEDSIGNATURES

Obtain the neighbors of destination vertex `i` in graph `g`.
"""
function 𝑑neighbors(g::BipartiteGraph, j::Integer,
        with_metadata::Val{M} = Val(false)) where {M}
    require_complete(g)
    backj = g.badjlist[j]::Vector{Int}
    M ? zip(backj, (g.metadata[i][j] for i in backj)) : backj
end
Graphs.ne(g::BipartiteGraph) = g.ne

"""
    $TYPEDSIGNATURES

Get the total number of vertices (source and destination) in the graph.
"""
Graphs.nv(g::BipartiteGraph) = sum(length, vertices(g))
Graphs.edgetype(g::BipartiteGraph{I}) where {I} = BipartiteEdge{I}

"""
    $TYPEDSIGNATURES

Get the number of source vertices in the graph.
"""
nsrcs(g::BipartiteGraph) = length(𝑠vertices(g))

"""
    $TYPEDSIGNATURES

Get the number of destination vertices in the graph.
"""
ndsts(g::BipartiteGraph) = length(𝑑vertices(g))

function Graphs.has_edge(g::BipartiteGraph, edge::BipartiteEdge)
    @unpack src, dst = edge
    (src in 𝑠vertices(g) && dst in 𝑑vertices(g)) || return false  # edge out of bounds
    insorted(dst, 𝑠neighbors(g, src))
end
Base.in(edge::BipartiteEdge, g::BipartiteGraph) = Graphs.has_edge(g, edge)

struct NoMetadata end
const NO_METADATA = NoMetadata()

"""
    $TYPEDSIGNATURES

Add an edge from source `i` to destination `j` in graph `g`.
"""
function Graphs.add_edge!(g::BipartiteGraph, i::Integer, j::Integer, md = NO_METADATA)
    add_edge!(g, BipartiteEdge(i, j), md)
end
"""
    $TYPEDSIGNATURES

Add `edge` to graph `g`.
"""
function Graphs.add_edge!(g::BipartiteGraph, edge::BipartiteEdge, md = NO_METADATA)
    @unpack fadjlist, badjlist = g
    s, d = src(edge), dst(edge)
    (has_𝑠vertex(g, s) && has_𝑑vertex(g, d)) || error("edge ($edge) out of range.")
    @inbounds list = fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) && return false  # edge already in graph
    insert!(list, index, d)
    if md !== NO_METADATA
        insert!(g.metadata[s], index, md)
    end

    g.ne += 1
    if badjlist isa AbstractVector
        @inbounds list = badjlist[d]
        index = searchsortedfirst(list, s)
        insert!(list, index, s)
    end
    return true  # edge successfully added
end

"""
    $TYPEDSIGNATURES

Remove the edge from source `i` to destination `j` in graph `g`.
"""
function Graphs.rem_edge!(g::BipartiteGraph, i::Integer, j::Integer)
    Graphs.rem_edge!(g, BipartiteEdge(i, j))
end
"""
    $TYPEDSIGNATURES

Femove `edge` from graph `g`.
"""
function Graphs.rem_edge!(g::BipartiteGraph, edge::BipartiteEdge)
    @unpack fadjlist, badjlist = g
    s, d = src(edge), dst(edge)
    (has_𝑠vertex(g, s) && has_𝑑vertex(g, d)) || error("edge ($edge) out of range.")
    @inbounds list = fadjlist[s]
    index = searchsortedfirst(list, d)
    @inbounds (index <= length(list) && list[index] == d) ||
              error("graph does not have edge $edge")
    deleteat!(list, index)
    g.ne -= 1
    if badjlist isa AbstractVector
        @inbounds list = badjlist[d]
        index = searchsortedfirst(list, s)
        deleteat!(list, index)
    end
    return true  # edge successfully deleted
end

"""
    $TYPEDSIGNATURES

Add a vertex of type `type` to graph `g`.
"""
function Graphs.add_vertex!(g::BipartiteGraph{T}, type::VertType) where {T}
    if type === DST
        if g.badjlist isa AbstractVector
            push!(g.badjlist, T[])
            return length(g.badjlist)
        else
            g.badjlist += 1
            return g.badjlist
        end
    elseif type === SRC
        push!(g.fadjlist, T[])
        return length(g.fadjlist)
    else
        error("type ($type) must be either `DST` or `SRC`")
    end
end

"""
    $TYPEDSIGNATURES

In graph `g`, set the neighbors of source vertex `i` to `new_neighbors`.
"""
function set_neighbors!(g::BipartiteGraph, i::Integer, new_neighbors)
    old_neighbors = g.fadjlist[i]
    old_nneighbors = length(old_neighbors)
    new_nneighbors = length(new_neighbors)
    g.ne += new_nneighbors - old_nneighbors
    if isa(g.badjlist, AbstractVector)
        for n in old_neighbors
            @inbounds list = g.badjlist[n]
            index = searchsortedfirst(list, i)
            if 1 <= index <= length(list) && list[index] == i
                deleteat!(list, index)
            end
        end
        for n in new_neighbors
            @inbounds list = g.badjlist[n]
            index = searchsortedfirst(list, i)
            if !(1 <= index <= length(list) && list[index] == i)
                insert!(list, index, i)
            end
        end
    end
    if iszero(new_nneighbors) # this handles Tuple as well
        # Warning: Aliases old_neighbors
        empty!(g.fadjlist[i])
    else
        g.fadjlist[i] = unique!(sort(new_neighbors))
    end
end

"""
    $TYPEDSIGNATURES

In graph `g`, remove all edges incident on source vertices in `srcs`. If `rm_verts` is
`true`, also remove the vertices from the graph. Note that this will cause
renumbering of source vertices.
"""
function delete_srcs!(g::BipartiteGraph{I}, srcs; rm_verts = false) where {I}
    for s in srcs
        set_neighbors!(g, s, ())
    end
    if rm_verts
        old_to_new_idxs = collect(one(I):I(nsrcs(g)))
        for s in srcs
            old_to_new_idxs[s] = zero(I)
        end
        offset = zero(I)
        for i in eachindex(old_to_new_idxs)
            if iszero(old_to_new_idxs[i])
                offset += one(I)
                continue
            end
            old_to_new_idxs[i] -= offset
        end

        if g.badjlist isa AbstractVector
            for i in 1:ndsts(g)
                for j in eachindex(g.badjlist[i])
                    g.badjlist[i][j] = old_to_new_idxs[g.badjlist[i][j]]
                end
                filter!(!iszero, g.badjlist[i])
            end
        end
        deleteat!(g.fadjlist, srcs)
    end
    g
end

"""
    $TYPEDSIGNATURES

In graph `g`, remove all edges incident on destination vertices in `srcs`. If `rm_verts` is
`true`, also remove the vertices from the graph. Note that this will cause
renumbering of destination vertices.
"""
function delete_dsts!(g::BipartiteGraph, srcs; rm_verts = false)
    delete_srcs!(invview(g), srcs; rm_verts)
end

###
### Edges iteration
###

"""
    $TYPEDSIGNATURES

Iterate over all edges in the graph, ordered by source vertices.
"""
Graphs.edges(g::BipartiteGraph) = BipartiteEdgeIter(g, Val(SRC))

"""
    $TYPEDSIGNATURES

Iterate over all edges in the graph, ordered by source vertices.
"""
𝑠edges(g::BipartiteGraph) = BipartiteEdgeIter(g, Val(SRC))

"""
    $TYPEDSIGNATURES

Iterate over all edges in the graph, ordered by destination vertices.
"""
𝑑edges(g::BipartiteGraph) = BipartiteEdgeIter(g, Val(DST))

"""
An iterator for edges in a [`BipartiteGraph`](@ref). The iteration order depends on the
`type` parameter: `Val(SRC)` iterates by source vertices, `Val(DST)` iterates by destination vertices.
"""
struct BipartiteEdgeIter{T, G} <: Graphs.AbstractEdgeIter
    g::G
    type::Val{T}
end

Base.length(it::BipartiteEdgeIter) = ne(it.g)
Base.eltype(it::BipartiteEdgeIter) = edgetype(it.g)

function Base.iterate(it::BipartiteEdgeIter{SRC, <:BipartiteGraph{T}},
        state = (1, 1, SRC)) where {T}
    @unpack g = it
    neqs = nsrcs(g)
    neqs == 0 && return nothing
    eq, jvar = state

    while eq <= neqs
        eq′ = eq
        vars = 𝑠neighbors(g, eq′)
        if jvar > length(vars)
            eq += 1
            jvar = 1
            continue
        end
        edge = BipartiteEdge(eq′, vars[jvar])
        state = (eq, jvar + 1, SRC)
        return edge, state
    end
    return nothing
end

function Base.iterate(it::BipartiteEdgeIter{DST, <:BipartiteGraph{T}},
        state = (1, 1, DST)) where {T}
    @unpack g = it
    nvars = ndsts(g)
    nvars == 0 && return nothing
    ieq, jvar = state

    while jvar <= nvars
        eqs = 𝑑neighbors(g, jvar)
        if ieq > length(eqs)
            ieq = 1
            jvar += 1
            continue
        end
        edge = BipartiteEdge(eqs[ieq], jvar)
        state = (ieq + 1, jvar, DST)
        return edge, state
    end
    return nothing
end
