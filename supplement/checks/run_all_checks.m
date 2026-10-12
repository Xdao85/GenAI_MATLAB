function run_all_checks
% Desktop field checks. Candidate classifications require human confirmation.
root=fileparts(fileparts(mfilename('fullpath')));
plan=readtable(fullfile(root,'logs','planned_runs.csv'),'TextType','string');
out=struct([]); diary(fullfile(root,'results','desktop_checks_log.txt'));
cleanup=onCleanup(@() diary('off'));
for k=1:height(plan)
 p=plan(k,:); file=fullfile(root,p.file);
 if ~isfile(file), continue; end % Missing data must not be scored as failure.
 if p.prompt_id=="Q3", continue; end % Use check_gui_desktop for GUI evidence.
 r=struct('assistant',p.assistant,'prompt_id',p.prompt_id,'rep',p.rep, ...
  'version',p.version,'file',p.file,'executed',0,'error_message',"", ...
  'error_id',"",'error_line',NaN,'best_ref',"",'eps',NaN,'eps_rev',NaN, ...
  'classification',"not_executed",'dir_check',NaN,'self_check',NaN, ...
  'init_ok',NaN,'start_ok',NaN,'update_ok',NaN,'stop_ok',NaN,'reset_ok',NaN, ...
  'matlab_version',string(version),'run_datetime',string(datetime('now','TimeZone','local')), ...
  'review_required',1);
 before=findall(groot,'Type','figure');
 try
  [printed,candidates]=execute_isolated(char(file));
  r.executed=1; r.classification="no_match";
  fprintf('\n%s %s r%d\n%s\n',p.assistant,p.prompt_id,p.rep,printed);
  [refs,labels]=references(p.prompt_id);
  candidateRows=struct([]); good=false;reverse=false; best=Inf;
  for c=1:size(candidates,1)
   v=candidates(c,:);
   for j=1:size(refs,1)
    e=norm(v-refs(j,:))/norm(refs(j,:)); er=norm(v+refs(j,:))/norm(refs(j,:));
    cr=struct('candidate',c,'x',v(1),'y',v(2),'z',v(3),'reference',labels(j),'eps',e,'eps_rev',er);
    candidateRows=[candidateRows;cr]; %#ok<AGROW>
    good=good||e<=0.005;reverse=reverse||er<=0.005;
    if min(e,er)<best
     best=min(e,er);r.best_ref=labels(j);r.eps=e;r.eps_rev=er;
     r.dir_check=sign(dot(v,refs(j,:)));
     if e<=0.005,r.classification="correct_"+labels(j);
     elseif er<=0.005,r.classification="reversed_"+labels(j);end
    end
   end
  end
  if good&&reverse,r.classification="inconsistent";end
  if ~isempty(candidateRows)
   writetable(struct2table(candidateRows),fullfile(root,'results',p.assistant+"_"+replace(p.prompt_id,".","")+"_r"+p.rep+"_candidates.csv"));
  end
 catch err
  r.error_id=string(err.identifier);r.error_message=string(getReport(err,'extended','hyperlinks','off'));
  if ~isempty(err.stack),r.error_line=err.stack(1).line;end
  fprintf('%s\n',r.error_message);
 end
 after=findall(groot,'Type','figure');delete(setdiff(after,before));
 out=[out;r]; %#ok<AGROW>
end
if isempty(out)
 fprintf('No observed field files. No checks.csv or rates created.\n');
else
 writetable(struct2table(out),fullfile(root,'results','checks.csv'));
end
end

function [printed,candidates]=execute_isolated(file)
% Workspace vectors and printed triplets are suggestions, not semantic proof.
old=pwd; folder=fileparts(file); cd(folder); addpath(folder);
guard=fullfile(fileparts(mfilename('fullpath')),'input_guard');addpath(guard,'-begin');
guardCleanup=onCleanup(@() rmpath(guard));
cleanup=onCleanup(@() restore(old,folder));
src=fileread(file);
% A local function at the end does not make a script a function file.
codeLines=splitlines(string(src));
active=codeLines(strlength(strtrim(codeLines))>0 & ~startsWith(strtrim(codeLines),"%"));
first={};
if ~isempty(active)&&startsWith(strtrim(active(1)),"function")
 first=regexp(char(active(1)),'^\s*function\s+(?:\[[^\]]*\]|\w+)\s*=\s*(\w+)|^\s*function\s+(\w+)','tokens','once');
end
declared='';
if ~isempty(first)
 declared=first{find(~cellfun(@isempty,first),1)};
 [~,name]=fileparts(file);
 if ~strcmp(name,declared),error('Paper:Filename','Place this function in an isolated folder as %s.m and update planned_runs.csv; preserve the raw filename.',declared);end
end
[printed,candidates]=execute_payload(file,declared);
end
function [printed,candidates]=execute_payload(file,declared)
% Generated clear commands cannot delete the caller's cleanup guards.
if isempty(declared),printed=evalc('run(file)');
else,printed=evalc('feval(declared)');end
candidates=zeros(0,3); vars=whos;
for n=1:numel(vars)
 if any(strcmp(vars(n).name,{'candidates','printed'})),continue;end
 value=eval(vars(n).name);
 if isnumeric(value)&&isreal(value)&&numel(value)==3&&isvector(value)&&all(isfinite(value))
  candidates(end+1,:)=double(value(:)'); %#ok<AGROW>
 end
end
lines=splitlines(string(printed)); number='[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?';
for n=1:numel(lines)
 tokens=regexp(char(lines(n)),number,'match');
 if numel(tokens)==3,candidates(end+1,:)=str2double(tokens);end %#ok<AGROW>
end
candidates=unique(candidates,'rows');
end
function restore(old,folder)
cd(old);rmpath(folder);
end
function [refs,labels]=references(pid)
if startsWith(pid,"Q1")
 k=8.9875517923e9;P=[0 1 2];a=[-1 0 0];b=[1 0 0];
 refs=k*2e-9*((P-a)/norm(P-a)^3-(P-b)/norm(P-b)^3);labels="q1";
else
 A=[.25 .5 0];P=[1 1 0];d=P-A;rho=norm(d(1:2));aphi=[-d(2) d(1) 0]/rho;
 g=@(z)(z-P(3))/sqrt(rho^2+(z-P(3))^2);
 refs=[1e-7/rho*(g(1)-g(-1))*aphi;1e-7/rho*(g(2)-g(0))*aphi];labels=["mid";"end"];
 if pid=="S2",refs=refs(1,:);labels=labels(1);end
end
end
