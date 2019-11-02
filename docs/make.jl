using Documenter, GenderDemoInertia

makedocs(;
    modules=[GenderDemoInertia],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/krishnab/GenderDemoInertia.jl/blob/{commit}{path}#L{line}",
    sitename="GenderDemoInertia.jl",
    authors="Krishna Bhogaonker",
    assets=String[],
)

deploydocs(;
    repo="github.com/krishnab/GenderDemoInertia.jl",
)
