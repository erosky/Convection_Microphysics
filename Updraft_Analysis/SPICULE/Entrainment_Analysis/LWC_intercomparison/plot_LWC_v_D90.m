function out = plot_LWC_v_D90()

Directory = "../";
Regions = dir(fullfile(Directory, 'RF*_Region*'));

output_folder = './';

full_data = [];

for f = 1:length(Regions)
    % Open up the cloudpass file
    region_folder = fullfile(Regions(f).folder, Regions(f).name);
    data = readtable(fullfile(region_folder, 'massdiameter90_comparison_table.csv'));
    
    shadow_data = readtable(fullfile(region_folder, 'ShadowDensityTable.csv'));
    
    lwc_data = readtable(fullfile(region_folder, 'LWC_Table_CDP.csv'));
    
    Indexes = shadow_data.Core_ShadowDensity < 0.03;
    
    fig = figure(1);
    scatter(lwc_data.LWC_ratio(Indexes), data.Edge90_Core90_ratio(Indexes), 50, 'filled', 'DisplayName', Regions(f).name);
    hold on
    title('Shadow Density > 0.03 removed');
    ylabel('Edge/Core 90th percentile droplet mass diameter ratio from HOLODEC');
    xlabel('Edge/Core LWC ratio from CDP');
    grid on
    legend('Interpreter', 'none', 'Location', 'northeastoutside');
    %h = colorbar;
    %h.Label.String = "Temperature";

        
    full_data = [full_data; data];
end

f = gcf;
exportgraphics(f, 'LWC_v_D90_profiles_SpeckleRemoved.png', 'Resolution',300);


end
