module OpenDtwa

    import LinearAlgebra
    import Distributed
    import Logging
    import BSON
    import Statistics
    import ProgressMeter
    import DifferentialEquations
    import Random
    import StatsBase

    export Param, initialize_parameters, create_timepoints, params, timepoints,
            coupling_matrix, coupling_longRange_random, thermal_state, initial_state, 
            update_parameters, solver_ensemble, load_configuration

    include("configs.jl")
    include("modules.jl")
    include("solvers.jl")

    greet() = print("Hello World!")
    greet_alien() = print("Hello ", Random.randstring(8))

end # module OpenDtwa
