function [] = plot_two_cdfs_continuous(region, corestart, coreend, edgestart, edgeend, titlestring, outputfolder);

% high resoltion time series of holodec
holo_path = sprintf('../../%s/NCAR_reconstruction', region);
holofile = dir(fullfile(holo_path, '*_HOLODEC.nc'));
holo_nc = fullfile(holo_path, holofile.name);

holotimes = ncread(holo_nc,'particletime');
diameters = ncread(holo_nc,'d');
totalN = length(diameters);

date_ref = split(holofile.name, "_")
year = date_ref{2}(1:4)
month = date_ref{2}(5:6)
day = date_ref{2}(7:8)

OFFSET = -seconds(0.0);
holotimes = datetime(str2double(year),str2double(month),str2double(day)) + seconds(holotimes(:,1)) + OFFSET;
coreIndexes = (holotimes >= corestart) & (holotimes <= coreend);
edgeIndexes = (holotimes >= edgestart) & (holotimes <= edgeend);

coreDiam = diameters(coreIndexes);
edgeDiam = diameters(edgeIndexes);

% Find total sample volume of all holograms combined
dy = 1.0; %cm ***NEEDS TO BE CHECKED
dx = 1.44; %cm
dz = 13; %cm
sample_volume = dy*dx*dz; %cubic cm


% diameters1 = quicklook1.ans.eqDiam*1000000;
% diameters2 = quicklook2.ans.eqDiam*1000000;

C_query = 0:0.01:1.0;

[C1, d1, Clo1, Cup1]  = ecdf(coreDiam,'Bounds','on');
[C2, d2, Clo2, Cup2]  = ecdf(edgeDiam,'Bounds','on');

core_interp = interp1(C1, d1, C_query);
edge_interp = interp1(C2, d2, C_query);

%Plot droplet size distribution in #/cc/um
fig = figure('visible','off');
ecdf(coreDiam,'Bounds','on'); hold on
%plot(d1, C1, 'LineWidth', 2, 'DisplayName','Core')
hold on
ecdf(edgeDiam,'Bounds','on'); hold on
%plot(d2, C2, 'LineWidth', 2, 'DisplayName','Edge')
hold on

xlabel('Diameter (microns)'), ylabel('Mass CDF')
legend('Core','Lower Confidence Bound','Upper Confidence Bound','Edge','Location','best')
title(titlestring,  'interpreter', 'none')

saveas(fig, sprintf('%s/%s_cdf_NCAR.png', outputfolder, titlestring));