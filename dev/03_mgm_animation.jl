#======================================================================
    This script generates the GIF animation in the main README.md file

    Author: Andrea Pavan
    Project: AirfoilInverseDesign.jl package
    License: MIT
    Date: 04/08/2024
======================================================================#
using AirfoilInverseDesign;
using Plots;


#define the starting airfoil (a NACA-0009 with 100 nodes)
(airfoil0,airfoil0header) = generatenaca4airfoil("0009", 100);

#define the target pressure distribution from a set of 10 parameters
params = [0.263625, -0.658409, 0.379949, 0.946806, -0.099668, 0.039979, -0.268271, 0.997283, 0.999967, 0.173235];
cptarget = cpgen10h(params, airfoil0[:,1]);
airfoiltmp = copy(airfoil0);

#analyze the initial airfoil with an inviscid panel method at α=0°
(cp,_,_,_,_) = panel1(airfoil0, 0);

#create animation
anim = Animation();
plt1 = plot(airfoil0[:,1], airfoil0[:,2], label="Starting",
    title = "Airfoil comparison - Iteration #0",
    xlabel = "x/c",
    ylabel = "y/c",
    ylims = [-0.3, +0.3],
    aspect_ratio = :equal
);
scatter!(plt1, airfoiltmp[:,1], airfoiltmp[:,2], label="Generated");
plt2 = plot(cptarget[:,1], cptarget[:,2], label="Target",
    title = "Pressure distribution comparison",
    xlabel = "x/c",
    ylabel = "cp",
    yflip = true
);
scatter!(plt2, cp[:,1], cp[:,2], label="Generated");
plt = plot(plt1, plt2);
frame(anim, plt);

#run one MGM iteration at a time
@gif for i=1:40
    #airfoil inverse design
    (airfoil,status) = mgm(cptarget, airfoiltmp, 1);
    global airfoiltmp = airfoil;

    #analyze the generated airfoil with an inviscid panel method at α=0°
    (cp,_,_,_,_) = panel1(airfoil, 0);

    #geometry animation frame
    plt1 = plot(airfoil0[:,1], airfoil0[:,2], label="Starting",
        title = "Airfoil - Iteration #"*string(i),
        xlabel = "x/c",
        ylabel = "y/c",
        ylims = [-0.3, +0.3],
        aspect_ratio = :equal
    );
    scatter!(plt1, airfoil[:,1], airfoil[:,2], label="Generated");

    #pressure distribution animation frame
    plt2 = plot(cptarget[:,1], cptarget[:,2], label="Target",
        title = "Pressure distribution",
        xlabel = "x/c",
        ylabel = "cp",
        yflip = true
    );
    scatter!(plt2, cp[:,1], cp[:,2], label="Generated");

    #update plots
    plt = plot(plt1, plt2);
    frame(anim, plt);
end
gif(anim, joinpath(@__DIR__,"../docs/assets/readme_mgm_animation.gif"), fps=2);
