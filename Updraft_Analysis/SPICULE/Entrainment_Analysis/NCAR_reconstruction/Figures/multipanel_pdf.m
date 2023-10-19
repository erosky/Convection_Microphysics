function out = multipanel_pdf(region)

% get the core-edge pairs from core_edge_pairs.csv for each pair, 
% get all the comparison data output a table containing the data 
% CorePassNum, EdgePassNum, Core90th, Core_Avg_Large, Core_Largest,
% Edge90th, Edge_Avg_Large, Edge_Largest,

% Plot a three panel figure per pair in the Region folder

flightnum = split(region, "_");
flightnum = flightnum{1};

region_folder = '../../..';
timestamps = readtable(fullfile(region_folder, region, 'core_edge_pairs.csv'));

edge = readtable(fullfile(region_folder, region, 'EdgeCloud', 'timestamps.csv'));
core = readtable(fullfile(region_folder, region, 'InCloud', 'timestamps.csv'))

core_thermodynamics = dir(fullfile(region_folder, region, 'InCloud', 'thermodynamics_*.csv'));

output_path = '../';
output_folder = fullfile(output_path, region, 'NCAR_reconstruction');

fig1 = figure(1);
tcl = tiledlayout(height(timestamps),1);
max = 28;

for r=1 : height(timestamps)
    ax(r) = nexttile();
    
   % get droplet size data
   core_pass = timestamps{r,2}
   edge_pass = timestamps{r,1}
   
   corestart = core.StartTime(core_pass)
   coreend = core.EndTime(core_pass)
   
   edgestart = edge.StartTime(edge_pass)
   edgeend = edge.EndTime(edge_pass)
   
   
   % get height above cb
   core_thermofile = readtable(fullfile(core_thermodynamics(core_pass).folder, core_thermodynamics(core_pass).name));
   HeightAbvCB = mean(core_thermofile.HeightAbvCloudBase, "omitnan");
   
   titlestring = sprintf("%dm above cloud base", round(HeightAbvCB));
   plot_two_pdfs(region, corestart, coreend, edgestart, edgeend, 30, titlestring);
   
    grid on
end
    hold off

    xlabel('Droplet diameter (\mum)');
    legend({'adiabatic updraft', 'edge region'}, 'location', 'northeast')
    title(tcl, flightnum)
    linkaxes(ax)
    xlim([12 max])

end
