module configs

    using OpenDtwa
    using JSON

    export Param, initialize_parameters, decayRate,  
            get_default_timepoints, load_configuration

    # Define the Param struct
    """
    Fields:
        lattice_length::Int   - Length of the lattice.
        lattice_size::Int     - Size of the lattice.
        n_samples::Int        - Number of samples.
        n_disorders::Int      - Number of disorders.
        γ::Float64            - dispersion rate.
        α::Float64            - Coupling exponent.
        dt::Float64           - Time step, FOR ODE solver
        tmin::Float64         - Minimum time.
        tmax::Float64         - Maximum time.
        field::Vector{Float64} - Magnetic field components [hx, hy, hz].
        Jxyz::Vector{Float64}  - Interaction terms [Jxx, Jyy, Jzz].
        dispersion::String     - dispersion type ("decay", "other").
    """
    struct Param
        lattice_length::Int
        lattice_size::Int
        n_samples::Int
        n_disorders::Int
        γ::Float64
        α::Float64
        dt::Float64
        tmin::Float64
        tmax::Float64
        field::Vector{Float64}
        Jxyz::Vector{Float64}
        dispersion::String
    end

    # Constructor with keyword arguments
    Param(; lattice_length, lattice_size, n_samples, n_disorders, γ, α, dt, tmin, tmax, field, Jxyz, dispersion) = 
        Param(lattice_length, lattice_size, n_samples, n_disorders, γ,  α, dt, tmin, tmax, field, Jxyz, dispersion)



    """
    Load parameters from a JSON file.

    Args:
        filepath::String: The path to the JSON file.

    Returns:
        Param: The Param struct with loaded parameters.
    """
    function load_params_from_file(filepath::String)
        # Read the JSON file
        file_content = JSON.parsefile(filepath)

        # Create the Param struct from the parsed data
        return Param(
            lattice_length = file_content["lattice_length"],
            lattice_size = file_content["lattice_size"],
            n_samples = file_content["n_samples"],
            n_disorders = file_content["n_disorders"],
            γ = file_content["γ"],
            α = file_content["α"],
            dt = file_content["dt"],
            tmin = file_content["tmin"],
            tmax = file_content["tmax"],
            field = file_content["field"],
            Jxyz = file_content["Jxyz"],
            dispersion = file_content["dispersion"]
        )
    end

    
    """
    Initialize simulation parameters with default values.

    Returns:
        Param: A struct with default simulation parameters.
    """
    function initialize_parameters()
        return Param(
            lattice_length = 100,
            lattice_size   = 10,
            n_samples      = 30,
            n_disorders    = 50,
            γ              = 0.1,
            α              = 3.0,
            dt             = 0.02,
            tmin           = 0.1,
            tmax           = 100.0,
            field          = [0.0, 0.0, 0.0],
            Jxyz           = [1.0, 1.0, 0.0],
            dispersion     = "decay",
        )
    end

   

    """
    Generate logarithmically spaced timepoints.

    Args:
        tmin::Float64: Minimum time.
        tmax::Float64: Maximum time.
        n_points::Int: Number of timepoints (default: 200).

    Returns:
        Vector{Float64}: Logarithmically spaced timepoints.
    """
    function create_timepoints(tmin::Float64, tmax::Float64, n_points::Int=200)
        if tmin <= 0 || tmax <= tmin || n_points <= 0
            error("Invalid inputs: Ensure tmin > 0, tmax > tmin, and n_points > 0.")
        end
        return 10 .^ range(log10(tmin), log10(tmax); length=n_points)
    end

  
    """
    Default accessors

    Returns:
        Param: The default parameters
    """
    function get_default_params()
        return initialize_parameters()
    end

    function get_default_timepoints()
        p = get_default_params()
        return create_timepoints(p.tmin, p.tmax)
    end


     # Load configuration from file (or default if the file doesn't exist)
    function load_configuration(path::String="./config.json")
        if isfile(path)
            return configs.load_params_from_file(path)
        else
            println("Config file not found, using default parameters.")
            return configs.get_default_params()
        end
    end

    function create_decayRate()
        p = get_default_params()
        if p.dispersion == "decay"
            return [1.0, 1.0, 1.0] .* p.γ
        elseif p.dispersion == "dephase"
            return [1.0, 1.0, 0.0] .* p.γ
        end
        return
    end
   
    timepoints = get_default_timepoints()
    decayRate  = create_decayRate()

end
