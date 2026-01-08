"""
    construct_augmenting_path!(m::Matching, g::BipartiteGraph, vsrc, dstfilter, vcolor=falses(ndsts(g)), ecolor=nothing) -> path_found::Bool

Try to construct an augmenting path in matching and if such a path is found,
update the matching accordingly.
"""
function construct_augmenting_path!(
        matching::Matching, g::BipartiteGraph, vsrc::Int, dstfilter,
        dcolor = falses(ndsts(g)), scolor = nothing
    )
    scolor === nothing || (scolor[vsrc] = true)

    # if a `vdst` is unassigned and the edge `vsrc <=> vdst` exists
    for vdst in 𝑠neighbors(g, vsrc)
        if dstfilter(vdst) && matching[vdst] === unassigned
            matching[vdst] = vsrc
            return true
        end
    end

    # for every `vsrc` such that edge `vsrc <=> vdst` exists and `vdst` is uncolored
    for vdst in 𝑠neighbors(g, vsrc)
        (dstfilter(vdst) && !dcolor[vdst]) || continue
        dcolor[vdst] = true
        # Check if the matched source is an Int before recursing to ensure type stability
        matched_src = matching[vdst]
        if matched_src isa Int && construct_augmenting_path!(
                matching, g, matched_src, dstfilter, dcolor,
                scolor
            )
            matching[vdst] = vsrc
            return true
        end
    end
    return false
end

# Default filter that always returns true - defined as a type for specialization
struct AlwaysTrue <: Function end
(::AlwaysTrue)(x) = true
const _always_true = AlwaysTrue()

"""
    maximal_matching(g::BipartiteGraph, [srcfilter], [dstfilter])

For a bipartite graph `g`, construct a maximal matching of destination to source
vertices, subject to the constraint that vertices for which `srcfilter` or `dstfilter`,
return `false` may not be matched.
"""
function maximal_matching(
        g::BipartiteGraph, ::Type{U} = Unassigned; srcfilter = _always_true,
        dstfilter = _always_true
    ) where {U}
    matching = Matching{U}(max(nsrcs(g), ndsts(g)))
    # Pre-allocate dcolor buffer to avoid allocations in construct_augmenting_path!
    dcolor = falses(ndsts(g))
    for vsrc in Iterators.filter(srcfilter, 𝑠vertices(g))
        # Reset dcolor for each source vertex
        fill!(dcolor, false)
        construct_augmenting_path!(matching, g, vsrc, dstfilter, dcolor, nothing)
    end
    return matching
end
