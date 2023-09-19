function out = core_edge_MASScomparison_profile()

% for each cloud region
% y-axis is heigh above cloud base
% x-axis is edge 90th / core 90th
% data points are colored by the temperature of the cloud pass

Directory = "./";
Regions = dir(fullfile(Directory, 'RF*_Region*'));

output_folder = './';

full_data = [];

for f = 1:length(Regions)
    % Open up the cloudpass file
    region_folder = fullfile(Regions(f).folder, Regions(f).name);
    data = readtable(fullfile(region_folder, 'massdiameter_comparison_table.csv'));
    
    fig = figure(1);
    scatter(data.Edge_90th./data.Core_90th, data.HeightAboveCB, 50, 'filled', 'DisplayName', Regions(f).name);
    hold on
    ylabel('Height above cloud base (m)');
    xlabel('Edge/Core 95th percentile droplet mass diameter ratio');
    grid on
    legend('Interpreter', 'none', 'Location', 'northeastoutside');
    %h = colorbar;
    %h.Label.String = "Temperature";

        
    full_data = [full_data; data];
end

f = gcf;
exportgraphics(f, 'mass_diameter_95th_profiles.png', 'Resolution',300);

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
