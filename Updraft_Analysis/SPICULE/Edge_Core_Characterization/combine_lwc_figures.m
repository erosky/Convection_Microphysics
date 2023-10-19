fig(1) = openfig('RF01_Region01_LWCvD90.fig'); % open figure
fig(2) = openfig('RF02_Region01_LWCvD90.fig'); % open figure
fig(3) = openfig('RF04_Region01_LWCvD90.fig'); % open figure
fig(4) = openfig('RF08_Region02_LWCvD90.fig'); % open figure
new_fig = figure;
ax_new = gobjects(size(fig));

titles = {'RF01', 'RF02', 'RF04', 'RF08'}
for i=1:4
    ax = subplot(4,1,i);
    ax_old = findobj(fig(i), 'type', 'axes');
    ax_new(i) = copyobj(ax_old, new_fig);
    ax_new(i).YLimMode = 'manual';
    ax_new(i).Position = ax.Position;
    ax_new(i).Position(4) = ax_new(i).Position(4)-0.02;
    delete(ax);
    title(titles(i))
end
linkaxes(ax_new,'xy')