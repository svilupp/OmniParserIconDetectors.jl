using OmniParserIconDetectors
using Documenter

DocMeta.setdocmeta!(OmniParserIconDetectors, :DocTestSetup, :(using OmniParserIconDetectors); recursive=true)

makedocs(;
    modules=[OmniParserIconDetectors],
    authors="J S <49557684+svilupp@users.noreply.github.com> and contributors",
    sitename="OmniParserIconDetectors.jl",
    format=Documenter.HTML(;
        canonical="https://svilupp.github.io/OmniParserIconDetectors.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "API Reference" => "api.md"
    ],
)

deploydocs(;
    repo="github.com/svilupp/OmniParserIconDetectors.jl",
    devbranch="main",
)
