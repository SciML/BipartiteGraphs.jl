using Documenter, BipartiteGraphs
import Graphs
import SparseArrays

const ExtMod = Base.get_extension(BipartiteGraphs, :BipartiteGraphsSparseArraysExt)
const REPO_ROOT = abspath(joinpath(@__DIR__, ".."))
const REPO_REMOTE = Documenter.Remotes.GitHub("SciML", "BipartiteGraphs.jl")
const REPO_COMMIT = readchomp(`git -C $REPO_ROOT rev-parse HEAD`)

cp("./docs/Manifest.toml", "./docs/src/assets/Manifest.toml", force = true)
cp("./docs/Project.toml", "./docs/src/assets/Project.toml", force = true)

makedocs(
    sitename = "BipartiteGraphs.jl",
    authors = "Chris Rackauckas",
    modules = [BipartiteGraphs, ExtMod],
    checkdocs = :exports,
    remotes = Dict(
        REPO_ROOT => (REPO_REMOTE, REPO_COMMIT),
    ),
    clean = true, doctest = true, linkcheck = true,
    format = Documenter.HTML(;
        assets = ["assets/favicon.ico"],
        canonical = "https://docs.sciml.ai/BipartiteGraphs/stable/",
        prettyurls = (get(ENV, "CI", nothing) == "true")
    ),
    pages = [
        "Home" => "index.md",
        "api.md",
    ]
)

deploydocs(
    repo = "github.com/SciML/BipartiteGraphs.jl.git";
    push_preview = true
)
