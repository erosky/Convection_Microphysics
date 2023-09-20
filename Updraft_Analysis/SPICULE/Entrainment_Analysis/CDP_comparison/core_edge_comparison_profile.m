function out = core_edge_comparison_profile()

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
    data = readtable(fullfile(region_folder, 'CDP', 'core_edge_comparison_table.csv'));
    
    fig = figure(f);
    scatter(data.Edge_LargeAvgDiam./data.Core_LargeAvgDiam, data.HeightAboveCB, 100, data.Temperature, 'filled');
    ylabel('Height above cloud base (m)');
    xlabel('Edge/Core Avg diameter above core 95th percentile threshold');
    grid on
    h = colorbar;
    h.Label.String = "Temperature";
        
    full_data = [full_data; data];
end

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
