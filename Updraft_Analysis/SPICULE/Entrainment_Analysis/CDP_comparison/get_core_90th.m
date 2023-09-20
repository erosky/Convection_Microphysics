function [percentile_LIST, large_avg_LIST, largest_LIST] = get_core_90th(region)

% output list per cloudpass
% holodec 90th percentile

quicklook_path = '../../';
quicklooks = dir(fullfile(quicklook_path, region, 'InCloud', 'cdp_*.nc'));
percentile_LIST = [];
large_avg_LIST = [];
largest_LIST = [];

for q=1 : length(quicklooks)
    quicklookfile = fullfile(quicklooks(q).folder, quicklooks(q).name);
    
    times = ncread(quicklookfile, 'time');
    times = datetime(times,'ConvertFrom','datenum', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');

    starttime = times(1);
    endtime = times(end);

    bin_edges = ncread(quicklookfile, 'bin_edges');
    bins = ncread(quicklookfile, 'bins');


    % divide holodec data into time series - rows are time, columns are
    % concentration bins
    % bin holodec data the same as CDP bins

    holo_contours = transpose(ncread(quicklookfile, 'PSD'));

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
    percentile_SIZE = bins(holo_P);
    percentile_LIST = [percentile_LIST; percentile_SIZE];

    % Get average size larger than 90th
    larger = holo_sum(holo_P:end);
    larger_diameters = bins(holo_P:end);
    large_avg_SIZE = sum(larger.*larger_diameters)/sum(larger);
    large_avg_LIST = [large_avg_LIST; large_avg_SIZE];
    
    % Find largest droplet bin with at least 3 counts
    largest_SIZE = bins(find( holo_sum >= 0.1, 1, 'last' ));
    largest_LIST = [largest_LIST; largest_SIZE];
    
end

percentile_LIST
large_avg_LIST
largest_LIST

       

end




