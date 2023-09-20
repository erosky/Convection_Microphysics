function [percentile_SIZE, large_avg_SIZE, largest_SIZE] = get_edge_90th(region, pass_num, core_90th)

% output list per cloudpass
% holodec 90th percentile

quicklook_path = '../../';
quicklooks = dir(fullfile(quicklook_path, region, 'EdgeCloud', 'cdp_*.nc'));

quicklookfile = fullfile(quicklooks(pass_num).folder, quicklooks(pass_num).name);

times = ncread(quicklookfile, 'time');
times = datetime(times,'ConvertFrom','datenum', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');

starttime = times(1);
endtime = times(end);

bin_edges = ncread(quicklookfile, 'bin_edges');
bins = ncread(quicklookfile, 'bins');

holo_contours = transpose(ncread(quicklookfile, 'PSD'));


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
percentile_SIZE = bins(holo_P);

% Get average size larger than 90th
core_index = find( bins == core_90th, 1)
holo_sum = sum(holo_contours, 2);
larger = holo_sum(core_index:end);
larger_diameters = bins(core_index:end);
large_avg_SIZE = sum(larger.*larger_diameters)/sum(larger)

% Find largest droplet bin with at least 3 counts
largest_SIZE = bins(find( holo_sum >= 0.1, 1, 'last' ))



       

end

