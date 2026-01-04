@deprecate maximal_matching(g::BipartiteGraph, srcfilter) maximal_matching(g; srcfilter)
@deprecate maximal_matching(g::BipartiteGraph, srcfilter, dstfilter) maximal_matching(g; srcfilter, dstfilter)
@deprecate maximal_matching(g::BipartiteGraph, srcfilter, dstfilter, T) maximal_matching(
    g, T; srcfilter, dstfilter
)
