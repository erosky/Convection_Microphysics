function out = fourpanel_figures(region)

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

HeightAbvCB = [];

for r=1 : height(timestamps)
   % get droplet size data
   core_pass = timestamps{r,2};
   edge_pass = timestamps{r,1};
   
    time_edge{r} = [];
    time_core{r} = [];
    Dratio_core{r} = [];
    Dratio_edge{r} = [];
    D90_core{r} = [];
    D90_edge{r} = [];
    D99_core{r} = [];
    D99_edge{r} = [];
    lwcratio_edge{r} = [];
    lwcratio_core{r} = [];
    lwc_core_list{r} = [];
    lwc_edge_list{r} = [];
    vwind_core_list{r} = [];
    vwind_edge_list{r} = [];

   
    edge_thermofile = readtable(fullfile(edge_thermodynamics(edge_pass).folder, edge_thermodynamics(edge_pass).name));
    core_thermofile = readtable(fullfile(core_thermodynamics(core_pass).folder, core_thermodynamics(core_pass).name));
    seconds_edge = edge_thermofile.Time;
    seconds_core = core_thermofile.Time;
    time_edge{r} = [time_edge{r}, seconds_edge];
    time_core{r} = [time_core{r}, seconds_core];
    
    HeightAbvCB = [HeightAbvCB; mean(core_thermofile.HeightAbvCloudBase, "omitnan")];
    
    LWC_edge = edge_thermofile.LWC_cdp;
    LWC_core = core_thermofile.LWC_cdp;
    vwind_edge = edge_thermofile.VerticalWind;
    vwind_core = core_thermofile.VerticalWind;
    
    
    Dref = Drefs(r)
    lwc_ref =  mean(LWC_core,"omitnan");
    
    % get D90/Dref for each timestep
    % first edge
    
    lwc_edge_1Hz = LWC_edge./lwc_ref;
    lwc_core_1Hz = LWC_core./lwc_ref;
    Dratio_edge_1Hz = [];
    Dratio_core_1Hz = [];
    coreD_list = [];
    edgeD_list = [];
    coreD99_list = [];
    edgeD99_list = [];
    
    for t = 1 : length(seconds_edge)
        t_start = seconds_edge(t) + hours(12.0);
        t_end = t_start + seconds(1.0);
        edgeIndexes = (holotimes >= t_start) & (holotimes < t_end);
        edgeDiam = diameters(edgeIndexes);

        if sum(edgeIndexes) > 0
            C_query = 0:0.001:1.0;
            [C2, d2, Clo2, Cup2]  = ecdf(edgeDiam,'Bounds','on');
            edge_interp = interp1(C2, d2, C_query);
            edgeD = edge_interp(find(C_query==0.90));
            edgeD99 = edge_interp(find(C_query==0.99));
            Dratio_edge_1Hz = [Dratio_edge_1Hz; edgeD/Dref];
            edgeD_list = [edgeD_list; edgeD];
            edgeD99_list = [edgeD99_list; edgeD99];
        else
            Dratio_edge_1Hz = [Dratio_edge_1Hz; 0];
            edgeD_list = [edgeD_list; nan];
            edgeD99_list = [edgeD99_list; nan];
        end
    end
    

    for t = 1 : length(seconds_core)
        t_start = seconds_core(t) + hours(12.0);
        t_end = t_start + seconds(1.0);
        coreIndexes = (holotimes >= t_start) & (holotimes < t_end);
        coreDiam = diameters(coreIndexes);

        if sum(coreIndexes) > 0
            C_query = 0:0.001:1.0;
            [C2, d2, Clo2, Cup2]  = ecdf(coreDiam,'Bounds','on');
            core_interp = interp1(C2, d2, C_query);
            coreD = core_interp(find(C_query==0.90));
            coreD99 = core_interp(find(C_query==0.99));
            Dratio_core_1Hz = [Dratio_core_1Hz; coreD/Dref];
            coreD_list = [coreD_list, coreD];
            coreD99_list = [coreD99_list, coreD99];
        else
            Dratio_core_1Hz = [Dratio_core_1Hz; 0];
            coreD_list = [coreD_list, nan];
            coreD99_list = [coreD99_list, nan];
        end
    end
 
    Dratio_core{r} = [Dratio_core{r}, Dratio_core_1Hz];
    Dratio_edge{r} = [Dratio_edge{r}, Dratio_edge_1Hz];
    lwcratio_edge{r} = [lwcratio_edge{r}, lwc_edge_1Hz];
    lwcratio_core{r} = [lwcratio_core{r}, lwc_core_1Hz];
    lwc_core_list{r} = [lwc_core_list{r}, LWC_core];
    lwc_edge_list{r} = [lwc_edge_list{r}, LWC_edge];
    vwind_core_list{r} = [vwind_core_list{r}, vwind_core];
    vwind_edge_list{r} = [vwind_edge_list{r}, vwind_edge];
    D90_core{r} = [D90_core{r}, coreD_list];
    D90_edge{r} = [D90_edge{r}, edgeD_list];
    D99_core{r} = [D99_core{r}, coreD99_list];
    D99_edge{r} = [D99_edge{r}, edgeD99_list];


    
    
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

    fig1 = figure(1);
    tiledlayout(height(timestamps),1);
    left_color = [0.6350 0.0780 0.1840];
    right_color = [0 .5 .5];
    set(fig1,'defaultAxesColorOrder',[left_color; right_color]);
    
    for R = 1:height(timestamps)
    ax = nexttile();
    title(sprintf("%dm above cloud base", round(HeightAbvCB(R))))
    yyaxis left
    patch([min(datenum(time_core{R})) max(datenum(time_core{R})) max(datenum(time_core{R})) min(datenum(time_core{R}))], [max(cell2mat(vwind_core_list(R)))+1 max(cell2mat(vwind_core_list(R)))+1 min(cell2mat(vwind_edge_list(R)))-1 min(cell2mat(vwind_edge_list(R)))-1], [0.4660 0.6740 0.1880], 'EdgeColor','none')
    hold on
    plot([datenum(time_edge{R})], cell2mat(vwind_edge_list(R)), "-", "DisplayName", "Edge", 'LineWidth', 3);
    hold on
    plot(datenum(time_core{R}), cell2mat(vwind_core_list(R)), "-", "DisplayName", "Core", 'LineWidth', 3);
    ylabel('Updraft (m/s)');

    yyaxis right
    plot(datenum(time_edge{R}), cell2mat(lwc_edge_list(R)), "--", "DisplayName", "Edge", 'LineWidth', 3);
    hold on
    
    plot(datenum(time_core{R}), cell2mat(lwc_core_list(R)), "--", "DisplayName", "Core", 'LineWidth', 3);
    hold on
    ylabel('LWC (g/m3)')
    
    datetick('x')
    %xtickangle(45)
    set(gca,'Xticklabel',[])
    xmin = mean(datenum(time_core{R})) - (max([datenum(time_core{R});datenum(time_edge{R})])-min([datenum(time_core{R});datenum(time_edge{R})]))
    xmax = mean(datenum(time_core{R})) + (max([datenum(time_core{R});datenum(time_edge{R})])-min([datenum(time_core{R});datenum(time_edge{R})]))
    xlim([xmin xmax])
    end
    hold off

    xlabel('time');
    grid on
    legend({'Core'}, 'location', 'best')
    
    
    fig2 = figure(2);
    tiledlayout(height(timestamps),1);
    
    for R = 1:height(timestamps)
    ax = nexttile();
    title(sprintf("%dm above cloud base", round(HeightAbvCB(R))))
    %patch([min(datenum(time_core{R})) max(datenum(time_core{R})) max(datenum(time_core{R})) min(datenum(time_core{R}))], [2 2 0 0], [0.4660 0.6740 0.1880])
    hold on
    scatter(datenum(time_edge{R}), cell2mat(D90_edge(R)), 50, [0.4940 0.1840 0.5560], "filled");
%     hold on
%     scatter(datenum(time_edge{R}), cell2mat(D99_edge(R)), 50, [0.4940 0.1840 0.5560], "filled");
    hold on
    scatter(datenum(time_core{R}), cell2mat(D90_core(R)), 50, [0.4660 0.6740 0.1880], "filled");
%     hold on
%     scatter(datenum(time_core{R}), cell2mat(D99_core(R)), 50, [0.4660 0.6740 0.1880], "filled");
    ylabel('diameter (um)');
    
    datetick('x')
    %xtickangle(45)
    set(gca,'Xticklabel',[])
    xmin = mean(datenum(time_core{R})) - (max([datenum(time_core{R});datenum(time_edge{R})])-min([datenum(time_core{R});datenum(time_edge{R})]))
    xmax = mean(datenum(time_core{R})) + (max([datenum(time_core{R});datenum(time_edge{R})])-min([datenum(time_core{R});datenum(time_edge{R})]))
    xlim([xmin xmax])
    grid on
    grid minor
    end
    hold off

    xlabel('time');
    legend({'outside core', 'inside core'}, 'location', 'best')

    %saveas(fig1, sprintf('%s/%s_LWCvD90.png', output_folder, region));


end