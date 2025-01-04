using Distributed
using Logging
using BSON
using Statistics
using ProgressMeter
using OpenDtwa  # Ensure the package is installed and accessible

#using .OpenDtwa.configs: load_configuration

# Add worker processes if only one process exists
if nprocs() == 1
    addprocs()  # Add worker processes
end

@everywhere begin
    using Logging
    using BSON
    using Statistics
    using OpenDtwa    
    #using .OpenDtwa.modules: coupling_longRange_random

end


# Logger setup
global_logger(ConsoleLogger(stderr))


# Load parameters
params = OpenDtwa.configs.load_configuration()
#params = load_configuration()


@everywhere begin
    # Broadcast `params` to all workers 
    global params = $(params)
    
    # Broadcast `output_path` to all workers 
    global output_path = "alpha$(params.α)"
    if !isdir(output_path)
        mkdir(output_path)
    end
end

@info "Parameters: $params"


# Define computation for a single disorder realization
@everywhere function compute_disorder(d)
    try
        @info "Worker $(myid()): Processing disorder realization $d"
        
        # Create Coupling
        Jmn = OpenDtwa.modules.coupling_longRange_random(params)
       
        # Initialize Parameters
        input = OpenDtwa.modules.update_parameters(Jmn, params)
        
        # Solve Ensemble
        sol = OpenDtwa.solvers.solver_ensemble(input, params, false)
        
        # Compute Averages
        ave_solution = mean(sol, dims=4)
        std_solution = std(sol, dims=4)

        # Save Results
        output_file = joinpath(output_path, "disorder_$(lpad(d, 3, '0')).bson")
        BSON.@save output_file ave_solution std_solution
        @info "Worker $(myid()): Saved results to $output_file"

        #sleep(1)
        return true
    catch e
        @warn "Worker $(myid()): Error in disorder realization $d: $e"
        return false
    end
end

# Use pmap for parallel processing
results = pmap(compute_disorder, 1:params.n_disorders)

# Summary of results
successful = count(x -> x, results)
failed     = count(x -> !x, results)
@info "Completed all computations"
@info "Successful realizations: $successful"
@info "Failed realizations: $failed"



#julia --project=./OpenDtwa -t 4 main.jl  # multiple threads:
#julia --project=./OpenDtwa -p 4 main.jl  # distributed processes


├── DATA
│   ├── alpha1.0
│   │   ├── disorder_001.bson
│   ├── alpha2.0
│   │   ├── disorder_001.bson
│   └── alpha3.0
│       ├── disorder_001.bson
│      
├── OpenDtwa
│   ├── Manifest.toml
│   ├── Project.toml
│   └── src
│       ├── OpenDtwa.jl
│       ├── configs.jl
│       ├── modules.jl
│       └── solvers.jl
├── config.json
├── magnetization.pdf
├── main.jl
├── plot.jl
└── test
    └── runtest.jl

