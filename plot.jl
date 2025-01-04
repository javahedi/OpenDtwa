


using Plots
using BSON
using Printf
using LaTeXStrings
using PlutoUI
using Measures
using DelimitedFiles
using OpenDtwa

using OpenDtwa.configs: Param, timepoints
params = OpenDtwa.configs.load_configuration()


#------------------------------------------------------------
function magnetization(α,p::Param)

    mx = zeros(p.lattice_size,length(timepoints))
    my = zeros(p.lattice_size,length(timepoints))
    mz = zeros(p.lattice_size,length(timepoints))

    for d in 1:p.n_disorders
        # Load the data from the file
        BSON.@load "alpha$(α)/disorder_$(lpad(d, 3, '0')).bson" ave_solution std_solution

        mx  .+= ave_solution[:,1,:]
        my  .+= ave_solution[:,2,:]
        mz  .+= ave_solution[:,3,:]
    end

    mx ./= p.n_disorders
    my ./= p.n_disorders
    mz ./= p.n_disorders

       
    # total magnetization
    #mx_expct = vec(sum(mx, dims=1)) ./p.lattice_size;
    #my_expct = vec(sum(my, dims=1)) ./p.lattice_size;
    #mz_expct = vec(sum(mz, dims=1)) ./p.lattice_size;

    mx_expct = vec(sum((-1)^(i-1) * mx[i,:] for i in 1:size(mx,1))) ./p.lattice_size
    my_expct = vec(sum((-1)^(i-1) * my[i,:] for i in 1:size(my,1))) ./p.lattice_size
    mz_expct = vec(sum((-1)^(i-1) * mz[i,:] for i in 1:size(mz,1))) ./p.lattice_size



	return mx_expct, my_expct, mz_expct

end 



result_α1 = magnetization(1.0,params);
result_α2 = magnetization(2.0,params);
result_α3 = magnetization(3.0,params);


# Plotting
plt = plot(size=(600, 200), dpi=300, xlim=(10^-1,10^2), ylim=(-0.1,1.01),
            bottom_margin=5mm, xscale=:log10,
            top_margin=0mm, left_margin=5mm)  # Initialize plot with custom size


plot!(timepoints, 1.0 .* result_α1[3], linecolor=:blue, linewidth=2, label=L"α=1.0")
plot!(timepoints, 1.0 .* result_α2[3], linecolor=:red, linewidth=2, label=L"α=2.0")
plot!(timepoints, 1.0 .* result_α3[3], linecolor=:yellow, linewidth=2, label=L"α=3.0")

xlabel!( "Time")
ylabel!(L"\langle m^z_{st} ⟩",fontsize=24)

savefig("magnetization.pdf")



# julia --project=./OpenDtwa plot.jl