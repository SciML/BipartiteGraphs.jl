using PrecompileTools

@setup_workload begin
    @compile_workload begin
        # Precompile BipartiteGraph construction and basic operations
        fadjlist = [[1], [1], [2], [2], [1], [1, 2]]
        badjlist = [[1, 2, 5, 6], [3, 4, 6]]

        # BipartiteGraph with full adjacency lists
        bg = BipartiteGraph(fadjlist, badjlist)

        # BipartiteGraph with just ndsts (incomplete)
        bg_incomplete = BipartiteGraph(fadjlist, 2)

        # Complete an incomplete graph
        bg_completed = complete(bg_incomplete)

        # Get vertices and edges
        𝑠vertices(bg)
        𝑑vertices(bg)
        nsrcs(bg)
        ndsts(bg)
        ne(bg)
        nv(bg)

        # Neighbors
        𝑠neighbors(bg, 1)
        𝑑neighbors(bg, 1)

        # Edge operations
        has_𝑠vertex(bg, 1)
        has_𝑑vertex(bg, 1)
        has_edge(bg, BipartiteEdge(1, 1))

        # invview
        inv_bg = invview(bg)

        # Edge iteration
        for edge in edges(bg)
        end
        for edge in 𝑠edges(bg)
        end
        for edge in 𝑑edges(bg)
        end

        # Maximal matching
        m = maximal_matching(bg)

        # Matching operations
        complete(m)
        copy(m)

        # DiCMOBiGraph construction (requires complete matching for some operations)
        m_complete = complete(m, nsrcs(bg))
        dcmo = DiCMOBiGraph{false}(bg, m_complete)
        vertices(dcmo)
        nv(dcmo)

        dcmo_t = DiCMOBiGraph{true}(bg, m_complete)

        # DiCMOBiGraph neighbor iteration (critical for TTFX)
        collect(outneighbors(dcmo, 1))
        collect(inneighbors(dcmo, 1))
        collect(outneighbors(dcmo_t, 1))
        collect(inneighbors(dcmo_t, 1))

        # DiCMOBiGraph edge iteration
        for edge in Graphs.edges(dcmo)
        end

        # Empty graph construction
        empty_bg = BipartiteGraph(3, 2)

        # Graph modification operations
        bg_mod = BipartiteGraph([[1, 2], [2, 3]], 3)
        bg_mod = complete(bg_mod)
        set_neighbors!(bg_mod, 1, [3])
        rem_edge!(bg_mod, 2, 2)
        add_edge!(bg_mod, 2, 2)

        # Condensation graphs
        cond_fadjlist = [[1, 2], [2, 3], [3]]
        cond_g = BipartiteGraph(cond_fadjlist, 3)
        cond_g = complete(cond_g)
        cond_m = Matching(3)
        cond_m[1] = 1
        cond_m[2] = 2
        cond_m[3] = 3
        cond_m_complete = complete(cond_m, 3)

        # MatchedCondensationGraph (requires complete matching)
        cond_dmog = DiCMOBiGraph{false}(cond_g, cond_m_complete)
        sccs = [[1], [2], [3]]
        mcg = MatchedCondensationGraph(cond_dmog, sccs)
        nv(mcg)
        vertices(mcg)
        collect(outneighbors(mcg, 1))
        collect(inneighbors(mcg, 1))

        # InducedCondensationGraph
        icg = InducedCondensationGraph(cond_g, sccs)
        nv(icg)
        vertices(icg)
        collect(outneighbors(icg, 1))
        collect(inneighbors(icg, 1))

        # HyperGraph
        hg = HyperGraph{Symbol}()
        add_vertex!(hg, :a)
        add_vertex!(hg, :b)
        add_vertex!(hg, :c)
        add_vertex!(hg, :d)
        add_edge!(hg, [:a, :b, :c])
        add_edge!(hg, [:b, :c, :d])
        vertices(hg)
        nv(hg)
        ne(hg)
        has_vertex(hg, :a)
        neighbors(hg, 1)
        incident_edges(hg, :a)
        for edge in edges(hg)
        end
        connected_components(hg)
    end
end
