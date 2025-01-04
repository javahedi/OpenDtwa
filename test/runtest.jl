
# Include the main package and modules for testing
using OpenDtwa
using Test

# Test initialization of parameters (configs module)
@testset "Configs module" begin
    config_file = joinpath(@__DIR__, "..", "config.json")
    println("Config file path: ", config_file)
    params = OpenDtwa.configs.load_configuration(config_file)
    
    # Check if the params struct is initialized correctly
    @test params.lattice_length == 100
    @test params.lattice_size == 10
    @test params.n_samples == 30
    @test params.field == [0.0, 0.0, 0.0]
    @test params.Jxyz == [1.0, 1.0, 0.0]
    @test params.dispersion == "dephase"
end

# Test create_timepoints function (configs module)
@testset "create_timepoints function" begin
    params = OpenDtwa.configs.load_configuration()
    timepoints = OpenDtwa.configs.create_timepoints(params.tmin, params.tmax)
    
    # Check that timepoints is a vector and has the correct length
    @test length(timepoints) == 200
    
    # Check the first and last timepoints are within expected range
    @test timepoints[1] ≈ 0.1 atol=1e-2
    @test timepoints[end] ≈ 100.0 atol=1e-2
end

# Test the coupling_matrix function (modules module)
@testset "coupling_matrix function" begin
    params = OpenDtwa.configs.load_configuration()
    δ = 0.5
    jmat = OpenDtwa.modules.coupling_matrix(δ, params)
    
    # Check if the matrix dimensions are correct
    @test size(jmat) == (params.lattice_size, params.lattice_size)
    
    # Check if the coupling values are properly set
    @test jmat[1,2] == (1.0 - (-1.0)^1 * δ)
    @test jmat[2,1] == jmat[1,2]  # Ensure symmetry
end



# Test thermal_state function (modules module)
@testset "thermal_state function" begin
    N = 10  # Number of spins
    s0 = OpenDtwa.modules.thermal_state(N)
    
    # Check if thermal state is a matrix of the correct size
    @test size(s0) == (N, 3)
    
    # Check the first spin state points in the negative z direction
    @test s0[1,3] == -1.0
end

# Test initial_state function (modules module)
@testset "initial_state function" begin
    N = 10  # Number of spins
    spin_state = OpenDtwa.modules.initial_state(N)
    
    # Check if initial state is a matrix of the correct size
    @test size(spin_state) == (N, 3)
    
end

# Test update_parameters function (modules module)
@testset "update_parameters function" begin
    params = OpenDtwa.configs.load_configuration()
    Jmn = rand(params.lattice_size, params.lattice_size)  # Random Jmn matrix
    Jmn_mat, fields_mat, decayRate_mat = OpenDtwa.modules.update_parameters(Jmn, params)
    
    # Check if the matrices returned have the correct dimensions
    @test size(Jmn_mat) == (params.lattice_size, params.lattice_size, 3)
    @test size(fields_mat) == (params.lattice_size, 3)
    @test size(decayRate_mat) == (params.lattice_size, 3)
end



"""
How to Run the Tests
Open Julia REPL and navigate to your project directory.
Run the tests by executing:
1 : in termina run : julia --project=.
2 : in julia run the following commands : ]
3 : pkg> activate ./OpenDtwa
4 : julia> import OpenDtwa
5 : julia> include("test/runtest.jl")
"""

