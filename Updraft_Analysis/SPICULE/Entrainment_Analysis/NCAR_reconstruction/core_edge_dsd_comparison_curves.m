function out = core_edge_dsd_comparison_curves(region)

% get the core-edge pairs from core_edge_pairs.csv for each pair, 
% get all the comparison data output a table containing the data 
% CorePassNum, EdgePassNum, Core90th, Core_Avg_Large, Core_Largest,
% Edge90th, Edge_Avg_Large, Edge_Largest,

% Plot a three panel figure per pair in the Region folder

region_folder = '../../';
timestamps = readtable(fullfile(region_folder, region, 'core_edge_pairs.csv'));

edge = readtable(fullfile(region_folder, region, 'EdgeCloud', 'timestamps.csv'));
core = readtable(fullfile(region_folder, region, 'InCloud', 'timestamps.csv'))

output_path = '../';
output_folder = fullfile(output_path, region, 'NCAR_reconstruction');


for r=1 : height(timestamps)
   % get droplet size data
   core_pass = timestamps{r,2}
   edge_pass = timestamps{r,1}
   
   corestart = core.StartTime(core_pass)
   coreend = core.EndTime(core_pass)
   
   edgestart = edge.StartTime(edge_pass)
   edgeend = edge.EndTime(edge_pass)
   
   titlestring = region + "Edge" + edge_pass + "_Core" + core_pass;
   plot_two_pdfs(region, corestart, coreend, edgestart, edgeend, 30, titlestring, output_folder);
   
   
end


end
