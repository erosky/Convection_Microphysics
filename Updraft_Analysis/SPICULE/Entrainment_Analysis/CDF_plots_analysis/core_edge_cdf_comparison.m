function out = core_edge_mass_comparison(region)

% get the core-edge pairs from core_edge_pairs.csv for each pair, 
% get all the comparison data output a table containing the data 
% CorePassNum, EdgePassNum, Core90th, Core_Avg_Large, Core_Largest,
% Edge90th, Edge_Avg_Large, Edge_Largest,

% Plot a three panel figure per pair in the Region folder

region_folder = '/data/emrosky-sim/Field_Projects/Convection_Microphysics/Updraft_Analysis/SPICULE';
timestamps = readtable(fullfile(region_folder, region, 'core_edge_pairs.csv'));

edge_holo = dir(fullfile(region_folder, region, 'EdgeCloud', 'holoquicklook_*.mat'))
core_holo = dir(fullfile(region_folder, region, 'holoquicklook_*.mat'))

edge_thermodynamics = dir(fullfile(region_folder, region, 'EdgeCloud', 'thermodynamics_*.csv'));
core_thermodynamics = dir(fullfile(region_folder, region, 'InCloud', 'thermodynamics_*.csv'));

core_summaryfile = readtable(fullfile(region_folder, region, 'InCloud', 'incloud_summary.csv'));

output_path = '/data/emrosky-sim/Field_Projects/Convection_Microphysics/Updraft_Analysis/SPICULE/Entrainment_Analysis';
output_folder = fullfile(output_path, region);

% rows are core-edge pairs, columns are data
output = timestamps;

core_Dref = [];
edge_PDref = [];

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
   
   % CDF data
   [C_query, core_interp, edge_interp] = data_two_cdfs_continuous(fullfile(core_holo(core_pass).folder, core_holo(core_pass).name), fullfile(edge_holo(edge_pass).folder, edge_holo(edge_pass).name));
   edge_interp
   Dref = core_interp(find(C_query==0.90))
   [ d, ix ] = min( abs( edge_interp-Dref ) )
   %PDref = C_query(interp1(edge_interp,1:length(edge_interp),Dref,'nearest'))
   PDref = C_query(ix)
   core_Dref = [core_Dref; Dref];
   edge_PDref = [edge_PDref; PDref];
   
   % get cloudpass data
   Height_abvCB = [Height_abvCB; core_summaryfile.HeightAboveCB(core_pass)];
   Pass_Temperature = [Pass_Temperature; core_summaryfile.AverageTemp(core_pass)];
   
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
 
   
   
   
end

output.HeightAboveCB = Height_abvCB;
output.Temperature = Pass_Temperature
output.Core_Dref = core_Dref;
output.Edge_PDref = edge_PDref;


output
writetable(output, fullfile(output_folder, 'cdf_comparison_table.csv'));




end
