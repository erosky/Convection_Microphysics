% plot one slice of hologram

% hologram = 'holoquicklook_RF04_2021-06-05-20-32-53_2021-06-05-20-33-01.mat';
% particles = load('holoquicklook_RF04_2021-06-05-20-32-53_2021-06-05-20-33-01.mat');

particles = load('../holoquicklook_RF04_2021-06-05-20-33-01_2021-06-05-20-33-08.mat');

indexes = (particles.ans.holonum == 10 & particles.ans.majsiz >= 6e-6);

[x, y, z, d] = deal(particles.ans.xpos(indexes).*100, particles.ans.ypos(indexes).*100, particles.ans.zpos(indexes).*100, particles.ans.majsiz(indexes).*1000000);

% Every third ypos gets moved to the center region

% convert um to cm

fig1 = figure(1)

scatter3(z,y,x,d,'MarkerEdgeColor','#25705F','MarkerFaceColor','#C5E3DC','DisplayName','cloud droplets')
view(-30,20)
legend('Location','southeast')
set(gca,'fontsize',20)

axis equal
% xlim([3 13])
% ylim([0 1.6])

box on;

f = gcf;
exportgraphics(f,'test_3d.png','Resolution',1000)


% droplets plotted as orange dots
% ice plotted with large black dot

