# Set up the environment
ENV["DATADEPS_ALWAYS_ACCEPT"] = true
PKG_DIR = Base.current_project()
# cd(PKG_DIR)
using Pkg
if !isfile(joinpath(PKG_DIR, "Manifest.toml"))
    ## Required until the new version of ONNXRunTime is released
    Pkg.add(url = "https://github.com/svilupp/ONNXRunTime.jl", rev = "mac120")
    Pkg.instantiate()
end
Pkg.activate(PKG_DIR)
