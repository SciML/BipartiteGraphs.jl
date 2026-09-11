using BipartiteGraphs, BenchmarkTools
using StableRNGs

const SUITE = BenchmarkGroup()
const rng = StableRNG(123)

N = 1000
# Forward adjacency list: each source vertex connects to ~5 destinations
fadj = [unique!(sort!(rand(rng, 1:N, 5))) for _ in 1:N]
fadj_match = [unique!(sort!([i; rand(rng, 1:N, 3)])) for i in 1:N]

# =============================================================================
# Construction
# =============================================================================

SUITE["construct"] = BenchmarkGroup()

SUITE["construct"]["from_fadj"] = @benchmarkable BipartiteGraph($fadj)
SUITE["construct"]["from_fadj_complete"] = @benchmarkable complete(
    BipartiteGraph($fadj)
)
SUITE["construct"]["empty"] = @benchmarkable BipartiteGraph($N, $N)

g = complete(BipartiteGraph(fadj))
g_match = complete(BipartiteGraph(fadj_match))

# =============================================================================
# Matching
# =============================================================================

SUITE["matching"] = BenchmarkGroup()

SUITE["matching"]["maximal"] = @benchmarkable maximal_matching($g_match)

# =============================================================================
# Queries
# =============================================================================

SUITE["query"] = BenchmarkGroup()

SUITE["query"]["dneighbors"] = @benchmarkable 𝑑neighbors($g, 500)
SUITE["query"]["sneighbors"] = @benchmarkable 𝑠neighbors($g, 500)
SUITE["query"]["vertices"] = @benchmarkable collect(𝑠vertices($g))
