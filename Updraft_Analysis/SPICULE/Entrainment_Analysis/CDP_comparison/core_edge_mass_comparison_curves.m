function out = core_edge_comparison_curves(region)

% get the core-edge pairs from core_edge_pairs.csv for each pair, 
% get all the comparison data output a table containing the data 
% CorePassNum, EdgePassNum, Core90th, Core_Avg_Large, Core_Largest,
% Edge90th, Edge_Avg_Large, Edge_Largest,

% Plot a three panel figure per pair in the Region folder

region_folder = '../../';
timestamps = readtable(fullfile(region_folder, region, 'core_edge_pairs.csv'));

edge_holo = dir(fullfile(region_folder, region, 'EdgeCloud', 'cdp_*.nc'));
core_holo = dir(fullfile(region_folder, region, 'InCloud', 'cdp_*.nc'));

output_path = '../';
output_folder = fullfile(output_path, region, 'CDP');


for r=1 : height(timestamps)
   % get droplet size data
   core_pass = timestamps{r,2}
   edge_pass = timestamps{r,1}
   
   titlestring = region + "_massCDF" + "Edge" + edge_pass + "_Core" + core_pass;
   plot_two_cdfs(fullfile(core_holo(core_pass).folder, core_holo(core_pass).name), fullfile(edge_holo(edge_pass).folder, edge_holo(edge_pass).name), titlestring, output_folder);
   
   
end


end
