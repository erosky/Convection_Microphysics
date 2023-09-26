function out = shadow_density(region)

% Z = 15 cm
% X = 0.8 cm
% Y = 1.2 cm
% 
% N = droplet number concentration (CDP) #/cm^3
% R = effective radius of droplets (CDP) um
% 
% Total illuminated area A_h = X*Y
% 
% Total cross-sectional area of particles A_p
% = N*pi*(Re-4)^2*(X*Y*Z)
% 
% Shadow density = A_p / A_h
% = N*pi*(Re-4)^2*Z

Z = 15 %cm
X = 0.8 %cm
Y = 1.2 %cm

region_folder = '/data/emrosky-sim/Field_Projects/Convection_Microphysics/Updraft_Analysis/SPICULE';
timestamps = readtable(fullfile(region_folder, region, 'core_edge_pairs.csv'));

edge_thermodynamics = dir(fullfile(region_folder, region, 'EdgeCloud', 'thermodynamics_*.csv'));
core_thermodynamics = dir(fullfile(region_folder, region, 'InCloud', 'thermodynamics_*.csv'));

core_summaryfile = readtable(fullfile(region_folder, region, 'InCloud', 'incloud_summary.csv'));

output_path = '/data/emrosky-sim/Field_Projects/Convection_Microphysics/Updraft_Analysis/SPICULE/Entrainment_Analysis';
output_folder = fullfile(output_path, region);

% rows are core-edge pairs, columns are data
output = timestamps;

core_ShadowDensity = [];
edge_ShadowDensity = [];

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
    N_edge = mean(edge_thermofile.TotalConc_cdp_cm3,"omitnan");
    N_core = mean(core_thermofile.TotalConc_cdp_cm3,"omitnan");
    R_edge = mean(edge_thermofile.EffRadius_cdp,"omitnan");
    R_core = mean(core_thermofile.EffRadius_cdp,"omitnan");
    

    % Shadow density = A_p / A_h
    % = N*pi*(Re-4)^2*Z
    edge_shadow = N_edge*pi*((R_edge*10^(-4))^2)*Z;
    core_shadow = N_core*pi*((R_core*10^(-4))^2)*Z;
    
    core_ShadowDensity = [core_ShadowDensity; core_shadow];
    edge_ShadowDensity = [edge_ShadowDensity; edge_shadow];
    
end

output.Core_ShadowDensity = core_ShadowDensity;
output.Edge_ShadowDensity = edge_ShadowDensity;

output
writetable(output, fullfile(output_folder, 'ShadowDensityTable.csv'));




end
