function run_gui_repairs
% Human desktop review. No successful outcome is inferred from opening a GUI.
if ~usejava('desktop'),error('Paper:Desktop','Run in MATLAB desktop.');end
root=fileparts(fileparts(mfilename('fullpath')));
plan=readtable(fullfile(root,'logs','repair_runs.csv'),'TextType','string');
outFile=fullfile(root,'results','gui_repairs.csv');
out=table;
if isfile(outFile),out=readtable(outFile,'TextType','string');end
rater=inputdlg('Reviewer name','Paper 1 GUI review',1,{''});
if isempty(rater)||isempty(strtrim(rater{1})),return;end
for k=1:height(plan)
 p=plan(k,:);file=fullfile(root,p.file);
 if p.prompt_id~="Q3"||~isfile(file),continue;end
 id=p.assistant+"_Q3_r"+p.rep+"_v2";
 if ~isempty(out)&&any(out.run_id==id),continue;end
 beforeF=findall(groot,'Type','figure');beforeT=timerfindall;
 log=fullfile(root,'results',id+"_desktop_log.txt");diary(log);
 guard=onCleanup(@() cleanup_run(beforeF,beforeT));
 r=struct('run_id',id,'assistant',p.assistant,'prompt_id',p.prompt_id, ...
 'rep',p.rep,'version',p.version,'file',p.file,'init_ok',NaN, ...
 'start_ok',NaN,'update_ok',NaN,'stop_ok',NaN,'reset_ok',NaN, ...
 'error_message',"",'error_id',"",'error_line',NaN, ...
 'rater',string(rater{1}),'evidence',"",'matlab_version',string(version), ...
 'run_datetime',string(datetime('now','TimeZone','Asia/Bangkok')));
 try
  execute_file(char(file));drawnow;
  figs=setdiff(findall(groot,'Type','figure'),beforeF);
  r.init_ok=double(~isempty(figs));
  if isempty(figs),r.evidence="Execution returned with no GUI figure.";
  else
   save_views(figs,root,id+"_init");
   review=uifigure('Name',char(id+" review"),'Position',[100 100 500 230]);
   uilabel(review,'Position',[20 75 460 140],'WordWrap','on','Text', ...
    'Test the generated GUI: Start, observe satellite/user/range updates for at least 3 seconds, Stop/Pause, then Reset. Open the equations and function panels. Check the Command Window for callback errors. Save notes and click Review finished.');
   uibutton(review,'Position',[150 25 200 40],'Text','Review finished', ...
    'ButtonPushedFcn',@(~,~) uiresume(review));
   uiwait(review);if isvalid(review),delete(review);end
   save_views(setdiff(findall(groot,'Type','figure'),beforeF),root,id+"_after");
   answer=inputdlg({'Start 0/1 or blank if unobserved', ...
    'Dynamic updates 0/1 or blank','Stop/Pause 0/1 or blank', ...
    'Reset 0/1 or blank (absent button = 0)','Evidence, errors and elapsed observation'}, ...
    char(id),[1 75;1 75;1 75;1 75;5 75],{'','','','',''});
   if ~isempty(answer)
    fields={'start_ok','update_ok','stop_ok','reset_ok'};
    for j=1:4
     value=str2double(answer{j});
     if ismember(value,[0 1]),r.(fields{j})=value;end
    end
    r.evidence=string(answer{5});
   end
  end
 catch err
  r.init_ok=0;r.error_message=string(getReport(err,'extended','hyperlinks','off'));
  r.error_id=string(err.identifier);if ~isempty(err.stack),r.error_line=err.stack(1).line;end
  fprintf('%s\n',r.error_message);
 end
 diary off;clear guard;
 out=[out;struct2table(r)]; %#ok<AGROW>
 writetable(out,outFile); % checkpoint after each observed run
end
fprintf('GUI evidence saved to %s. Initial failures require a separate same-chat repair.\n',outFile);
end
function execute_file(file)
old=pwd;folder=fileparts(file);cd(folder);addpath(folder);
guard=onCleanup(@() restore(old,folder));
src=fileread(file);L=splitlines(string(src));
L=L(strlength(strtrim(L))>0 & ~startsWith(strtrim(L),'%'));
[~,name]=fileparts(file);
execute_payload(file,name,~isempty(L)&&startsWith(strtrim(L(1)),'function'));
end
function execute_payload(file,name,isFunction)
if isFunction,feval(name);else,run(file);end
end
function restore(old,folder)
cd(old);rmpath(folder);
end
function save_views(figs,root,id)
for j=1:numel(figs)
 target=fullfile(root,'results',id+"_fig"+j+".png");
 try,exportapp(figs(j),target);
 catch
  try,exportgraphics(figs(j),target,'Resolution',150);
  catch err,fprintf('Screenshot unavailable: %s\n',err.message);end
 end
end
end
function cleanup_run(beforeF,beforeT)
ts=setdiff(timerfindall,beforeT);
for j=1:numel(ts),if isvalid(ts(j)),stop(ts(j));delete(ts(j));end,end
delete(setdiff(findall(groot,'Type','figure'),beforeF));diary off;
end
