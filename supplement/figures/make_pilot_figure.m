function make_pilot_figure
% Replot of observed pilot values, not new assistant responses.
root=fileparts(fileparts(mfilename('fullpath')));
B=[-9.141924e-8 1.371289e-7 0;-9.1419e-8 1.3713e-7 0;-5.6104e-8 8.4156e-8 0;5.61037e-8 -8.41555e-8 0];
ref=[-9.141924341e-8 1.371288651e-7 0;-9.141924341e-8 1.371288651e-7 0;-5.610366841e-8 8.415550262e-8 0;-5.610366841e-8 8.415550262e-8 0];
names={'(a) ChatGPT  midpoint','(b) Gemini  midpoint','(c) Claude  endpoint','(d) DeepSeek  endpoint'};
f=figure('Visible','off','Color','white','Units','inches','Position',[1 1 4.5 3.0]);
layout=tiledlayout(f,2,2,'TileSpacing','compact','Padding','compact');
for k=1:4
 ax=nexttile(layout);hold(ax,'on');
 if k<=2,z=[-1 1];else,z=[0 2];end
 plot3(ax,[.25 .25],[.5 .5],z,'k-','LineWidth',2);
 plot3(ax,1,1,0,'ko','MarkerFaceColor','k','MarkerSize',3);
 % Shared display scale preserves the original vector magnitudes and signs.
 scale=4e6;
 quiver3(ax,1,1,0,scale*ref(k,1),scale*ref(k,2),0,0,'Color',[.65 .65 .65],'LineWidth',3,'MaxHeadSize',.6);
 quiver3(ax,1,1,0,scale*B(k,1),scale*B(k,2),0,0,'Color',[0 .3 .7],'LineWidth',1.7,'MaxHeadSize',.6);
 title(ax,names{k},'FontSize',8,'FontWeight','normal');
 xlabel(ax,'x (m)');ylabel(ax,'y (m)');zlabel(ax,'z (m)');
 axis(ax,'equal');xlim(ax,[-.1 1.7]);ylim(ax,[.1 1.8]);zlim(ax,[-1.2 2.2]);
 view(ax,[-35 23]);grid(ax,'on');set(ax,'FontSize',8);
end
exportgraphics(f,fullfile(root,'figures','Fig1_pilot_Q21_600dpi.png'),'Resolution',600);
exportgraphics(f,fullfile(root,'figures','Fig1_pilot_Q21.pdf'),'ContentType','vector');close(f);
fid=fopen(fullfile(root,'figures','Fig1_provenance.txt'),'w');
fprintf(fid,'Reconstructed from original_v1_v2/verification/matlab_log.txt, Q21 sections. Gemini and Claude values are rounded as printed. Blue: observed analytical result. Gray: matching-geometry reference. Shared display scale 4e6 m/T. Not newly collected data. DeepSeek numerical result is reported separately in paper text.\n');fclose(fid);
end
