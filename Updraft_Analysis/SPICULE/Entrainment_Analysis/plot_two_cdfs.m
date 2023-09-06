function [] = plot_two_cdfs(quicklookfile1, quicklookfile2, numberofbins, titlestring, outputfolder);

[Dcenters1, C1, err1] = lwc_test(quicklookfile1, numberofbins)
[Dcenters2, C2, err2] = lwc_test(quicklookfile2, numberofbins)


%Plot droplet size distribution in #/cc/um
fig = figure('visible','off');
plot(Dcenters1.*1000000, C1, 'LineWidth', 2, 'DisplayName','Core')
hold on
%er = errorbar(Dcenters1.*1000000, C1, err1, "o", 'LineWidth', 1, 'Color', 'b',  'HandleVisibility','off');
hold on
plot(Dcenters2.*1000000, C2, 'LineWidth', 2, 'DisplayName','Edge')
hold on
%er = errorbar(Dcenters2.*1000000, C2, err2, "o", 'LineWidth', 1, 'Color', '#EDB120',  'HandleVisibility','off');
hold on
xlabel('Diameter (microns)'), ylabel('Mass (g)')
legend
title(titlestring,  'interpreter', 'none')

saveas(fig, sprintf('%s/%s_curves.png', outputfolder, titlestring));