% plot one slice of hologram

hologram = 'holoquicklook_RF04_2021-06-05-20-32-53_2021-06-05-20-33-01.mat';
particles = load('holoquicklook_RF04_2021-06-05-20-32-53_2021-06-05-20-33-01.mat');

ice_indexes = (particles.ans.holonum == 22 & particles.ans.majsiz >= 3e-5);
liq_indexes = (particles.ans.holonum == 22 & particles.ans.majsiz < 3e-5);

[x_ice, y_ice, z_ice] = deal(particles.ans.xpos(ice_indexes).*100, particles.ans.ypos(ice_indexes).*100, particles.ans.zpos(ice_indexes).*100);
[x_liq, y_liq, z_liq] = deal(particles.ans.xpos(liq_indexes).*100, particles.ans.ypos(liq_indexes).*100, particles.ans.zpos(liq_indexes).*100);

% Every third ypos gets moved to the center region

% convert um to cm

fig = figure()
scatter(z_liq, x_liq+0.8, 10, [0.9290 0.6940 0.1250], "filled")
hold on
scatter(z_ice, x_ice+0.8, 30, "black", "filled")

axis equal
xlim([3 13])
ylim([0 1.6])

ylabel('Y (cm)');
xlabel('X (cm)');

box on;

f = gcf;
exportgraphics(f,'test.png','Resolution',1000)


% droplets plotted as orange dots
% ice plotted with large black dot

