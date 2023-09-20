function [] = plot_two_cdfs(ncfileCORE, ncfileEDGE, titlestring, outputfolder);

Dcenters1 = ncread(ncfileCORE, 'bins');
Dcenters2 = ncread(ncfileEDGE, 'bins')

contours1 = transpose(ncread(ncfileCORE, 'PSD'));
contours2 = transpose(ncread(ncfileEDGE, 'PSD'));


rho_liquid = 997 * 1e3 ; %gm/m^3

% Find the 90th percentile
% plot cdf and find index where cdf reaches 90%
sum1 = sum(contours1, 2);
total_sum1 = sum(sum1);
sum2 = sum(contours2, 2);
total_sum2 = sum(sum2);
C1 = [];
C2 = [];
for p = 1:length(Dcenters1)
    c = sum(sum1(1:p));
    C1 = [C1; c]; 
end

for p = 1:length(Dcenters2)
    c = sum(sum2(1:p));
    C2 = [C2; c]; 
end

C1 = C1/total_sum1;
C2 = C2/total_sum2;


%Plot droplet size distribution in #/cc/um
fig = figure('visible','off');
stairs(Dcenters1, C1, 'LineWidth', 2, 'DisplayName','Core')
hold on
stairs(Dcenters2, C2, 'LineWidth', 2, 'DisplayName','Edge')
hold on
xlabel('Diameter (microns)'), ylabel('Mass (g)')
xlim([0 30])
legend
title(titlestring,  'interpreter', 'none')

saveas(fig, sprintf('%s/%s_curves.png', outputfolder, titlestring));