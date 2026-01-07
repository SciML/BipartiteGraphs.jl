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

        # Edge collection (triggers different code paths than iteration)
        collect(edges(bg))
        collect(𝑠edges(bg))
        collect(𝑑edges(bg))

        # Vertex collection
        collect(vertices(bg))

        # Maximal matching
        m = maximal_matching(bg)

        # Matching operations
        complete(m)
        copy(m)

        # DiCMOBiGraph
        dcmo = DiCMOBiGraph{false}(bg, m)
        vertices(dcmo)
        nv(dcmo)
        outneighbors(dcmo, 1)
        ne(dcmo)
        collect(edges(dcmo))

        dcmo_t = DiCMOBiGraph{true}(bg, complete(m, nsrcs(bg)))
        inneighbors(dcmo_t, 1)
        outneighbors(dcmo_t, 1)
        ne(dcmo_t)
        collect(edges(dcmo_t))

        # Empty graph construction
        empty_bg = BipartiteGraph(3, 2)

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
        collect(edges(hg))
        connected_components(hg)
    end
end
