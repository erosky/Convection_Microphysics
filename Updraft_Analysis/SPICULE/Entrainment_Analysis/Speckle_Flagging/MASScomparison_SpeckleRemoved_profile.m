function out = MASScomparison__SpeckleRemoved_profile()

% for each cloud region
% y-axis is heigh above cloud base
% x-axis is edge 90th / core 90th
% data points are colored by the temperature of the cloud pass

Directory = "../";
Regions = dir(fullfile(Directory, 'RF*_Region*'));

output_folder = './';

full_data = [];

for f = 1:length(Regions)
    % Open up the cloudpass file
    region_folder = fullfile(Regions(f).folder, Regions(f).name);
    data = readtable(fullfile(region_folder, 'massdiameter90_comparison_table.csv'));
    
    shadow_data = readtable(fullfile(region_folder, 'ShadowDensityTable_MeanDiameter.csv'));
    shadow_ratio = shadow_data.Edge_ShadowDensity./shadow_data.Core_ShadowDensity;
    
    Indexes = shadow_data.Core_ShadowDensity < 0.01;
    D_data = data.Edge90_Core90_ratio(Indexes);
    CB_data = data.HeightAboveCB(Indexes);
    
    fig = figure(1);
    scatter(D_data, CB_data, 50, 'filled', 'DisplayName', Regions(f).name);
    hold on
    ylabel('Height above cloud base (m)');
    xlim([0.8 1.2]);
    xlabel('Edge/Core 90th percentile droplet mass diameter ratio');
    grid on
    legend('Interpreter', 'none', 'Location', 'northeastoutside');
    %h = colorbar;
    %h.Label.String = "Temperature";

        
    full_data = [full_data; data];
end

f = gcf;
exportgraphics(f, 'mass_diameter_90th_profiles_shadowremoved.png', 'Resolution',300);

ratio_data = full_data.Edge_90th./full_data.Core_90th;
avg_diameter_data = full_data.Edge_LargeAvgDiam./full_data.Core_LargeAvgDiam;

% fig1 = figure(1);
% scatter(ratio_data, full_data.HeightAboveCB, 100, full_data.Temperature, 'filled');
% ylabel('Height above cloud base (m)');
% xlabel('Edge/Core 95th percentile dropelt diameter ratio');
% grid on
% h = colorbar;
% h.Label.String = "Temperature";
% 
% saveas(fig1, '95th_percentile_profile.png');
% 
% fig2 = figure(2);
% scatter(avg_diameter_data, full_data.HeightAboveCB, 100, full_data.Temperature, 'filled');
% ylabel('Height above cloud base (m)');
% xlabel('Edge/Core Avg diameter above core 95th percentile threshold');
% grid on
% h = colorbar;
% h.Label.String = "Temperature";
% 
% saveas(fig2, 'avg_diameter_profile.png');


end
