using BipartiteGraphs
using SciMLTesting

# ExplicitImports only inspects an extension module once it exists, which requires the
# extension's trigger package to be loaded. Without loading the weakdeps here,
# BipartiteGraphsSparseArraysExt is silently skipped by the QA checks.
using SparseArrays

run_qa(BipartiteGraphs)
