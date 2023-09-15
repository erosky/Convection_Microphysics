function [LWC_holo, LWC_cdp, LWC_king] = lwc_test(region, flightnumber);
% return timeseries of LWC for each instrument
% one time-series per cloudpass 

directory = fullfile('/data/emrosky-sim/Field_Projects/Convection_Microphysics/Updraft_Analysis/SPICULE/',region);

edge_holo = dir(fullfile(directory, 'EdgeCloud', 'holoquicklook_*.mat'))
core_holo = dir(fullfile(directory, 'holoquicklook_*.mat'))

nc_path = '/data/emrosky-sim/Field_Projects/SPICULE/Data/LRT_Aircraft_2.1';
flight_nc = dir(fullfile(nc_path, sprintf('%s.*.nc', flightnumber)));
ncfile = fullfile(nc_path, flight_nc.name);

edge_folder = fullfile(directory, '/EdgeCloud');
core_folder = fullfile(directory, '/InCloud');
edge_timestamps = readtable(fullfile(edge_folder, 'timestamps.csv'));
core_timestamps = readtable(fullfile(core_folder, 'timestamps.csv'));



size_threshold = 12; % 12um lower cutoff for holodec data
water_density = 1.0E6; %grams per cubic meter


%Get data from the netCDF file
time = ncread(ncfile,'Time');
flightdate = ncreadatt(ncfile, '/', 'FlightDate');
time_ref = split(flightdate, "/");

% variables
lwc_king = ncread(ncfile,'PLWCC');
lwc_cdp = ncread(ncfile,'PLWCD_LWOO');
cdp_conc = ncread(ncfile, 'CCDP_LWOO');
cdp_edges = ncreadatt(ncfile, 'CCDP_LWOO', 'CellSizes');

% Reshape the concentration array into two dimensions
s = size(cdp_conc);
conc2 = reshape(cdp_conc, [s(1), s(3)]);

% Reformat time to human readable format
% Given in netcdf file as seconds since 00:00:00 +0000 of flight date
time2 = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time(:,1));

% Go through core passes

core_output = table('Size',[0 6],...
                        'VariableTypes',{'datetime','datetime','double','double','double','double'},...
                        'VariableNames', ["StartTime", "EndTime", "LWC_cdp", "cdp_LWC_whole", "LWC_king", "LWC_holo"]);

for p = 1 : size(core_timestamps)

                    
    starttime = core_timestamps.StartTime(p);
    endtime = core_timestamps.EndTime(p);
    timeIndexes = (time2 <= endtime) & (time2 >= starttime);
   
    
    % Calculate CDP LWC larger than size threshold of holodec
    %    units         = '#/cm3'
    %    CellSizeUnits = 'micrometers'
    %    CellSizeNote  = 'CellSizes are upper bin limits as diameter.'
    
    % find bin size that is greater or equal to the size cuttoff (12um)
    bin_cutoff = find(cdp_edges >= size_threshold, 1);
    % this will be the lower bound of cdp bins
    bound_edges = cdp_edges(bin_cutoff:end);
    cdp_diameters = [];
    for b = 1 : length(bound_edges)-1
     center = (bound_edges(b) + bound_edges(b+1))/2;
     cdp_diameters = [cdp_diameters; center];
    end
    
    cdp_concentrations = conc2(bin_cutoff:end,timeIndexes);
    
    % calculate LWC in the cdp bound bins
    volume_array = (1/6)*pi*(1.0E-6*cdp_diameters).^3;  %cubic meters (volume of one water droplet in this bin)
    per_droplet_mass_array = water_density*volume_array; %g (mass of one water droplet in this bin)
    mass_array = (per_droplet_mass_array.*cdp_concentrations)*10^6; % g/m3
    cdp_LWC = sum(mass_array,1); % g/m3
    
    
    % Calculate LWC in holodec diameters larger than lower size threshold
    quicklook = load(fullfile(core_holo(p).folder, core_holo(p).name));
    % Find total sample volume of all holograms combined
    N_holograms = length(quicklook.ans.counts);
    dy = 2*0.28; %cm
    dx = 1.44; %cm
    dz = 13; %cm
    sample_volume = dy*dx*dz; %cubic cm
    holo_volume = sample_volume*N_holograms; %cubic cm
    
    
    holo_diameters = quicklook.ans.majsiz; %m
    diameterIndexes = holo_diameters*1000000 >= 12;
    holo_diameters = holo_diameters(diameterIndexes)
    
    holo_volume_array = (1/6)*pi*holo_diameters.^3;  %cubic meters (volume of each water droplet)
    holo_mass_array = water_density*holo_volume_array; % g
    holo_total_mass = sum(holo_mass_array)
    holo_LWC = (holo_total_mass/holo_volume)*10^6 % g/m3
    
   
     pass = {starttime, endtime, nanmean(cdp_LWC), nanmean(lwc_cdp(timeIndexes)), nanmean(lwc_king(timeIndexes)),holo_LWC};
     core_output = [core_output;pass];

    
%          % Save cloudpass data
%     output = table('Size', [length(time2(timeIndexes)) 0]);
%     output.Time = time2(timeIndexes);
%     output.king_LWC = lwc_king(timeIndexes);
%     output.cdp_LWC_whole = lwc_cdp(timeIndexes);
%     output.cdp_LWC = transpose(cdp_LWC);


%      date_txt = string(startcore, 'yyyy-MM-dd-HH-mm-ss') + '_' + string(endcore, 'yyyy-MM-dd-HH-mm-ss');
%      outputname = LWC + "_" + flightnumber + "_" + date_txt;
%      writetable(output, sprintf('%s/%s.png', core_folder, outputname), 'WriteMode','overwrite');
     
end

core_output

figure
scatter(core_output.LWC_king, core_output.LWC_holo, "filled", 'DisplayName', 'King vs Holodec')
hold on
scatter(core_output.LWC_king, core_output.LWC_cdp, "filled", 'DisplayName', 'King vs CDP')
hold on
scatter(core_output.LWC_king, core_output.cdp_LWC_whole, 'DisplayName', 'King vs full CDP')
hold on
plot(xlim,ylim,'-b')
axis equal
xlabel('King probe LWC'), ylabel('LWC for >12um')
legend('Location', 'northeastoutside')


% Save cloudpass data
% core_filename = fullfile(folder, 'LWC_values.csv');
% writetable(core_output, sprintf('%s/%s.png', core_folder, core_filename),'WriteMode','overwrite');

% Go through edge passes



end





