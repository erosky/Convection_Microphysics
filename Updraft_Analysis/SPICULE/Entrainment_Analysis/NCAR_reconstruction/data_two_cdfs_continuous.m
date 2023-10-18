function [C_query, core_interp, edge_interp] = data_two_cdfs_continuous(region, corestart, coreend, edgestart, edgeend);

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

holotimes = datetime(str2double(year),str2double(month),str2double(day)) + seconds(holotimes(:,1));
coreIndexes = (holotimes >= corestart) & (holotimes <= coreend);
edgeIndexes = (holotimes >= edgestart) & (holotimes <= edgeend);

coreDiam = diameters(coreIndexes);
edgeDiam = diameters(edgeIndexes);

C_query = 0:0.01:1.0;

[C1, d1, Clo1, Cup1]  = ecdf(coreDiam,'Bounds','on');
[C2, d2, Clo2, Cup2]  = ecdf(edgeDiam,'Bounds','on');

core_interp = interp1(C1, d1, C_query);
edge_interp = interp1(C2, d2, C_query);