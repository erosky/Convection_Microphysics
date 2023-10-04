function [timestamps, D_timeseries, LWC] = holoNC_to_LWC(holo_nc, starttime, endtime, time_ref, size_cutoff)

water_density = 0.997E6 ; %g/m^3

holotimes = ncread(holo_nc,'particletime');
diameters = ncread(holo_nc,'d');
totalN = length(diameters);

holotimes(1)

OFFSET = -seconds(0.0);
holotimes = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(holotimes(:,1)) + OFFSET;
timeIndexes = (holotimes <= endtime) & (holotimes >= starttime);

holotimes = holotimes(timeIndexes);
diameters = diameters(timeIndexes);

% Find total sample volume of all holograms combined
dy = 1.0; %cm ***NEEDS TO BE CHECKED
dx = 1.44; %cm
dz = 13; %cm
sample_volume = dy*dx*dz; %cubic cm


% Group timeseries by unique timestamps
 timestamps = unique(holotimes);
 N_holo = length(timestamps);
 
 [tf,loc] = ismember(holotimes,unique(holotimes));
 for ni = 1:max(loc)
     D_timeseries{ni} = diameters(loc==ni);
 end
 
% make LWC timeseries
LWC = [];
for t = 1:N_holo
    Diams = cell2mat(D_timeseries(t)); 
    cutIndexes = (Diams >= size_cutoff);
    Diams = Diams(cutIndexes);
    Diams_m = Diams*10^-6; % convert diameters from um to m
    Vol = (1/6)*pi*Diams_m.^3;  % cubic meters (volume of each water droplet)
    Mass = water_density*Vol; % g
    holo_LWC = (sum(Mass)/sample_volume)*10^6; % g/m3
    LWC = [LWC; holo_LWC];
end

max(LWC)


end





