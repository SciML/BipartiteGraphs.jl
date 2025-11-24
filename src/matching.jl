"""
A sentinel type representing an unassigned vertex in a matching.
"""
struct Unassigned end

"""
A singleton instance representing unassigned vertices.
"""
const unassigned = Unassigned.instance

# Behaves as a scalar
Base.length(u::Unassigned) = 1
Base.size(u::Unassigned) = ()
Base.iterate(u::Unassigned) = (unassigned, nothing)
Base.iterate(u::Unassigned, state) = nothing

Base.show(io::IO, ::Unassigned) = printstyled(io, "u"; color = :light_black)

#U=> :Unassigned =#

"""
A matching between two sets of vertices in a bipartite graph. Maps destination vertices
to their matched source vertices. `U` denotes the type that unmatched variables can take.
Typically, this will be [`Unassigned`](@ref) but other types can be used for more
complicated matchings.
"""
struct Matching{U, V <: AbstractVector} <: AbstractVector{Union{U, Int}}
    match::V
    inv_match::Union{Nothing, V}
end
# These constructors work around https://github.com/JuliaLang/julia/issues/41948
"""
    $TYPEDSIGNATURES

Convert a matching to have element type `Union{V, Int}`.
"""
function Matching{V}(m::Matching) where {V}
    eltype(m) === Union{V, Int} && return m
    VUT = typeof(similar(m.match, Union{V, Int}))
    Matching{V}(convert(VUT, m.match),
        m.inv_match === nothing ? nothing : convert(VUT, m.inv_match))
end

"""
    $TYPEDSIGNATURES

Identity constructor for a matching.
"""
Matching(m::Matching) = m

"""
    $TYPEDSIGNATURES

Construct a matching from a vector without the inverse matching. The inverse matching can
be calculated using [`complete`](@ref).
"""
Matching{U}(v::V) where {U, V <: AbstractVector} = Matching{U, V}(v, nothing)

"""
    $TYPEDSIGNATURES

Construct a matching from forward and inverse matchings.
"""
function Matching{U}(v::V, iv::Union{V, Nothing}) where {U, V <: AbstractVector}
    Matching{U, V}(v, iv)
end

"""
    $TYPEDSIGNATURES

Construct a matching from a vector, inferring the unassigned type. The inverse matching
is not stored.
"""
function Matching(v::V) where {U, V <: AbstractVector{Union{U, Int}}}
    Matching{@isdefined(U) ? U : Unassigned, V}(v, nothing)
end

"""
    $TYPEDSIGNATURES

Construct an empty matching with `m` vertices, all unassigned. The inverse matching is not
stored.
"""
function Matching(m::Int)
    Matching{Unassigned}(Union{Int, Unassigned}[unassigned for _ in 1:m], nothing)
end

"""
    $TYPEDSIGNATURES

Construct an empty matching with `m` vertices and custom unassigned type `U`.
"""
function Matching{U}(m::Int) where {U}
    Matching{Union{Unassigned, U}}(Union{Int, Unassigned, U}[unassigned for _ in 1:m],
        nothing)
end

Base.size(m::Matching) = Base.size(m.match)
Base.getindex(m::Matching, i::Integer) = m.match[i]
Base.iterate(m::Matching, state...) = iterate(m.match, state...)
function Base.copy(m::Matching{U}) where {U}
    Matching{U}(copy(m.match), m.inv_match === nothing ? nothing : copy(m.inv_match))
end

"""
    $TYPEDSIGNATURES

Update `i` to match to `v` in matching `m`. Also updates the inverse matching, if present.
"""
function Base.setindex!(m::Matching{U}, v::Union{Integer, U}, i::Integer) where {U}
    if m.inv_match !== nothing
        oldv = m.match[i]
        # TODO: maybe default Matching to always have an `inv_match`?

        # To maintain the invariant that `m.inv_match[m.match[i]] == i`, we need
        # to unassign the matching at `m.inv_match[v]` if it exists.
        if v isa Int && 1 <= v <= length(m.inv_match) && (iv = m.inv_match[v]) isa Int
            m.match[iv] = unassigned
        end
        if isa(oldv, Int)
            @assert m.inv_match[oldv] == i
            m.inv_match[oldv] = unassigned
        end
        if isa(v, Int)
            for vv in (length(m.inv_match) + 1):v
                push!(m.inv_match, unassigned)
            end
            m.inv_match[v] = i
        end
    end
    return m.match[i] = v
end

"""
    $TYPEDSIGNATURES

Append an element to the source vertices of the matching `m`, and match it to `v`.
"""
function Base.push!(m::Matching, v)
    push!(m.match, v)
    if v isa Integer && m.inv_match !== nothing
        for vv in (length(m.inv_match) + 1):v
            push!(m.inv_match, unassigned)
        end
        m.inv_match[v] = length(m.match)
    end
end

"""
    $TYPEDSIGNATURES

Populate the inverse matching if it is not already computed. The optional parameter `N`
specifies the size of the inverse matching vector.
"""
function complete(m::Matching{U},
        N = maximum((x for x in m.match if isa(x, Int)); init = 0)) where {U}
    m.inv_match !== nothing && return m
    inv_match = Union{U, Int}[unassigned for _ in 1:N]
    for (i, eq) in enumerate(m.match)
        isa(eq, Int) || continue
        inv_match[eq] = i
    end
    return Matching{U}(collect(m.match), inv_match)
end

"""
    $TYPEDSIGNATURES

Throw an error if the matching does not have the inverse matching computed.
"""
@noinline function require_complete(m::Matching)
    m.inv_match === nothing &&
        throw(ArgumentError("Backwards matching not defined. `complete` the matching first."))
end

"""
    $TYPEDSIGNATURES

Return a view of the matching with the forward and inverse matchings swapped.
Requires that the matching is [`complete`](@ref).
"""
function invview(m::Matching{U, V}) where {U, V}
    require_complete(m)
    return Matching{U, V}(m.inv_match, m.match)
end
