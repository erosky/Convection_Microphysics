function [C_query, core_interp, edge_interp] = data_two_cdfs_continuous(quicklookfile1, quicklookfile2);

quicklook1 = load(quicklookfile1); % loaded structure
diameters1 = quicklook1.ans.eqDiam*1000000;

quicklook2 = load(quicklookfile2); % loaded structure
diameters2 = quicklook2.ans.eqDiam*1000000;

C_query = 0:0.01:1.0;

[C1, d1, Clo1, Cup1]  = ecdf(diameters1,'Bounds','on');
[C2, d2, Clo2, Cup2]  = ecdf(diameters2,'Bounds','on');

core_interp = interp1(C1, d1, C_query);
edge_interp = interp1(C2, d2, C_query);