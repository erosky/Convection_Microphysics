

% LWC histogram of core and edge 1 Hz
% Vertical wind histogram core and edge
% 

function out = core_edge_histograms(region)

% get the core-edge pairs from core_edge_pairs.csv for each pair, 
% get all the comparison data output a table containing the data 
% CorePassNum, EdgePassNum, Core90th, Core_Avg_Large, Core_Largest,
% Edge90th, Edge_Avg_Large, Edge_Largest,

% Plot a three panel figure per pair in the Region folder

region_folder = '../';
timestamps = readtable(fullfile(region_folder, region, 'core_edge_pairs.csv'));

edge_thermodynamics = dir(fullfile(region_folder, region, 'EdgeCloud', 'thermodynamics_*.csv'));
core_thermodynamics = dir(fullfile(region_folder, region, 'InCloud', 'thermodynamics_*.csv'));

core_summaryfile = readtable(fullfile(region_folder, region, 'InCloud', 'incloud_summary.csv'));

output_path = '../Entrainment_Analysis';
output_folder = fullfile(output_path, region);

% rows are core-edge pairs, columns are data
output = timestamps;

% get core data
% [core_90th_list, core_large_avg_list, core_largest_list] = get_core_90th(region)

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

Height_abvCB = [];
Pass_Temperature = [];


for r=1 : height(timestamps)
   % get droplet size data
   core_pass = timestamps{r,2}
   edge_pass = timestamps{r,1}
%    core_90th_pass = core_90th_list(core_pass);
%    [edge_90th_pass, edge_large_avg_pass, edge_largest_pass] = get_edge_90th(region, edge_pass, core_90th_pass);
%    core_90th = [core_90th; core_90th_pass];
%    core_large_avg = [core_large_avg; core_large_avg_list(core_pass)];
%    core_largest = [core_largest; core_largest_list(core_pass)];
%    edge_90th = [edge_90th; edge_90th_pass];
%    edge_large_avg = [edge_large_avg; edge_large_avg_pass];
%    edge_largest = [edge_largest; edge_largest_pass];
%    
%    % get cloudpass data
%    Height_abvCB = [Height_abvCB; core_summaryfile.HeightAboveCB(core_pass)];
%    Pass_Temperature = [Pass_Temperature; core_summaryfile.AverageTemp(core_pass)];
%    
   % Thermodynamics
    edge_thermofile = readtable(fullfile(edge_thermodynamics(edge_pass).folder, edge_thermodynamics(edge_pass).name));
    core_thermofile = readtable(fullfile(core_thermodynamics(core_pass).folder, core_thermodynamics(core_pass).name));
    LWC_edge = edge_thermofile.LWC_cdp;
    LWC_core = core_thermofile.LWC_cdp;
    vwind_edge = edge_thermofile.VerticalWind;
    vwind_core = core_thermofile.VerticalWind;
    
%     core_LWC_avg = [core_LWC_avg; mean(LWC_core,"omitnan")];
%     core_LWC_max = [core_LWC_max; max(LWC_core)];
%     core_LWC_min = [core_LWC_min; min(LWC_core)];
%     edge_LWC_avg = [edge_LWC_avg; mean(LWC_edge,"omitnan")];
%     edge_LWC_max = [edge_LWC_max; max(LWC_edge)];
%     edge_LWC_min = [edge_LWC_min; min(LWC_edge)];
% 
%     core_vwind_avg = [core_vwind_avg; mean(vwind_core,"omitnan")];
%     core_vwind_max = [core_vwind_max; max(vwind_core)];
%     core_vwind_min = [core_vwind_min; min(vwind_core)];
%     edge_vwind_avg = [edge_vwind_avg; mean(vwind_edge,"omitnan")];
%     edge_vwind_max = [edge_vwind_max; max(vwind_edge)];
%     edge_vwind_min = [edge_vwind_min; min(vwind_edge)];

    passname = region + "_" + "Edge" + edge_pass + "_Core" + core_pass;
    
    fig1 = figure(1);

    histogram(LWC_edge,  "DisplayName", "Edge", "FaceColor", "green");
    hold on
    histogram(LWC_core, "DisplayName", "Core", "FaceColor", "blue");
    hold off
    
    ylabel('Counts');
    xlabel('CDP Liquid Water Content (g/cm3)');
    grid on
    legend('location', 'best')
    

    saveas(fig1, sprintf('%s/%s_LWC.png', output_folder, passname));
    
        
    fig2 = figure(2);

    histogram(vwind_edge, "DisplayName", "Edge", "FaceColor", "red");
    hold on
    histogram(vwind_core, "DisplayName", "Core", "FaceColor", "cyan");
    hold off
    
    ylabel('Counts');
    xlabel('Vertical Wind Velocity m/s');
    grid on
    legend('location', 'best')
    

    saveas(fig2, sprintf('%s/%s_vwind.png', output_folder, passname));


end
   

   
   
   
end
