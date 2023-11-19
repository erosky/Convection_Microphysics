function [] = plot_two_cdfs_continuous(region, corestart, coreend, edgestart, edgeend, titlestring, max);

% high resoltion time series of holodec
holo_path = sprintf('../%s/NCAR_reconstruction', region);
holofile = dir(fullfile(holo_path, '*_HOLODEC.nc'));
holo_nc = fullfile(holo_path, holofile.name);

holotimes = ncread(holo_nc,'particletime');
diameters = ncread(holo_nc,'d');
totalN = length(diameters);

date_ref = split(holofile.name, "_")
year = date_ref{2}(1:4)
month = date_ref{2}(5:6)
day = date_ref{2}(7:8)


flightnum = split(region, "_");
flightnum = flightnum{1};

OFFSET = seconds(readtable(fullfile('../', 'holo_time_shift.csv')).(flightnum));
brightnessfolder = dir(fullfile('../Hologram_Brightness', flightnum, '*.mat'));
brightness_data = load(fullfile(brightnessfolder.folder, brightnessfolder.name)).data;
brightness_time = brightness_data.imagetime;
brightness_time = datetime(brightness_time, 'convertfrom', 'datenum') + OFFSET;
brightness = brightness_data.brightness;

holotimes = datetime(str2double(year),str2double(month),str2double(day)) + seconds(holotimes(:,1));
corebrightIndexes = (brightness_time >= corestart) & (brightness_time <= coreend);
edgebrightIndexes = (brightness_time >= edgestart) & (brightness_time <= edgeend);
coreIndexes = (holotimes >= corestart) & (holotimes <= coreend);
edgeIndexes = (holotimes >= edgestart) & (holotimes <= edgeend);

coreDiam = diameters(coreIndexes);
coreDiam = coreDiam(coreDiam > 12);
edgeDiam = diameters(edgeIndexes);
edgeDiam = edgeDiam(edgeDiam > 12);
coreBright = brightness(corebrightIndexes);
edgeBright = brightness(edgebrightIndexes);


% Find total sample volume of all holograms combined
dy = 1.0; %cm ***NEEDS TO BE CHECKED
dx = 1.44; %cm
dz = 13; %cm
sample_volume = dy*dx*dz; %cubic cm


% diameters1 = quicklook1.ans.eqDiam*1000000;
% diameters2 = quicklook2.ans.eqDiam*1000000;

C_query = 0:0.01:1.0;

[C1, d1, Clo1, Cup1]  = ecdf(coreDiam,'Bounds','off');
[C2, d2, Clo2, Cup2]  = ecdf(edgeDiam,'Bounds','off');

core_interp = interp1(C1, d1, C_query);
edge_interp = interp1(C2, d2, C_query);

%Plot droplet size distribution in #/cc/um
%ecdf(coreDiam,'Bounds','off'); hold on
plot(core_interp, C_query, 'LineWidth', 2, 'color', [0.4660 0.6740 0.1880])
hold on
%ecdf(edgeDiam,'Bounds','off'); hold on
plot(edge_interp, C_query, 'LineWidth', 2, 'color', [0.4940 0.1840 0.5560])
hold on
yline(0.90, 'Color',[0,0.7,0.9]);
text(max, 0.90, '90th percentile', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');


ylabel('CDF')
xlabel('')
title(titlestring)
