function check_gui_desktop(file,run_id)
% Run one inspected GUI at a time in MATLAB desktop; outcomes require review.
% Example: check_gui_desktop('.../code_eval/claude/Q3_r1.m','claude_Q3_r1')
root=fileparts(fileparts(mfilename('fullpath')));
beforeF=findall(groot,'Type','figure');beforeT=timerfindall;
log=fullfile(root,'results',[char(run_id) '_gui_log.txt']); diary(log);
cleanup=onCleanup(@() finish(beforeF,beforeT));
fprintf('MATLAB %s | %s | %s\n',version,char(datetime('now','TimeZone','local')),file);
try
 [folder,name]=fileparts(file);old=pwd;cd(folder);addpath(folder);
 pathCleanup=onCleanup(@() restore_path(old,folder));
 execute_gui_payload(file,name);
 drawnow;figs=setdiff(findall(groot,'Type','figure'),beforeF);
 fprintf('INIT: %d new figure(s). Initialization is not a dynamic pass.\n',numel(figs));
 if isempty(figs),return;end
 controls=findall(figs);
 startControl=[];stopControl=[];resetControl=[];
 for k=1:numel(controls)
  h=controls(k);label='';
  if isprop(h,'Text'),label=char(string(h.Text));elseif isprop(h,'String'),label=char(string(h.String));end
  if ~has_callback(h),continue;end
  if ~isempty(regexpi(label,'\b(start|run|play|begin|simulate)\b','once')),startControl=h;
  elseif ~isempty(regexpi(label,'\b(stop|pause)\b','once')),stopControl=h;
  elseif ~isempty(regexpi(label,'\breset\b','once')),resetControl=h;end
 end
 % Single-shot watchdog can release many blocking drawnow/pause loops.
 watchdog=timer('ExecutionMode','singleShot','StartDelay',4,'TimerFcn',@(~,~) emergency_stop(beforeF,beforeT,startControl,stopControl));
 start(watchdog); % handle name below avoids shadowing timer start
 if isempty(startControl),fprintf('START absent or ambiguous; review manually.\n');
 else,invoke(startControl,true);pause(3);drawnow;fprintf('START/UPDATE callbacks returned; verify changing graphics and diary manually.\n');end
 if ~isempty(stopControl),invoke(stopControl,false);fprintf('STOP invoked.\n');
 elseif ~isempty(startControl)&&isprop(startControl,'Value'),invoke(startControl,false);fprintf('State-button STOP invoked.\n');
 else,fprintf('STOP absent; not a pass.\n');end
 if ~isempty(resetControl),invoke(resetControl,false);drawnow;fprintf('RESET invoked; verify state manually.\n');else,fprintf('RESET absent.\n');end
catch err
 fprintf('%s\n',getReport(err,'extended','hyperlinks','off'));
end
fprintf('Manual review required: asynchronous timer errors and semantic positioning coverage are not inferred from callback return.\n');
end
function execute_gui_payload(file,name)
% Keep generated clear commands away from the runner's cleanup handles.
src=fileread(file);
active=regexp(src,'\r?\n','split');
active=active(~cellfun(@(s) isempty(strtrim(s))||startsWith(strtrim(s),'%'),active));
if ~isempty(active)&&startsWith(strtrim(active{1}),'function'),feval(name);else,run(file);end
end
function yes=has_callback(h)
yes=false;
for p={'ButtonPushedFcn','ValueChangedFcn','Callback'}
 if isprop(h,p{1})&&~isempty(h.(p{1})),yes=true;return;end
end
end
function invoke(h,state)
if isprop(h,'Value'),h.Value=state;end
for p={'ButtonPushedFcn','ValueChangedFcn','Callback'}
 if isprop(h,p{1})&&~isempty(h.(p{1})),cb=h.(p{1});break;end
end
if isa(cb,'function_handle'),cb(h,[]);elseif iscell(cb),feval(cb{1},h,[],cb{2:end});elseif ischar(cb)||isstring(cb),evalin('base',cb);end
end
function emergency_stop(beforeF,beforeT,startControl,stopControl)
try
 if ~isempty(stopControl)&&isvalid(stopControl),invoke(stopControl,false);
 elseif ~isempty(startControl)&&isvalid(startControl)&&isprop(startControl,'Value'),invoke(startControl,false);end
catch err,warning('Paper:Watchdog','%s',err.message);end
ts=setdiff(timerfindall,beforeT);
for k=1:numel(ts),if isvalid(ts(k)),stop(ts(k));end,end
% Close only new figures as a fallback; baseline user figures are retained.
delete(setdiff(findall(groot,'Type','figure'),beforeF));
end
function finish(beforeF,beforeT)
ts=setdiff(timerfindall,beforeT);
for k=1:numel(ts),if isvalid(ts(k)),stop(ts(k));delete(ts(k));end,end
delete(setdiff(findall(groot,'Type','figure'),beforeF));diary off;
end
function restore_path(old,folder)
cd(old);rmpath(folder);
end
