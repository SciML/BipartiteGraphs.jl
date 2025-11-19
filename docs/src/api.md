# API Reference

## Bipartite Graphs

```@docs
BipartiteEdge
Graphs.src(::BipartiteEdge)
Graphs.dst(::BipartiteEdge)
BipartiteGraphs.VertType
BipartiteGraph
invview
complete
require_complete
Base.empty!(::BipartiteGraph)
𝑠vertices
𝑑vertices
has_𝑠vertex
has_𝑑vertex
𝑠neighbors
𝑑neighbors
Graphs.add_edge!(::BipartiteGraph, ::Integer, ::Integer)
Graphs.add_edge!(::BipartiteGraph, ::BipartiteEdge)
Graphs.rem_edge!(::BipartiteGraph, ::Integer, ::Integer)
Graphs.rem_edge!(::BipartiteGraph, ::BipartiteEdge)
Graphs.add_vertex!(::BipartiteGraph{T}, ::BipartiteGraphs.VertType)
set_neighbors!
delete_srcs!
delete_dsts!
```

## Maximal matching

```@docs
maximal_matching
construct_augmenting_path!
Matching
Unassigned
unassigned
```

## Other utilities

```@docs
DiCMOBiGraph
InducedCondensationGraph
MatchedCondensationGraph
```
