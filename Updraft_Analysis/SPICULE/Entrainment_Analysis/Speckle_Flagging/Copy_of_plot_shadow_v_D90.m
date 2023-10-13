function out = plot_shadow_v_D90()

Directory = "../";
Regions = dir(fullfile(Directory, 'RF*_Region*'));

output_folder = './';

full_data = [];

for f = 1:length(Regions)
    % Open up the cloudpass file
    region_folder = fullfile(Regions(f).folder, Regions(f).name);
    data = readtable(fullfile(region_folder, 'massdiameter90_comparison_table.csv'));
    
    shadow_data = readtable(fullfile(region_folder, 'ShadowDensityTable.csv'));
    shadow_ratio = shadow_data.Edge_ShadowDensity./shadow_data.Core_ShadowDensity;
    
    Indexes = shadow_data.Core_ShadowDensity < 0.03;
    
    fig = figure(1);
    scatter(shadow_ratio(Indexes), data.Edge90_Core90_ratio(Indexes), 50, 'filled', 'DisplayName', Regions(f).name);
    hold on
    title('Shadow Density > 0.03 removed');
    ylabel('Edge/Core 90th percentile droplet mass diameter ratio');
    xlabel('Edge/Core shadow density ratio');
    grid on
    legend('Interpreter', 'none', 'Location', 'northeastoutside');
    %h = colorbar;
    %h.Label.String = "Temperature";

        
    full_data = [full_data; data];
end

f = gcf;
exportgraphics(f, 'SpeckleRemoved_ShadowDensity_v_D90_profiles.png', 'Resolution',300);


end
