function rerun_v8_dynamic
root=fileparts(mfilename('fullpath'));diary(fullfile(root,'dynamic_log.txt'));
set(groot,'defaultFigureVisible','off');
names={'ChatGPT','Gemini','Claude','DeepSeek'};
files={'GPS_Dynamics_GUI_v2','gps_gui_simulation','GPS_Simulator','GPS_Simulation_GUI_v2'};
results=struct('assistant',{},'initialization',{},'dynamic',{},'reset',{},'error',{});
for i=1:4
 folder=fullfile(root,'..','code','generated',names{i});addpath(folder);
 r=struct('assistant',names{i},'initialization','FAIL','dynamic','NOT TESTED','reset','NOT TESTED','error','');
 fprintf('\n===== %s dynamic check =====\n',names{i});
 try
  feval(files{i});drawnow;r.initialization='PASS';
  figs=findall(groot,'Type','figure');before=capture_state(figs);
  try
  btn=find_button(figs,'start');
  if i==2
   stopper=timer('StartDelay',1,'TimerFcn',@(~,~) stop_state_button(btn));
   start(stopper);btn.Value=true;invoke_button(btn);
   if isvalid(stopper),delete(stopper);end
  else
   invoke_button(btn);
   ts=timerfindall;
   for k=1:numel(ts),stop(ts(k));end
   for step=1:5
    for k=1:numel(ts),cb=ts(k).TimerFcn;invoke_callback(cb,ts(k));end
   end
   stopbtn=find_button(figs,'stop');
   if isempty(stopbtn),stopbtn=find_button(figs,'pause');end
   if ~isempty(stopbtn),invoke_button(stopbtn);end
  end
  drawnow;after=capture_state(figs);
  assert(~isequaln(before,after),'No graphics or status change detected.');
  r.dynamic='PASS';fprintf('START/UPDATE/STOP PASS: displayed state changed.\n');
  catch err
   r.dynamic='FAIL';r.error=getReport(err,'extended','hyperlinks','off');fprintf('%s\n',r.error);
  end
  try
  resetbtn=find_button(figs,'reset');
  if ~isempty(resetbtn),invoke_button(resetbtn);drawnow;r.reset='PASS';fprintf('RESET PASS\n');end
  catch err
   r.reset='FAIL';r.error=[r.error newline getReport(err,'extended','hyperlinks','off')];fprintf('RESET FAIL: %s\n',err.message);
  end
  try
   target=fullfile(root,[names{i} '_verified.png']);
   if isa(figs(1),'matlab.ui.Figure') && strcmp(figs(1).WindowStyle,'normal') && isprop(figs(1),'NumberTitle') && strcmp(figs(1).NumberTitle,'off')
    try,exportapp(figs(1),target);catch,exportgraphics(figs(1),target);end
   else,exportgraphics(figs(1),target);end
  catch err
   fprintf('SCREENSHOT NOTE: %s\n',err.message);
  end
 catch err
  r.error=getReport(err,'extended','hyperlinks','off');
  if strcmp(r.initialization,'PASS'),r.dynamic='FAIL';end
  fprintf('%s\n',r.error);
 end
 results(end+1)=r;
 close all force;ts=timerfindall;if ~isempty(ts),delete(ts);end;rmpath(folder);
end
fid=fopen(fullfile(root,'dynamic_results.json'),'w');fwrite(fid,jsonencode(results),'char');fclose(fid);
for name={'reference_q1_point_charges','reference_q2_finite_wire'}
 folder=fullfile(root,'..','code');addpath(folder);
 fprintf('\n===== %s =====\n',name{1});
 try,invoke_reference(name{1});fprintf('REFERENCE PASS\n');catch err,fprintf('%s\n',getReport(err,'extended','hyperlinks','off'));end
 close all force;rmpath(folder);
end
diary off;
end
function invoke_reference(name)
eval(name);
end
function invoke_callback(cb,obj)
if isa(cb,'function_handle'),cb(obj,[]);elseif iscell(cb),feval(cb{1},obj,[],cb{2:end});else,error('Unsupported callback format');end
end
function invoke_button(btn)
if isprop(btn,'ButtonPushedFcn') && ~isempty(btn.ButtonPushedFcn),cb=btn.ButtonPushedFcn;
elseif isprop(btn,'ValueChangedFcn') && ~isempty(btn.ValueChangedFcn),cb=btn.ValueChangedFcn;
else,cb=btn.Callback;end
invoke_callback(cb,btn);
end
function stop_state_button(btn)
btn.Value=false;invoke_button(btn);
end
function b=find_button(figs,term)
b=[];
for obj=reshape(findall(figs),1,[])
 try
  if isprop(obj,'Text'),label=string(obj.Text);elseif isprop(obj,'String'),label=string(obj.String);else,continue;end
  if any(contains(lower(label),term)) && (isprop(obj,'ButtonPushedFcn') || isprop(obj,'ValueChangedFcn') || (isprop(obj,'Style') && strcmp(obj.Style,'pushbutton')))
   b=obj;return;
  end
 catch
 end
end
end
function state=capture_state(figs)
state={};
for obj=reshape(findall(figs),1,[])
 for prop={'XData','YData','ZData','Text','String'}
  try
   if isprop(obj,prop{1}),state{end+1}=get(obj,prop{1});end
  catch
  end
 end
end
end
