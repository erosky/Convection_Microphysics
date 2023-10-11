function out = HOLODEC_v_LWC_concAdjust()

% get total conc of CDP larger than 12 um
% get total conc of holodec droplets larger than 12 um
% calculate volume adjustment to holodec that would make total conc equal
% to CDP total conc
% Then calculate holodec LWC using adjested volume
% Plot CDP LWC against adjusted holodec LWC

water_density = 0.997E6 ; %g/m^3
holo_sample_volume = 13.0995; %cm3/hologram

Directory = "../Entrainment_Analysis";
Regions = dir(fullfile(Directory, 'RF*_Region*'));

brightnessfolder = dir(fullfile('../Hologram_Brightness', '*.mat'));

output_folder = './';

% shadow_density = {};
% holo_brightness = {};
% LWC_difference = {};

for f = 1:length(Regions)
    
    shadow_density{f} = [];
    holo_brightness{f} = [];
    LWC_cdp{f} = [];
    LWC_holodec{f} = [];
    LWC_adjusted{f} = [];
    
    % Open up the cloudpass file
    region_folder = fullfile(Regions(f).folder, Regions(f).name);
    brightness_data = load(fullfile(brightnessfolder(f).folder, brightnessfolder(f).name)).data;
    
    directory = fullfile('../', Regions(f).name);
    
    cdp_folder = fullfile(directory, '/InCloud');    
    cdp_data = dir(fullfile(cdp_folder, 'cdp_*.nc'));

    
    time = brightness_data.imagetime; 
    time = datetime(time, 'convertfrom', 'datenum') - seconds(1.0); % 1 second offset to correct for holodec offset
    brightness = brightness_data.brightness;
    flightdate = brightness_data.flightdate;
    time_ref = split(flightdate, "/");

    holo_path = fullfile(directory,'/NCAR_reconstruction');
    holo_data = dir(fullfile(holo_path, '*_HOLODEC.nc'));
    holo_file = fullfile(holo_data.folder, holo_data.name);
    holotime = ncread(holo_file,'time');
    holo_region_LWC = ncread(holo_file,'lwc_round');
    holotime = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(holotime); 
    
    % Reformat time to human readable format
    % Given in netcdf file as seconds since 00:00:00 +0000 of flight date
    %time2 = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time);
    
    
    
    for p = 1 : size(cdp_data)
            
            
            core_cdpfile = fullfile(cdp_data(p).folder, cdp_data(p).name);
            N = ncread(core_cdpfile,'TotalConc');
            R = ncread(core_cdpfile,'MeanDiameter')/2;
            
            D_cdp = ncread(core_cdpfile, 'bins');
            cutoff = find(D_cdp >= 12, 1);
            D_cdp = D_cdp(cutoff:end);
   
            cdp_contours = transpose(ncread(core_cdpfile, 'PSD'));
            cdp_contours = cdp_contours(cutoff:end,:);
            cdp_conc = sum(cdp_contours); % droplets per m3
            cdp_LWC = [];
            size(cdp_contours,2)
            cdp_dropmass = []
            for d = 1 : size(D_cdp)
                D_center = D_cdp(d)*10^-6; % meters
                D_volume = (1/6)*pi*(D_center)^3;  % cubic meters (volume of each water droplet)
                D_Mass = water_density*D_volume; % g
                cdp_dropmass = [cdp_dropmass; D_Mass];
            end
                       
            cdp_perLWC = cdp_contours.*cdp_dropmass*10^6; % mass per bin g/cm3/um
            cdp_LWC = sum(cdp_perLWC) 
% 
%             holo_brightness{f} = [holo_brightness{f}; b_1Hz];
%             LWC_cdp{f} = [LWC_cdp{f}; cdp_LWC];
%             LWC_holodec{f} = [LWC_holodec{f}; holo_LWC];
%             LWC_adjusted{f} = [LWC_adjusted{f}; holo_LWC];
            
    end
end