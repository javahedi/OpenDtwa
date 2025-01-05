
module solvers
    using OpenDtwa.configs: Param, timepoints
    using OpenDtwa.modules: initial_state
    using DifferentialEquations: SDEProblem, EnsembleProblem, solve, StochasticCompositeAlgorithm, ImplicitEM, ImplicitRKMil, EnsembleThreads, remake
    using LinearAlgebra
    
    export solver_ensemble


    ########################################
    function dtwa0(du, u, p, t)
        jmat, couplings, fields, decayRate = p
        
        jx,jy,jz   = couplings
        hx,hy,hz   = fields
        gx, gy, gz = decayRate
        ux, uy, uz =  u[:,1] ,  u[:,2], u[:,3]
        
        jsx   = 2.0 * (jx * jmat * ux + hx)
        jsy   = 2.0 * (jy * jmat * uy + hy)
        jsz   = 2.0 * (jz * jmat * uz + hz)

        du[:,1] = uy .* jsz - uz .* jsy +  0.5 * gx * ux
        du[:,2] = uz .* jsx - ux .* jsz +  0.5 * gy * uy
        du[:,3] = ux .* jsy - uy .* jsx +  1.0 * gz * (1.0 .+ uz)
        
    end


    ########################################
    function dtwa1!(du, u, p, t)
        jmat, couplings, fields, decayRate, Ax, Ay, Az = p
        
        jx,jy,jz   = couplings
        hx,hy,hz   = fields
        gx, gy, gz, g0 = decayRate
        N          = length(hx)
        ux = @view u[:,1] 
        uy = @view u[:,2] 
        ux = @view u[:,3] 

        dux = @view du[:,1] 
        duy = @view du[:,2] 
        duz = @view du[:,3]
        
        mul!(Ax, jmat , ux)
        mul!(Ay, jmat , uy)
        mul!(Az, jmat , uz)

        jsx   = 2.0 * ( jx * Ax +  hx )
        jsy   = 2.0 * ( jy * Ay +  hy )
        jsz   = 2.0 * ( jz * Az +  hz )
        
        @. dux = uy * jsz - uz * jsy + 0.5 * gx * ux
        @. duy = uz * jsx - ux * jsz + 0.5 * gy * uy
        @. duz = ux * jsy - uy * jsx + 1.0 * gz * (1.0 .+ uz)
        
    end


    ########################################
    function dtwa_decay!(du, u, p, t)
        jmat, fields, decayRate= p
        
        ux = @view u[:,1] 
        uy = @view u[:,2] 
        uz = @view u[:,3] 

        dux = @view du[:,1] 
        duy = @view du[:,2] 
        duz = @view du[:,3] 
        
        jsx   = 2.0 * (jmat[:,:,1]* ux + fields[:,1]) 
        jsy   = 2.0 * (jmat[:,:,2]* uy + fields[:,2])
        jsz   = 2.0 * (jmat[:,:,3]* uz + fields[:,3])

        @. dux = uy * jsz - uz * jsy - 0.5 * decayRate[:,1] * ux
        @. duy = uz * jsx - ux * jsz - 0.5 * decayRate[:,2] * uy
        @. duz = ux * jsy - uy * jsx - 1.0 * decayRate[:,3] * (uz .+ 1.0)
        
    end


    ########################################
    function dtwa_dephase!(du, u, p, t)
        jmat, fields, decayRate= p
        
        
        ux = @view u[:,1] 
        uy = @view u[:,2] 
        uz = @view u[:,3] 

        dux = @view du[:,1] 
        duy = @view du[:,2] 
        duz = @view du[:,3] 
        
    
        jsx   = 2.0 * (jmat[:,:,1]* ux + fields[:,1]) 
        jsy   = 2.0 * (jmat[:,:,2]* uy + fields[:,2])
        jsz   = 2.0 * (jmat[:,:,3]* uz + fields[:,3])



        @. dux = uy * jsz - uz * jsy -  decayRate[:,1] * ux
        @. duy = uz * jsx - ux * jsz -  decayRate[:,2] * uy
        @. duz = ux * jsy - uy * jsx 
        
    end

    
    ########################################
    function noise_decay!(du, u, p, t)
        _, _, decayRate = p
        
        
        ux = @view u[:,1] 
        uy = @view u[:,2] 
        uz = @view u[:,3] 

        dux = @view du[:,1] 
        duy = @view du[:,2] 
        duz = @view du[:,3] 
        

        @. dux = -sqrt.(decayRate[:,1]) * uy
        @. duy =  sqrt.(decayRate[:,2]) * ux
        @. duz =  sqrt.(decayRate[:,3]) * (uz .+ 1.0)
        
    end


    ########################################
    function noise_dephase!(du, u, p, t)
        _, _, decayRate = p
        
        
        ux = @view u[:,1] 
        uy = @view u[:,2] 
        #uz = @view u[:,3] 

        dux = @view du[:,1] 
        duy = @view du[:,2] 
        #duz = @view du[:,3] 
        

        @. dux = -sqrt.(2.0 * decayRate[:,1]) * uy
        @. duy =  sqrt.(2.0 * decayRate[:,2]) * ux
        #@. duz = 0.0
        
    end




    ########################################
    function solver_ensemble(input, params::Param, discrete::Bool)

        #------------------------------
        y0      = initial_state(params.lattice_size, discrete=discrete)
        list_y0 = [initial_state(params.lattice_size, discrete=discrete) for _ in 1:params.n_samples]

        #------------------------------
        function prob_func(prob, i, repeat)
            remake(prob, u0 =list_y0[i])
        end

        prob          = SDEProblem(dtwa_decay!, noise_decay!, y0, (params.tmin, params.tmax),input)
        ensemble_prob = EnsembleProblem(prob, prob_func = prob_func)


        #------------------------------
        choice_function(integrator) = (Int(integrator.dt < 0.001) + 1)
        alg_switch = StochasticCompositeAlgorithm((ImplicitEM(), ImplicitRKMil()), choice_function)
        

        sol = solve(ensemble_prob, alg_switch,
                dt = params.dt,
                adaptive = false,
                alg_hints = [:stiff],  # Assuming your problem is stiff
                saveat = timepoints,
                reltol = 1e-10,
                abstol = 1e-10,
                EnsembleThreads(),  # Assuming you want to use parallelism
                trajectories = params.n_samples)

        return sol
    end

end
