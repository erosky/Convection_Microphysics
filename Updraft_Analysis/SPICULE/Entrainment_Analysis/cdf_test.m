function [h, stats] = cdf_test(quicklookfile);
% return bin centers and number of particles in the bin

quicklook = load(quicklookfile); % loaded structure
diameters = quicklook.ans.eqDiam;
totalN = length(diameters);


% Find total sample volume of all holograms combined
samples = length(quicklook.ans.counts)
dy = 2*0.28; %cm
dx = 1.44; %cm
dz = 13; %cm
sample_volume = dy*dx*dz; %cubic cm
volume = samples*sample_volume; %cubic cm
water_density = 1.0E6; %grams per cubic meter


[h,stats] = cdfplot(diameters);





%Plot droplet size distribution in #/cc/um
%figure
%semilogy(Dcenters.*1000000,C), 
%xlabel('Diameter (microns)'), ylabel('Concentration (#/cc/micron)')
%title('DSD from SPICULE Holodec')

% fig = figure(1);
% %Concentration contour
% levels = 10.^(linspace(0,4,20));  %Log10 levels
% contourf(time, bins, transpose(conc), levels, 'LineStyle', 'none');
% if ~isempty(SIZE)
% hold on
% yline(SIZE,'-',sprintf('90th percentile: %0.2f',SIZE));
% end
% hold off
% datetick('x')
% set(gca,'ColorScale','log');
% grid on
% 
% xlabel('Time')
% ylabel('Diameter (microns)');
% c=colorbar;
% set(gca,'ColorScale','log');
% c.Label.String = 'Concentration (#/cc/um)';






