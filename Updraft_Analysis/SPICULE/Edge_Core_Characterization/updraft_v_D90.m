
function out = updraft_v_D90(region)

% Use core D90 as reference. And core vwind as reference.
% For each 1Hz in the edge and core:
% Plot the D90/D90ref along y axis, and the vwind/vwindref along x_axis.
% Repeat for LWC?


% get core reference
region_folder = '../';
timestamps = readtable(fullfile(region_folder, region, 'core_edge_pairs.csv'));
edgetimes = readtable(fullfile(region_folder, region, 'EdgeCloud', 'timestamps.csv'));
coretimes = readtable(fullfile(region_folder, region, 'InCloud', 'timestamps.csv'));

edge_thermodynamics = dir(fullfile(region_folder, region, 'EdgeCloud', 'thermodynamics_*.csv'));
core_thermodynamics = dir(fullfile(region_folder, region, 'InCloud', 'thermodynamics_*.csv'));

holo_path = fullfile(region_folder, region,'/NCAR_reconstruction');
holo_data = dir(fullfile(holo_path, '*_HOLODEC.nc'));
holo_file = fullfile(holo_data.folder, holo_data.name);
holotimes = ncread(holo_file,'particletime');
diameters = ncread(holo_file,'d');

flightnum = split(region, "_");
flightnum = flightnum{1};
date_ref = split(holo_data.name, "_");
year = date_ref{2}(1:4);
month = date_ref{2}(5:6);
day = date_ref{2}(7:8);

timeshift = seconds(readtable(fullfile('../', 'holo_time_shift.csv')).(flightnum));
brightnessfolder = dir(fullfile('../Hologram_Brightness', flightnum, '*.mat'));
brightness_data = load(fullfile(brightnessfolder.folder, brightnessfolder.name)).data;
brightness_time = brightness_data.imagetime;
brightness_time = datetime(brightness_time, 'convertfrom', 'datenum') + timeshift;
brightness = brightness_data.brightness;

holotimes = datetime(str2double(year),str2double(month),str2double(day)) + seconds(holotimes(:,1));

output_path = '../Entrainment_Analysis';
output_folder = fullfile(output_path, region);

core_edge_stats = readtable(fullfile(output_folder, 'NCAR_reconstruction', 'cdf_comparison_table.csv'))

Drefs = core_edge_stats.Core_Dref;

for r=1 : height(timestamps)
   % get droplet size data
   core_pass = timestamps{r,2};
   edge_pass = timestamps{r,1};
   
   
    Dratio_core{r} = [];
    Dratio_edge{r} = [];
    vwindratio_edge{r} = [];
    vwindratio_core{r} = [];
    vwind_core_list{r} = [];
    vwind_edge_list{r} = [];

   
    edge_thermofile = readtable(fullfile(edge_thermodynamics(edge_pass).folder, edge_thermodynamics(edge_pass).name));
    core_thermofile = readtable(fullfile(core_thermodynamics(core_pass).folder, core_thermodynamics(core_pass).name));
    seconds_edge = edge_thermofile.Time;
    seconds_core = core_thermofile.Time;
    LWC_edge = edge_thermofile.LWC_cdp;
    LWC_core = core_thermofile.LWC_cdp;
    shadow_edge = edge_thermofile.TotalConc_cdp_cm3*pi.*((0.5*edge_thermofile.MeanDiam*10^(-4)).^2)*15;
    shadow_core = core_thermofile.TotalConc_cdp_cm3*pi.*((0.5*core_thermofile.MeanDiam*10^(-4)).^2)*15;
    vwind_edge = edge_thermofile.VerticalWind;
    vwind_core = core_thermofile.VerticalWind;
    
    Dref = Drefs(r)
    vwind_ref =  mean(vwind_core,"omitnan");
    
    % get D90/Dref for each timestep
    % first edge
    
    vwind_edge_1Hz = vwind_edge./vwind_ref;
    vwind_core_1Hz = vwind_core./vwind_ref;
    Dratio_edge_1Hz = [];
    Dratio_core_1Hz = [];
    
    for t = 1 : length(seconds_edge)
        if shadow_edge(t) < 0.015
        
            t_start = seconds_edge(t) + hours(12.0);
            t_end = t_start + seconds(1.0);
            edgeIndexes = (holotimes >= t_start) & (holotimes < t_end);
            edgeDiam = diameters(edgeIndexes);

            if sum(edgeIndexes) > 0
                C_query = 0:0.01:1.0;
                [C2, d2, Clo2, Cup2]  = ecdf(edgeDiam,'Bounds','on');
                edge_interp = interp1(C2, d2, C_query);
                edgeD = edge_interp(find(C_query==0.90));
                Dratio_edge_1Hz = [Dratio_edge_1Hz; edgeD/Dref];
            else
                Dratio_edge_1Hz = [Dratio_edge_1Hz; 0];
            end
        else
            Dratio_edge_1Hz = [Dratio_edge_1Hz; 0];
        end
    end
    

    for t = 1 : length(seconds_core)
        if shadow_core(t) < 0.015
            t_start = seconds_core(t) + hours(12.0);
            t_end = t_start + seconds(1.0);
            coreIndexes = (holotimes >= t_start) & (holotimes < t_end);
            coreDiam = diameters(coreIndexes);

            if sum(coreIndexes) > 0
                C_query = 0:0.01:1.0;
                [C2, d2, Clo2, Cup2]  = ecdf(coreDiam,'Bounds','on');
                core_interp = interp1(C2, d2, C_query);
                coreD = core_interp(find(C_query==0.90));
                Dratio_core_1Hz = [Dratio_core_1Hz; coreD/Dref];
            else
                Dratio_core_1Hz = [Dratio_core_1Hz; 0];
            end
        else
            Dratio_core_1Hz = [Dratio_core_1Hz; 0];
        end
    end
 
    Dratio_core{r} = [Dratio_core{r}, Dratio_core_1Hz];
    Dratio_edge{r} = [Dratio_edge{r}, Dratio_edge_1Hz];
    vwindratio_edge{r} = [vwindratio_edge{r}, vwind_edge_1Hz];
    vwindratio_core{r} = [vwindratio_core{r}, vwind_core_1Hz];
    vwind_core_list{r} = [vwind_core_list{r}, vwind_core];
    vwind_edge_list{r} = [vwind_edge_list{r}, vwind_edge];

    
    
