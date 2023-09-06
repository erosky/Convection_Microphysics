function out = core_edge_mass_comparison(region)

% get the core-edge pairs from core_edge_pairs.csv for each pair, 
% get all the comparison data output a table containing the data 
% CorePassNum, EdgePassNum, Core90th, Core_Avg_Large, Core_Largest,
% Edge90th, Edge_Avg_Large, Edge_Largest,

% Plot a three panel figure per pair in the Region folder

region_folder = '/data/emrosky-sim/Field_Projects/Convection_Microphysics/Updraft_Analysis/SPICULE';
timestamps = readtable(fullfile(region_folder, region, 'core_edge_pairs.csv'));

edge_thermodynamics = dir(fullfile(region_folder, region, 'EdgeCloud', 'thermodynamics_*.csv'));
core_thermodynamics = dir(fullfile(region_folder, region, 'InCloud', 'thermodynamics_*.csv'));

output_path = '/data/emrosky-sim/Field_Projects/Convection_Microphysics/Updraft_Analysis/SPICULE/Entrainment_Analysis';
output_folder = fullfile(output_path, region);

% rows are core-edge pairs, columns are data
output = timestamps;

% get core data
[core_90th_list, core_large_avg_list, core_largest_list] = get_core_mass90th(region)

core_90th = [];
core_large_avg = [];
core_largest = [];
edge_90th = [];
edge_large_avg = [];
edge_largest = [];

core_LWC_avg = [];
core_LWC_max = [];
core_LWC_min = [];
edge_LWC_avg = [];
edge_LWC_max = [];
edge_LWC_min = [];

core_vwind_avg = [];
core_vwind_max = [];
core_vwind_min = [];
edge_vwind_avg = [];
edge_vwind_max = [];
edge_vwind_min = [];


