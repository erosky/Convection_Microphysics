function out = LWC_edgecore(region)



region_folder = '/data/emrosky-sim/Field_Projects/Convection_Microphysics/Updraft_Analysis/SPICULE';
timestamps = readtable(fullfile(region_folder, region, 'core_edge_pairs.csv'));

edge_thermodynamics = dir(fullfile(region_folder, region, 'EdgeCloud', 'thermodynamics_*.csv'));
core_thermodynamics = dir(fullfile(region_folder, region, 'InCloud', 'thermodynamics_*.csv'));

core_summaryfile = readtable(fullfile(region_folder, region, 'InCloud', 'incloud_summary.csv'));

output_path = '/data/emrosky-sim/Field_Projects/Convection_Microphysics/Updraft_Analysis/SPICULE/Entrainment_Analysis';
output_folder = fullfile(output_path, region);

% rows are core-edge pairs, columns are data
output = timestamps;

core_LWC = [];
edge_LWC = [];
LWC_ratio = [];

Height_abvCB = [];
Pass_Temperature = [];



for r=1 : height(timestamps)
   % get droplet size data
   core_pass = timestamps{r,2}
   edge_pass = timestamps{r,1}
   
   % get cloudpass data
   Height_abvCB = [Height_abvCB; core_summaryfile.HeightAboveCB(core_pass)];
   Pass_Temperature = [Pass_Temperature; core_summaryfile.AverageTemp(core_pass)];
   
   % Thermodynamics
   edge_thermofile = readtable(fullfile(edge_thermodynamics(edge_pass).folder, edge_thermodynamics(edge_pass).name));
   core_thermofile = readtable(fullfile(core_thermodynamics(core_pass).folder, core_thermodynamics(core_pass).name));
    LWC_edge = mean(edge_thermofile.LWC_cdp,"omitnan");
    LWC_core = mean(core_thermofile.LWC_cdp,"omitnan");
    
    core_LWC = [core_LWC; LWC_core];
    edge_LWC = [edge_LWC; LWC_edge];
    LWC_ratio = [LWC_ratio; LWC_edge/LWC_core ];
    
    
end

output.core_LWC = core_LWC;
output.edge_LWC = edge_LWC;
output.LWC_ratio = LWC_ratio;

output
writetable(output, fullfile(output_folder, 'LWC_Table_CDP.csv'));




end
