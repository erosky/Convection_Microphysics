function [C_query, core_interp, edge_interp] = data_two_cdfs_continuous(region, corestart, coreend, edgestart, edgeend);

% high resoltion time series of holodec
holo_path = sprintf('../../../%s/NCAR_reconstruction', region);
holofile = dir(fullfile(holo_path, '*_HOLODEC.nc'));
holo_nc = fullfile(holo_path, holofile.name);

holotimes = ncread(holo_nc,'particletime');
diameters = ncread(holo_nc,'d');
totalN = length(diameters);

date_ref = split(holofile.name, "_");
year = date_ref{2}(1:4);
month = date_ref{2}(5:6);
day = date_ref{2}(7:8);

holotimes = datetime(str2double(year),str2double(month),str2double(day)) + seconds(holotimes(:,1));

flight = split(region,"_");
flight = flight{1};
flight_nc = dir(fullfile('/data/emrosky-sim/Field_Projects/SPICULE/Data/LRT_Aircraft_2.1',sprintf('%s.*.nc',flight)));
ncfile = fullfile(flight_nc.folder, flight_nc.name);     

cdp_time = ncread(ncfile,'Time');
cdp_time = datetime(str2double(year),str2double(month),str2double(day)) + seconds(cdp_time(:,1));

cdp_coreIndexes = (cdp_time >= corestart) & (cdp_time <= coreend);
cdp_edgeIndexes = (cdp_time >= edgestart) & (cdp_time <= edgeend);
cdp_coretime = cdp_time(cdp_coreIndexes)
cdp_edgetime = cdp_time(cdp_edgeIndexes)

cdp_conc = ncread(ncfile, 'CONCD_LWOO');
cdp_Diam = ncread(ncfile,'DBARD_LWOO');

Z = 15;
coreShadow = pi*Z*cdp_conc(cdp_coreIndexes).*(((0.5*cdp_Diam(cdp_coreIndexes))*10^(-4)).^2);
edgeShadow = pi*Z*cdp_conc(cdp_edgeIndexes).*(((0.5*cdp_Diam(cdp_edgeIndexes))*10^(-4)).^2);


coreshadowIndexes = (coreShadow > 0.015); 
sum(coreshadowIndexes)
edgeshadowIndexes = (edgeShadow > 0.015); 
sum(edgeshadowIndexes)

% we have an array of a second timestamps that are to be removed
% for all the diameter timestamps, we check if the rounded to 1 sec value is equal to any of the values in the array of removed seconds
% if it is, then that timestep gets a value of 1, if its not its a 0

 

coreIndexes = (holotimes >= corestart) & (holotimes <= coreend) & ~ismember(dateshift(holotimes,'start','second'),cdp_coretime(coreshadowIndexes));
edgeIndexes = (holotimes >= edgestart) & (holotimes <= edgeend) & ~ismember(dateshift(holotimes,'start','second'),cdp_edgetime(edgeshadowIndexes));

coreDiam = diameters(coreIndexes);
edgeDiam = diameters(edgeIndexes);

C_query = 0:0.01:1.0;

    
[C1, d1, Clo1, Cup1]  = ecdf(coreDiam,'Bounds','on');
[C2, d2, Clo2, Cup2]  = ecdf(edgeDiam,'Bounds','on');

core_interp = interp1(C1, d1, C_query);
edge_interp = interp1(C2, d2, C_query);

