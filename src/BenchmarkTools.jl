module BenchmarkTools

using Compat

typealias Tag UTF8String

##############
# Parameters #
##############

include("parameters.jl")

##############
# Trial Data #
##############

include("trials.jl")

export gctime,
       memory,
       allocs,
       tolerance,
       ratio,
       judge,
       isinvariant,
       isregression,
       isimprovement,
       rmoutliers!,
       rmoutliers

##################
# Benchmark Data #
##################

include("groups.jl")

export BenchmarkGroup,
       invariants,
       regressions,
       improvements,
       @tagged

######################
# Execution Strategy #
######################

include("execution.jl")

export tune!,
       @benchmark,
       @benchmarkable

##########################################
# Plotting Facilities (loaded on demand) #
##########################################

loadplotting() = include(joinpath(Pkg.dir("BenchmarkTools"), "src", "plotting.jl"))

end # module BenchmarkTools
