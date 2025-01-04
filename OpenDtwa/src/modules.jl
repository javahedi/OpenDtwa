module modules

    using OpenDtwa.configs: Param
    using StatsBase
    using LinearAlgebra

    export coupling_matrix, coupling_longRange_random, 
            thermal_state, initial_state, update_parameters
    
    ########################################
    function coupling_matrix(δ::Float64, params::Param)
        # Build the hopping matrix
        jmat = zeros(Float64, params.lattice_size, params.lattice_size)
        for n in 1:params.lattice_size-1
            jmat[n,n+1] = (1.0 - (-1.0)^n * δ ) 
        end
        jmat .+= jmat'
        return jmat
    end


    function coupling_longRange_random(params::Param)

        check = false
        site_index = Array{Int}(undef, params.lattice_size)
        while !check
            site_index = sort(sample(1:params.lattice_length, params.lattice_size, replace=false))
            check = length(unique(site_index)) == params.lattice_size
        end

        jmat = zeros(Float64, params.lattice_size, params.lattice_size)
        for i in 1:params.lattice_size-1
            for j in i+1:params.lattice_size
                dij = abs(site_index[i] - site_index[j])
                jmat[i, j] = 1.0 / dij^params.α  # Use params.α
            end
        end
        jmat .+= jmat'
        return jmat 
    end


    ########################################
    function thermal_state(N; discrete=true)
        s0 = Array{Float64, 2}(undef, N, 3); 
        if discrete
            # dTWA
            sx_init = 2.0 .* rand(0:1, N) .- 1.0
            sy_init = 2.0 .* rand(0:1, N) .- 1.0
            sz_init = 2.0 .* rand(0:1, N) .- 1.0
        else
            # TWA--> sampled from Gaussian distribution
            mean = [0.0, 0.0, 0.0]
            covariance = [1.0 0.0 0.0; 0.0 1.0 0.0; 0.0 0.0 1.0]
            z = randn(3, N)
            sample = (cholesky(covariance).L * z) .+ mean
            sx_init, sy_init, sz_init = sample[1,:], sample[2,:], sample[3,:]
        end

        # Fix the first one pointing in z direction
        sx_init[1] = 0.0
        sy_init[1] = 0.0
        sz_init[1] = -1.0

        s0[:,1] = sx_init
        s0[:,2] = sy_init
        s0[:,3] = sz_init
        return s0
    end


    function initial_state(N; discrete=true)
        spin_state = Array{Float64, 2}(undef, N, 3); 
        if discrete
            # dTWA
            sz_init = ones(Float64, N)
            sy_init = 2.0 .* rand(0:1, N) .- 1.0
            sx_init = 2.0 .* rand(0:1, N) .- 1.0

            # Neel state
            for i in 1:N
                if i % 2 == 0
                    sz_init[i] = -1.0 
                end
            end
        else
            sz_init = ones(Float64, N)
            # Neel state
            for i in 1:N
                if i % 2 == 0
                    sz_init[i] = -1.0 
                end
            end
            mean = [0.0, 0.0]
            covariance = [1.0 0.0; 0.0 1.0]
            z = randn(2, N)
            sample = (cholesky(covariance).L * z) .+ mean
            sx_init, sy_init = sample[1,:], sample[2,:]
        end

        spin_state[:,1] = sx_init
        spin_state[:,2] = sy_init
        spin_state[:,3] = sz_init

        return spin_state
    end


    # Function to update parameters
    function update_parameters(Jmn::Matrix{Float64}, params::Param)
        
        # Create the fields matrix (lattice_size x 3)
        fields_mat = Array{Float64, 2}(undef, params.lattice_size, 3)
        #fields_mat[:,1]= ones(Float64, params.lattice_size) .* params.field[1]
        #fields_mat[:,2]= ones(Float64, params.lattice_size) .* params.field[2]
        #fields_mat[:,3]= ones(Float64, params.lattice_size) .* params.field[3]
        fields_mat = repeat(params.field', params.lattice_size, 1)

        decayRate_mat = Array{Float64, 2}(undef, params.lattice_size, 3)
        #decayRate_mat[:,1]= ones(Float64, params.lattice_size) .* params.decayRate[1]
        #decayRate_mat[:,2]= ones(Float64, params.lattice_size) .* params.decayRate[2]
        #decayRate_mat[:,3]= ones(Float64, params.lattice_size) .* params.decayRate[3]
        decayRate_mat = repeat(params.decayRate', params.lattice_size, 1)

        # Create the Jmn matrix (lattice_size x lattice_size x 3)
        Jmn_mat = Array{Float64, 3}(undef, params.lattice_size, params.lattice_size, 3)
        #Jmn_mat[:,:,1] = Jmn .* params.Jxyz[1]  # Jxx
        #Jmn_mat[:,:,2] = Jmn .* params.Jxyz[2]  # Jyy
        #Jmn_mat[:,:,3] = Jmn .* params.Jxyz[3]  # Jzz
        Jmn_mat = Jmn[:, :, :] .* reshape(params.Jxyz, 1, 1, :)
        

        return (Jmn_mat, fields_mat, decayRate_mat)
    end

end