%     core_LWC_avg = [core_LWC_avg; mean(LWC_core,"omitnan")];
%     core_LWC_max = [core_LWC_max; max(LWC_core)];
%     core_LWC_min = [core_LWC_min; min(LWC_core)];
%     edge_LWC_avg = [edge_LWC_avg; mean(LWC_edge,"omitnan")];
%     edge_LWC_max = [edge_LWC_max; max(LWC_edge)];
%     edge_LWC_min = [edge_LWC_min; min(LWC_edge)];
% 
%     vwind_ref = [core_vwind_avg; mean(vwind_core,"omitnan")];
%     core_vwind_max = [core_vwind_max; max(vwind_core)];
%     core_vwind_min = [core_vwind_min; min(vwind_core)];
%     edge_vwind_avg = [edge_vwind_avg; mean(vwind_edge,"omitnan")];
%     edge_vwind_max = [edge_vwind_max; max(vwind_edge)];
%     edge_vwind_min = [edge_vwind_min; min(vwind_edge)];
   
end

    CM = lines(height(timestamps));
    
    fig1 = figure(1);
    for R = 1:height(timestamps)
    scatter(cell2mat(vwindratio_edge(R)), cell2mat(Dratio_edge(R)), 50, CM(R,:), "o");
    hold on
    scatter(cell2mat(vwindratio_core(R)), cell2mat(Dratio_core(R)), 50, CM(R,:), "filled");
    end
    hold off
    
    ylabel('90th diameter ratio (normalized by average value in core)');
    xlabel('vwind ratio (normalized by avg core value)');
    ylim([0.6 1.4])
    grid on
    legend({'Edge','Core'}, 'location', 'best')


    saveas(fig1, sprintf('%s/%s_WINDvD90.png', output_folder, region));
    
    fig2 = figure(2);
    for R = 1:height(timestamps)
    scatter(cell2mat(vwind_edge_list(R)), cell2mat(Dratio_edge(R)), 50, CM(R,:), "o");
    hold on
    scatter(cell2mat(vwind_core_list(R)), cell2mat(Dratio_core(R)), 50, CM(R,:), "filled");
    end
    hold off
    
    ylabel('D_{90th} / D_{90th,adiabatic}');
    xlabel('vertical wind velocity (m/s)');
    ylim([0.7 1.3])
    grid on
    legend({'Edge','Core'}, 'location', 'best')
    

    saveas(fig2, sprintf('%s/%s_WINDvD90_ABSOLUTE.png', output_folder, region));
    savefig(fig2, sprintf('%s_WINDvD90_ABSOLUTE.fig', region));


end
