function [timeseries, LWC] = holoquicklook_to_LWC(quicklookfile)

water_density = 0.997E6 ; %g/m^3

quicklook = load(quicklookfile); % loaded structure
diameters = quicklook.ans.majsiz;
totalN = length(diameters);


% Find total sample volume of all holograms combined
N_holograms = length(quicklook.ans.counts);
holotimes = datetime(quicklook.ans.time,'ConvertFrom','datenum', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
holotimes = sortrows(holotimes);
dy = 2*0.28; %cm
dx = 1.44; %cm
dz = 13; %cm
sample_volume = dy*dx*dz; %cubic cm

starttime = holotimes(1);
endtime = holotimes(end);


bin_edges = [4.5:1.0:200.5];
bins = [];
for b = 1 : length(bin_edges)-1
    center = (bin_edges(b) + bin_edges(b+1))/2;
    bins = [bins; center];
end


% divide holodec data into time series - rows are time, columns are
% concentration bins
% bin holodec data the same as CDP bins

holo_contours = zeros(length(bins),N_holograms);
N_contours = zeros(length(bins),N_holograms);
N_time_table = [quicklook.ans.time, transpose(1:N_holograms)];
N_time_table = sortrows(N_time_table);
index_search = N_time_table(:,2);
timeseries = N_time_table(:,1);
LWC = [];

for n=1 : N_holograms
    h = index_search(n);
    totalN = quicklook.ans.counts(h);
    indexes = (quicklook.ans.holonum == h);
    h_diameters = diameters(indexes);
    holo_volume_array = (1/6)*pi*h_diameters.^3;  %cubic meters (volume of each water droplet)
    holo_mass_array = water_density*holo_volume_array; % g
    holo_total_mass = sum(holo_mass_array);
    holo_LWC = (holo_total_mass/sample_volume)*10^6; % g/m3
    LWC = [LWC; holo_LWC];

end







