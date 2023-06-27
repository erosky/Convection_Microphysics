function out = Plot_correlations()

    vars = readtable(fullfile('/home/simulations/Field_Projects/Updraft_Analysis/SPICULE/Microphysics_Analysis', 'correlation_table.csv'));
    lwc_bin_edges = [0, 0.5, 0.8, 1.0, 1.5, 2.5];
    
    % figure 1 -> showing tht lwc bins are following moist-adiabatic
    % expectations
    
    X1 = categorical({'LWC = 0-0.5 g/m^3','LWC = 0.5-0.8 g/m^3','LWC = 0.8-1.0 g/m^3','LWC = 1.0-1.5 g/m^3', 'LWC = 1.5-2.5 g/m^3'});
    X1 = reordercats(X1,{'LWC = 0-0.5 g/m^3','LWC = 0.5-0.8 g/m^3','LWC = 0.8-1.0 g/m^3','LWC = 1.0-1.5 g/m^3', 'LWC = 1.5-2.5 g/m^3'});
    Y1 = zeros([1,5]);
    
    % figure 2 -> showing lack of correlation with below-cloud properties
    
    X2 = categorical({'CN Concentration','Cloud Base Temperature','Updraft Velocity','GNI Concentration', 'Largest GNI NaCl Size'});
    X2 = reordercats(X2,{'CN Concentration','Cloud Base Temperature','Updraft Velocity','GNI Concentration', 'Largest GNI NaCl Size'});
    Y2 = zeros([5,5]);
%     bar(X,Y)

    % figure 3 -> showing overall correlation between dropsize and height,
    % weak correlations between dropsize and lwc
    % weak correlation between lwc and height
    X3 = categorical({'Droplet Size and Height above Cloud Base','Droplet Size and LWC','LWC and Height above Cloud base'});
    X3 = reordercats(X3,{'Droplet Size and Height above Cloud Base','Droplet Size and LWC','LWC and Height above Cloud base'});

    allheight = corrcoef(vars.holoSize, vars.HeightAbvCB);
    allLWC = corrcoef(vars.holoSize, vars.meanLWC);
    LWCheight = corrcoef(vars.HeightAbvCB, vars.meanLWC);
    
    Y3 = [allheight(1,2), allLWC(1,2), LWCheight(1,2)];
    
    fig3 = figure(3)
    bar(X3,Y3)
    saveas(fig3, 'allpasscorrelations.png')

    fig4 = figure(4)
    

    for bin=1 : length(lwc_bin_edges)-1
        binIndexes = (vars.meanLWC > lwc_bin_edges(bin)) & (vars.meanLWC <= lwc_bin_edges(bin+1));
        gniIndexes = (vars.meanLWC > lwc_bin_edges(bin)) & (vars.meanLWC <= lwc_bin_edges(bin+1)) & (vars.gniSize ~= -5);
        A = vars.holoSize(binIndexes);
        A_G = vars.holoSize(gniIndexes);
        B = vars.concCN(binIndexes);
        C = vars.CloudBaseTemp(binIndexes);
        D = vars.gniConc(gniIndexes);
        E = vars.meanUpdraft(binIndexes);
        F = vars.TempAbvCB(binIndexes);
        G = vars.HeightAbvCB(binIndexes);
        H = vars.gniMass(gniIndexes);
        I = vars.gniSize(gniIndexes);
        CN = corrcoef(A,B);
        temp = corrcoef(A,C);
        gniconc = corrcoef(A_G,D);
        gnimass = corrcoef(A_G,I);
        updraft = corrcoef(A,E);
        thermo = corrcoef(F,G)
        Y1(1,bin) = thermo(1,2);
        height = corrcoef(A,G);
        Y2(1,bin) = CN(1,2);
        Y2(2,bin) = temp(1,2);
        Y2(3,bin) = updraft(1,2);
        Y2(4,bin) = gniconc(1,2);
        Y2(5,bin) = gnimass(1,2);
        name = X1(bin)
        scatter(A_G, I, 'marker', 'o')
        xlabel('90th percentile droplet size (um)')
        ylabel('Largest GNI NaCl diameter (um)')
        hold on
    end
    
    fig1 = figure(1)
    bar(X1,Y1)
    title("Temperature and Height above cloud base correlation")
    ylabel('Correlation Coefficient')
    saveas(fig1, 'moistadiabaticcorrelations.png')
    
    fig2 = figure(2)
    tiledlayout(1,3);
    nexttile([1,2])
    bar(X2,Y2)
    L={'LWC = 0-0.5 g/m^3','LWC = 0.5-0.8 g/m^3','LWC = 0.8-1.0 g/m^3','LWC = 1.0-1.5 g/m^3', 'LWC = 1.5-2.5 g/m^3'};
    lgd=legend(L, 'Location', 'east');
    lgd.Layout.Tile = 3;
    title("Correlation between 90th percentile droplet size and other variables")
    ylabel("Correlation Coefficient")
    saveas(fig2, 'nocorrelations.png')
    
    %
    %scatter plot of CN conc and 90th percentil for LWC = 1.5
   
    
    %fig5 = figure(5)
    %scatter plot of CN conc and 90th percentil for LWC = 1.5
   
    

end