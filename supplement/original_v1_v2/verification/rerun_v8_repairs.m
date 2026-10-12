function rerun_v8_repairs
root=fileparts(mfilename('fullpath'));diary(fullfile(root,'repair_log.txt'));
set(groot,'defaultFigureVisible','off');
names={'ChatGPT','DeepSeek'};files={'GPS_Dynamics_GUI_v2','GPS_Simulation_GUI_v2'};
for i=1:2
 folder=fullfile(root,'..','code','generated',names{i});addpath(folder);
 fprintf('\n===== %s archived repair =====\n',names{i});
 try, feval(files{i});drawnow;fprintf('INITIALIZATION PASS\n');
 catch err,fprintf('%s\n',getReport(err,'extended','hyperlinks','off'));end
 close all force;ts=timerfindall;if ~isempty(ts),delete(ts);end;rmpath(folder);
end
diary off;
end
