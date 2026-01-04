# Matrix whose only purpose is to pretty-print the bipartite graph

"""
A wrapper for adjacency lists used in pretty-printing bipartite graphs. Stores the
adjacency list along with optional highlighting information and matching status.
"""
struct BipartiteAdjacencyList
    u::Union{Vector{Int}, Nothing}
    highlight_u::Union{Set{Int}, Nothing}
    match::Any # Int or something else
end

"""
    $TYPEDSIGNATURES

Construct a [`BipartiteAdjacencyList`](@ref) without highlighting.
"""
function BipartiteAdjacencyList(u::Union{Vector{Int}, Nothing})
    return BipartiteAdjacencyList(u, nothing, unassigned)
end

"""
    overview_label(::Type{T}) where {T}
    overview_label(x) = overview_label(typeof(x))

Used for pretty-printing in `BipartiteAdjacencyList`. Given the type of
`BipartiteAdjacencyList.match`, returns a 3-tuple where the first element is
the symbol to print, the second element is a string describing what it means,
and the last element is the color to print it in.
"""
function overview_label end
overview_label(::Type) = error("No label defined for this matching type")
overview_label(x) = overview_label(typeof(x))

"""
A highlighted integer for pretty-printing, with color and matching status information.
"""
struct HighlightInt
    i::Int
    highlight::Symbol
    match::Bool
end
Base.typeinfo_implicit(::Type{HighlightInt}) = true
function Base.show(io::IO, hi::HighlightInt)
    return if hi.match
        printstyled(io, "(", color = hi.highlight)
        printstyled(io, hi.i, color = hi.highlight)
        printstyled(io, ")", color = hi.highlight)
    else
        printstyled(io, hi.i, color = hi.highlight)
    end
end

function Base.show(io::IO, l::BipartiteAdjacencyList)
    if !isa(l.match, Union{Int, Unassigned})
        (label, _, color) = overview_label(l.match)
        printstyled(io, string(label, " "); color)
    else
        printstyled(io, "  ")
    end
    return if l.u === nothing
        printstyled(io, '⋅', color = :light_black)
    elseif isempty(l.u)
        printstyled(io, '∅', color = :light_black)
    elseif l.highlight_u === nothing
        print(io, l.u)
    else
        match = l.match
        !isa(match, Int) && (match = unassigned)
        function choose_color(i)
            solvable = i in l.highlight_u
            matched = i == match
            return if !matched && solvable
                :default
            elseif !matched && !solvable
                :light_black
            elseif matched && solvable
                :light_yellow
            elseif matched && !solvable
                :magenta
            end
        end
        if !isempty(setdiff(l.highlight_u, l.u))
            # Only for debugging, shouldn't happen in practice
            print(
                io,
                map(union(l.u, l.highlight_u)) do i
                    HighlightInt(
                        i, !(i in l.u) ? :light_red : choose_color(i),
                        i == match
                    )
                end
            )
        else
            print(
                io, map(l.u) do i
                    HighlightInt(i, choose_color(i), i == match)
                end
            )
        end
    end
end

"""
A labeled string with an associated color for pretty-printing.
"""
struct Label
    s::String
    c::Symbol
end

"""
    $TYPEDSIGNATURES

Construct a label from a string without color.
"""
Label(s::AbstractString) = Label(s, :nothing)

"""
    $TYPEDSIGNATURES

Construct a label from an integer.
"""
Label(x::Integer) = Label(string(x))
Base.show(io::IO, l::Label) = printstyled(io, l.s, color = l.c)

"""
A matrix view of a [`BipartiteGraph`](@ref) for pretty-printing. Provides a tabular
representation with source and destination adjacency information.
"""
struct BipartiteGraphPrintMatrix <:
    AbstractMatrix{Union{Label, Int, BipartiteAdjacencyList}}
    bpg::BipartiteGraph
end
Base.size(bgpm::BipartiteGraphPrintMatrix) = (max(nsrcs(bgpm.bpg), ndsts(bgpm.bpg)) + 1, 3)
function Base.getindex(bgpm::BipartiteGraphPrintMatrix, i::Integer, j::Integer)
    checkbounds(bgpm, i, j)
    if i == 1
        return (Label.(("#", "src", "dst")))[j]
    elseif j == 1
        return i - 1
    elseif j == 2
        return BipartiteAdjacencyList(
            i - 1 <= nsrcs(bgpm.bpg) ?
                𝑠neighbors(bgpm.bpg, i - 1) : nothing
        )
    elseif j == 3
        return BipartiteAdjacencyList(
            i - 1 <= ndsts(bgpm.bpg) ?
                𝑑neighbors(bgpm.bpg, i - 1) : nothing
        )
    else
        @assert false
    end
end

function Base.show(io::IO, b::BipartiteGraph)
    print(
        io, "BipartiteGraph with (", length(b.fadjlist), ", ",
        isa(b.badjlist, Int) ? b.badjlist : length(b.badjlist), ") (𝑠,𝑑)-vertices\n"
    )
    return Base.print_matrix(io, BipartiteGraphPrintMatrix(b))
end

"""
    $TYPEDSIGNATURES

For a hypergraph with vertex type `V`, print to `io` a hint/label for the given edge
`edge_i`. No hint is printed by default.
"""
function print_hyperedge_hint(io::IO, ::Type{V}, graph::HyperGraph{V}, edge_i::Int) where {V} end

function Base.show(io::IO, graph::HyperGraph{V}) where {V}
    printstyled(io, get(io, :cgraph_name, "HyperGraph"); color = :blue, bold = true)
    println(
        io, " with ", length(graph.labels),
        " vertices and ", nsrcs(graph.graph), " hyperedges"
    )
    compact = get(io, :compact, false)
    for edge_i in 𝑠vertices(graph.graph)
        if compact && edge_i > 5
            println(io, "⋮")
            break
        end
        print(io, "  ")
        print_hyperedge_hint(io, V, graph, edge_i)
        edge_idxs = 𝑠neighbors(graph.graph, edge_i)
        print(io, "<")
        for vi in @view(edge_idxs[1:(end - 1)])
            print(io, graph.invmap[vi], ", ")
        end
        println(io, graph.invmap[edge_idxs[end]], ">")
    end
    return
end
