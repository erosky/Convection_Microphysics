function [percentile_SIZE, large_avg_SIZE, largest_SIZE] = get_edge_90th(region, pass_num, core_90th)

% output list per cloudpass
% holodec 90th percentile

quicklook_path = '../';
quicklooks = dir(fullfile(quicklook_path, region, 'EdgeCloud', 'holoquicklook_*.mat'));

quicklookfile = fullfile(quicklooks(pass_num).folder, quicklooks(pass_num).name);
quicklook = load(quicklookfile); % loaded structure
diameters = quicklook.ans.majsiz;
totalN = length(diameters);


% numbins = numberofbins;
% Dcenters = [];
% N = [];


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

for n=1 : N_holograms
    h = index_search(n);
    totalN = quicklook.ans.counts(h);
    indexes = (quicklook.ans.holonum == h);
    h_diameters = diameters(indexes);
    particlesinbin = zeros(length(bins),1);
    for i = 1:length(bin_edges)-1
          b1 = bin_edges(i)*10^-6; %convert from um to m
          b2 = bin_edges(i+1)*10^-6;
          Dsinbin = find(h_diameters>=b1 & h_diameters<b2); % b1 is the lower diameter
          particlesinbin(i) = length(Dsinbin); %this is the number of particle diameters that fell between the bin edges    
    end
    if totalN > 0 
        N = particlesinbin;
    else N = 0;
    end
    C = particlesinbin./sample_volume;
    holo_contours(:,n) = C;
    N_contours(:,n) = N;

end


% % Liquid Water content of Holodec and CDP
% Using density of water, and diameter, calculate LWZ in g/m^3
% Density of water
rho_liquid = 997 * 1e3 ; %gm/m^3

% Find the 90th percentile
% plot cdf and find index where cdf reaches 90%
holo_sum = sum(holo_contours, 2);
totalholo_sum = sum(holo_sum);
holo_CDF = [];
for p = 1:length(bins)
    c = sum(holo_sum(1:p));
    holo_CDF = [holo_CDF; c]; 
end
holo_P = find( holo_CDF./totalholo_sum >= 0.95, 1 );
percentile_SIZE = bins(holo_P)

% Get average size larger than 90th
core_index = find( bins == core_90th, 1)
N_sum = sum(N_contours, 2);
larger = N_sum(core_index:end);
larger_diameters = bins(core_index:end);
large_avg_SIZE = sum(larger.*larger_diameters)/sum(larger)

% Find largest droplet bin with at least 3 counts
largest_SIZE = bins(find( N_sum >= 3, 1, 'last' ))



       

end

