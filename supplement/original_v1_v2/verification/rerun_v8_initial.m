function rerun_v8_initial
root = fileparts(mfilename('fullpath'));
diary(fullfile(root,'matlab_log.txt'));
fprintf('MATLAB %s | %s\n',version,datestr(now));
set(groot,'defaultFigureVisible','off');
names={'ChatGPT','Gemini','Claude','DeepSeek'};
files={'Q11','Q12','Q21','Q22','GPS_Dynamics_GUI_v1';'Q11','Q12','Q21','Q22','gps_gui_simulation';'Q11','Q12','Q21','Q22','GPS_Simulator';'Q11','Q12','Q21','Q22','GPS_Simulation_GUI_v1'};
results=struct('assistant',{},'task',{},'status',{},'output',{},'error',{});
for a=1:4
 folder=fullfile(root,'..','code','generated',names{a});
 for t=1:5
  fprintf('\n===== %s %s =====\n',names{a},files{a,t});
  old=pwd;cd(folder);addpath(folder);
  r=struct('assistant',names{a},'task',files{a,t},'status','PASS','output','','error','');
  try
   r.output=evalc('invoke_file(files{a,t});');
   fprintf('%s',r.output);
  catch err
   r.status='FAIL';r.error=getReport(err,'extended','hyperlinks','off');fprintf('%s\n',r.error);
  end
  results(end+1)=r;
  close all force;
  ts=timerfindall;if ~isempty(ts),delete(ts);end
  rmpath(folder);cd(old);
 end
end
fid=fopen(fullfile(root,'results.json'),'w');fwrite(fid,jsonencode(results),'char');fclose(fid);
diary off;
end
function invoke_file(name)
eval(name);
end
