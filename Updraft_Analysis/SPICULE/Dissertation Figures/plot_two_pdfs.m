function [] = plot_two_pdfs(region, corestart, coreend, edgestart, edgeend, numberofbins, titlestring);

[Dcenters1, C1, err1] = pdf_test(region, corestart, coreend, numberofbins)
[Dcenters2, C2, err2] = pdf_test(region, edgestart, edgeend, numberofbins)


core_interp = interp1(Dcenters1, C1, 14.95);
edge_interp = interp1(Dcenters2, C2, 15.93);

%Plot droplet size distribution in #/cc/um
plot(Dcenters1, C1, 'LineWidth', 2, 'DisplayName','Core', 'color', [0.4660 0.6740 0.1880])
hold on
er = errorbar(Dcenters1, C1, err1, "o", 'LineWidth', 1, 'color', [0.4660 0.6740 0.1880],  'HandleVisibility','off');
hold on
plot(Dcenters2, C2, 'LineWidth', 2, 'DisplayName','Edge', 'color', [0.4940 0.1840 0.5560])
hold on
er = errorbar(Dcenters2, C2, err2, "o", 'LineWidth', 1, 'color', [0.4940 0.1840 0.5560],  'HandleVisibility','off');
hold on
% stem(14.95, core_interp,"filled", 'color', [0.4660 0.6740 0.1880])
% hold on
% stem(15.93, edge_interp,"filled", 'color', [0.4940 0.1840 0.5560])
% size(Dcenters1(4:end))
% size(C1(4:end))
% size(core_interp)

x = [14.95 14.95 Dcenters1(4:end)];
y = [0 core_interp transpose(C1(4:end))];
roi = drawpolygon(gca,'Position',[x;y]', 'color', [0.4660 0.6740 0.1880], "FaceAlpha", 0.2, "LineWidth", 0.1);

% xe = [15.93 15.93 Dcenters2(Dcenters2>15.93)];
% ye = [0 edge_interp transpose(C2(Dcenters2>15.93))];
% roie = drawpolygon(gca,'Position',[xe;ye]', 'color', [0.4940 0.1840 0.5560], "FaceAlpha", 0.2, "LineWidth", 0.1);
%set(gca,'YScale','log','XScale','log')
%set(gca,'YScale','log')
ylabel('Probability Density (\mum^{-1})')

title(titlestring)
