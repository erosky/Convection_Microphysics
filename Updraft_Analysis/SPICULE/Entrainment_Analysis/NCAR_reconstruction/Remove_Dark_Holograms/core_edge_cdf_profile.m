function out = core_edge_cdf_profile()

% for each cloud region
% y-axis is heigh above cloud base
% x-axis is edge 90th / core 90th
% data points are colored by the temperature of the cloud pass

Directory = "../../";
Regions = dir(fullfile(Directory, 'RF*_Region*'));

output_folder = './';

full_data = [];

for f = 1:length(Regions)
    % Open up the cloudpass file
    region_folder = fullfile(Regions(f).folder, Regions(f).name);
    data = readtable(fullfile(region_folder, 'NCAR_reconstruction/cdf_comparison_table_shadowremoved.csv'));
    
    fig = figure(1);
    
    scatter((data.Edge_D./data.Core_Dref), data.HeightAboveCB, 50, 'filled', 'DisplayName', Regions(f).name);
    hold on
    ylabel('Height above cloud base (m)');
    xlabel('Edge/Core 90th percentile diameter ratio');

    legend('Interpreter', 'none', 'Location', 'northeastoutside');
    grid on
    grid minor
    
%     scatter((1.0-data.Edge_PDref), data.HeightAboveCB, 50, 'filled', 'DisplayName', Regions(f).name);
%     hold on
%     ylabel('Height above cloud base (m)');
%     xlabel('Percentage of Edge droplets larger than Core 90th percentile diameter');
%     grid on
%     legend('Interpreter', 'none', 'Location', 'northeastoutside');

        
    full_data = [full_data; data];
end

f = gcf;
exportgraphics(f, 'cdf_D_profiles_shadowremoved.png', 'Resolution',300);


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