for r=1 : height(timestamps)
   % get droplet size data
   core_pass = timestamps{r,2}
   edge_pass = timestamps{r,1}
   core_90th_pass = core_90th_list(core_pass);
   [edge_90th_pass, edge_large_avg_pass, edge_largest_pass] = get_edge_mass90th(region, edge_pass, core_90th_pass);
   core_90th = [core_90th; core_90th_pass];
   core_large_avg = [core_large_avg; core_large_avg_list(core_pass)];
   core_largest = [core_largest; core_largest_list(core_pass)];
   edge_90th = [edge_90th; edge_90th_pass];
   edge_large_avg = [edge_large_avg; edge_large_avg_pass];
   edge_largest = [edge_largest; edge_largest_pass];
   
   
   % Thermodynamics
    edge_thermofile = readtable(fullfile(edge_thermodynamics(edge_pass).folder, edge_thermodynamics(edge_pass).name));
    core_thermofile = readtable(fullfile(core_thermodynamics(core_pass).folder, core_thermodynamics(core_pass).name));
    LWC_edge = edge_thermofile.LWC_king;
    LWC_core = core_thermofile.LWC_king;
    vwind_edge = edge_thermofile.VerticalWind;
    vwind_core = core_thermofile.VerticalWind;
    
    core_LWC_avg = [core_LWC_avg; mean(LWC_core,"omitnan")];
    core_LWC_max = [core_LWC_max; max(LWC_core)];
    core_LWC_min = [core_LWC_min; min(LWC_core)];
    edge_LWC_avg = [edge_LWC_avg; mean(LWC_edge,"omitnan")];
    edge_LWC_max = [edge_LWC_max; max(LWC_edge)];
    edge_LWC_min = [edge_LWC_min; min(LWC_edge)];

    core_vwind_avg = [core_vwind_avg; mean(vwind_core,"omitnan")];
    core_vwind_max = [core_vwind_max; max(vwind_core)];
    core_vwind_min = [core_vwind_min; min(vwind_core)];
    edge_vwind_avg = [edge_vwind_avg; mean(vwind_edge,"omitnan")];
    edge_vwind_max = [edge_vwind_max; max(vwind_edge)];
    edge_vwind_min = [edge_vwind_min; min(vwind_edge)];
   
   % Plot Figure
    fig = figure(r)
    hold off
    tiledlayout(4,1);
    ax1 = nexttile([2 1]);
    x = [1,2];
    
    % 90th percentile
    yline(core_90th_pass, '--b','DisplayName', 'Core 95th percentile'); % Mark core 90th percentile
    hold on
    % plot core
    plot(1, core_large_avg_list(core_pass), 'square', 'MarkerSize', 10, 'DisplayName', 'Avg Large Diameter', 'MarkerEdgeColor','b');
    hold on
    plot(1, core_largest_list(core_pass), '^', 'MarkerSize', 10, 'DisplayName', 'Max Diameter', 'MarkerEdgeColor','b');
    hold on
    % Plot edge
    plot(2, edge_large_avg_pass, 'square', 'MarkerSize', 10, 'HandleVisibility','off', 'MarkerEdgeColor','m');
    hold on
    plot(2, edge_largest_pass, '^', 'MarkerSize', 10, 'HandleVisibility','off', 'MarkerEdgeColor','m');
    % Set up axes.
    xlim([0.5, 2.5]);
    ylim([core_90th_pass-5, core_largest_list(core_pass)+15]);
    ax1 = gca;
    ax1.XTick = [1, 2];
    ax1.XTickLabels = {'Core','Edge'};
    ylabel('Droplet Diameter (um)');
    grid on
    legend('Location', 'northeastoutside')
    
    % Updraft
    ax2 = nexttile;
    % plot core
    plot(1, core_vwind_avg(end), 'square', 'MarkerSize', 10, 'DisplayName', 'Avg updraft velocity', 'MarkerEdgeColor','b');
    hold on
    plot(1, core_vwind_max(end), '^', 'MarkerSize', 10, 'DisplayName', 'Max updraft velocity', 'MarkerEdgeColor','b');
    hold on
    plot(1, core_vwind_min(end), 'v', 'MarkerSize', 10, 'DisplayName', 'Min updraft velocity', 'MarkerEdgeColor','b');
    hold on
    % Plot edge
    plot(2, edge_vwind_avg(end), 'square', 'MarkerSize', 10, 'HandleVisibility','off', 'MarkerEdgeColor','m');
    hold on
    plot(2, edge_vwind_max(end), '^', 'MarkerSize', 10, 'HandleVisibility','off', 'MarkerEdgeColor','m');
    hold on
    plot(2, edge_vwind_min(end), 'v', 'MarkerSize', 10, 'HandleVisibility','off', 'MarkerEdgeColor','m');
    % Set up axes.
    xlim([0.5, 2.5]);
    ax2 = gca;
    ax2.XTick = [1, 2];
    ax2.XTickLabels = {'Core','Edge'};
    ylabel('Vertical wind (m/s)');
    grid on
    legend('Location', 'northeastoutside')
    
    % LWC
    ax3 = nexttile;
    % plot core
    plot(1, core_LWC_avg(end), 'square', 'MarkerSize', 10, 'DisplayName', 'Avg LWC', 'MarkerEdgeColor','b');
    hold on
    plot(1, core_LWC_max(end), '^', 'MarkerSize', 10, 'DisplayName', 'Max updraft velocity', 'MarkerEdgeColor','b');
    hold on
    plot(1, core_LWC_min(end), 'v', 'MarkerSize', 10, 'DisplayName', 'Min updraft velocity', 'MarkerEdgeColor','b');
    hold on
    % Plot edge
    plot(2, edge_LWC_avg(end), 'square', 'MarkerSize', 10, 'HandleVisibility','off', 'MarkerEdgeColor','m');
    hold on
    plot(2, edge_LWC_max(end), '^', 'MarkerSize', 10, 'HandleVisibility','off', 'MarkerEdgeColor','m');
    hold on
    plot(2, edge_LWC_min(end), 'v', 'MarkerSize', 10, 'HandleVisibility','off', 'MarkerEdgeColor','m');
    % Set up axes.
    xlim([0.5, 2.5]);
    ax2 = gca;
    ax2.XTick = [1, 2];
    ax2.XTickLabels = {'Core','Edge'};
    ylabel('LWC (g m-3) King probe');
    grid on
    legend('Location', 'northeastoutside')
    hold off
    
    linkaxes([ax1, ax2, ax3],'x');
    
    passname = region + "_" + "Edge" + edge_pass + "_Core" + core_pass;
    saveas(fig, sprintf('%s/MASSDIAMETER_%s.png', output_folder, passname));
   
   
   
end


output.Core_90th = core_90th;
output.Core_LargeAvgDiam = core_large_avg;
output.Core_Largest = core_largest;
output.Edge_90th = edge_90th;
output.Edge_LargeAvgDiam = edge_large_avg;
output.Edge_Largest = edge_largest;

output
writetable(output, fullfile(output_folder, 'massdiameter_comparison_table.csv'));




end
