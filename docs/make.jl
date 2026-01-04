using Documenter, BipartiteGraphs
import Graphs
import SparseArrays

const ExtMod = Base.get_extension(BipartiteGraphs, :BipartiteGraphsSparseArraysExt)

cp("./docs/Manifest.toml", "./docs/src/assets/Manifest.toml", force = true)
cp("./docs/Project.toml", "./docs/src/assets/Project.toml", force = true)

makedocs(
    sitename = "BipartiteGraphs.jl",
    authors = "Chris Rackauckas",
    modules = [BipartiteGraphs, ExtMod],
    clean = true, doctest = false, linkcheck = true,
    warnonly = [:docs_block, :missing_docs, :cross_references],
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
