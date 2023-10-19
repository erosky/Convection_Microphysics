function [] = plot_two_pdfs(region, corestart, coreend, edgestart, edgeend, numberofbins, titlestring);

[Dcenters1, C1, err1] = pdf_test(region, corestart, coreend, numberofbins)
[Dcenters2, C2, err2] = pdf_test(region, edgestart, edgeend, numberofbins)

%Plot droplet size distribution in #/cc/um
plot(Dcenters1, C1, 'LineWidth', 2, 'DisplayName','Core', 'color', [0.4660 0.6740 0.1880])
hold on
er = errorbar(Dcenters1, C1, err1, "o", 'LineWidth', 1, 'color', [0.4660 0.6740 0.1880],  'HandleVisibility','off');
hold on
plot(Dcenters2, C2, 'LineWidth', 2, 'DisplayName','Edge', 'color', [0.4940 0.1840 0.5560])
hold on
er = errorbar(Dcenters2, C2, err2, "o", 'LineWidth', 1, 'color', [0.4940 0.1840 0.5560],  'HandleVisibility','off');
hold on
%set(gca,'YScale','log','XScale','log')
%set(gca,'YScale','log')
ylabel('Probability Density (\mum^{-1})')

title(titlestring)
