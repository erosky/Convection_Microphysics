function [] = plot_two_cdfs_continuous(quicklookfile1, quicklookfile2, titlestring, outputfolder);

quicklook1 = load(quicklookfile1); % loaded structure
diameters1 = quicklook1.ans.eqDiam*1000000;

quicklook2 = load(quicklookfile2); % loaded structure
diameters2 = quicklook2.ans.eqDiam*1000000;

C_query = 0:0.01:1.0;

[C1, d1, Clo1, Cup1]  = ecdf(diameters1,'Bounds','on');
[C2, d2, Clo2, Cup2]  = ecdf(diameters2,'Bounds','on');

core_interp = interp1(C1, d1, C_query);
edge_interp = interp1(C2, d2, C_query);

%Plot droplet size distribution in #/cc/um
fig = figure('visible','off');
ecdf(diameters1,'Bounds','on'); hold on
%plot(d1, C1, 'LineWidth', 2, 'DisplayName','Core')
hold on
ecdf(diameters2,'Bounds','on'); hold on
%plot(d2, C2, 'LineWidth', 2, 'DisplayName','Edge')
hold on

xlabel('Diameter (microns)'), ylabel('Mass CDF')
legend('Core','Lower Confidence Bound','Upper Confidence Bound','Edge','Location','best')
title(titlestring,  'interpreter', 'none')

saveas(fig, sprintf('%s/%s_masscdf.png', outputfolder, titlestring));