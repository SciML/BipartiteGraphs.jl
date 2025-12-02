# API Reference

## Bipartite Graphs

```@docs
BipartiteEdge
Graphs.src(::BipartiteEdge)
Graphs.dst(::BipartiteEdge)
BipartiteGraphs.VertType
BipartiteGraph
invview(::BipartiteGraph)
complete(::BipartiteGraph{I}) where {I}
require_complete(::BipartiteGraph)
Base.empty!(::BipartiteGraph)
𝑠vertices
𝑑vertices
has_𝑠vertex
has_𝑑vertex
𝑠neighbors
𝑑neighbors
𝑠edges
𝑑edges
Graphs.edges(::BipartiteGraph)
nsrcs
ndsts
Graphs.nv(::BipartiteGraph)
Graphs.vertices(::BipartiteGraph)
Graphs.add_edge!(::BipartiteGraph, ::Integer, ::Integer)
Graphs.add_edge!(::BipartiteGraph, ::BipartiteEdge)
Graphs.rem_edge!(::BipartiteGraph, ::Integer, ::Integer)
Graphs.rem_edge!(::BipartiteGraph, ::BipartiteEdge)
Graphs.add_vertex!(::BipartiteGraph{T}, ::BipartiteGraphs.VertType) where {T}
set_neighbors!
delete_srcs!
delete_dsts!
Graphs.incidence_matrix(::BipartiteGraph, ::Any)
```

## Maximal matching

```@docs
maximal_matching
construct_augmenting_path!
Matching
Unassigned
unassigned
Base.setindex!(::Matching{U}, ::Union{Integer, U}, ::Integer) where {U}
Base.push!(::Matching, ::Any)
complete(::Matching{U}, ::Any) where {U}
require_complete(::Matching)
invview(::Matching{U, V}) where {U, V}
```

## `DiCMOBiGraph`

```@docs
DiCMOBiGraph
DiCMOBiGraph{Transposed}(::BipartiteGraph) where {Transposed}
DiCMOBiGraph{Transposed}(::BipartiteGraph, ::M) where {Transposed, M}
invview(::DiCMOBiGraph{Transposed}) where {Transposed}
```

## Condensation graphs

```@docs
BipartiteGraphs.AbstractCondensationGraph
Graphs.nv(::BipartiteGraphs.AbstractCondensationGraph)
InducedCondensationGraph
MatchedCondensationGraph
```

## Hyper-graphs

```@docs
HyperGraph
Graphs.add_vertex!(::HyperGraph{V}, ::V) where {V}
Graphs.add_edge!(::HyperGraph{V}, ::BipartiteGraphs.HyperGraphEdge{V}) where {V}
```
