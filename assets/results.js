const names={chatgpt:'ChatGPT',gemini:'Gemini',claude:'Claude',deepseek:'DeepSeek'};
const labels={reference_agreement:'Reference agreement',selfcheck_stop:'Self-check stopped',execution_failure:'Execution failure',initialized:'GUI initialized',initialization_failure:'Initialization failure',no_code:'No code returned'};
const geometry={q1:'Two point charges',mid:'Centered segment',end:'Endpoint segment'};
let study;
const dialog=document.querySelector('#run-dialog');
const text=(tag,value)=>{const e=document.createElement(tag);e.textContent=value;return e};
const localLink=(path,label)=>{const a=text('a',label);a.href='supplement/'+path.split('/').map(encodeURIComponent).join('/');a.target='_blank';a.rel='noopener';return a};
function render(){
 const filtered=study.runs.map((r,id)=>({...r,id})).filter(r=>['assistant','prompt','stage','status'].every(k=>{const v=document.querySelector('#filter-'+k).value;return v==='all'||v===r[k]}));
 const initial=filtered.filter(r=>r.stage==='initial').length;
 document.querySelector('#run-count').textContent=`${filtered.length} records shown · ${initial} initial responses · ${filtered.length-initial} separate repairs`;
 const body=document.querySelector('#run-rows');body.replaceChildren();
 for(const r of filtered){const tr=document.createElement('tr');tr.append(text('th',`${names[r.assistant]} · r${r.rep}`),text('td',r.prompt),text('td',r.stage==='initial'?'Initial':'Repair'));
 const cell=document.createElement('td');const badge=text('span',labels[r.status]);badge.className='status '+(r.status==='reference_agreement'?'ok':['execution_failure','initialization_failure'].includes(r.status)?'fail':'warn');cell.append(badge);tr.append(cell,text('td',r.error!==''&&Number.isFinite(Number(r.error))?(Number(r.error)*100).toPrecision(4)+'%':'—'));
 const td=document.createElement('td'),button=text('button','Inspect');button.type='button';button.className='inspect';button.addEventListener('click',()=>inspect(r));td.append(button);tr.append(td);body.append(tr)}
}
function metaLine(container,label,value){const p=text('p','');p.append(text('strong',label+': '),document.createTextNode(value));container.append(p)}
async function inspect(r){
 document.querySelector('#detail-title').textContent=`${names[r.assistant]} · ${r.prompt} · r${r.rep} · ${r.stage==='initial'?'initial response':'separate repair'}`;
 const meta=document.querySelector('#detail-meta');meta.replaceChildren();
 metaLine(meta,'Outcome',labels[r.status]);
 if(r.geometry)metaLine(meta,'Implemented geometry',geometry[r.geometry]||r.geometry);
 if(r.vectors.length)metaLine(meta,'Labeled field vectors',r.vectors.map(v=>'['+v.join(', ')+']').join('; ')+(r.prompt.startsWith('Q1')?' V/m (equivalent to N/C)':' T'));
 if(r.error!==''&&Number.isFinite(Number(r.error)))metaLine(meta,'Maximum external relative error',(Number(r.error)*100).toPrecision(5)+'%');
 if(r.callbacks)metaLine(meta,'Reported callback labels',Object.entries(r.callbacks).map(([k,v])=>k+' = '+(v==='1'?'1':v==='0'?'0':'missing')).join(' · '));
 document.querySelector('#detail-evidence').textContent=r.evidence||'No additional observation recorded.';
 const links=document.querySelector('#detail-links');links.replaceChildren();if(r.file)links.append(localLink(r.file,r.status==='no_code'?'Response capture':'Evaluation source'));
 if(r.diary){links.append(document.createTextNode(' · '),localLink(r.diary,'Desktop diary'))}
 const pictures=document.querySelector('#detail-screens');pictures.replaceChildren();
 for(const path of r.screens){const figure=document.createElement('figure'),img=document.createElement('img');img.src='supplement/'+path;img.alt=`Archived ${r.prompt} r${r.rep} ${r.stage} screenshot`;img.loading='lazy';figure.append(img,text('figcaption',path.split('/').pop()+' · Single frame; not evidence of animation.'));pictures.append(figure)}
 document.querySelector('#detail-code').textContent='';document.querySelector('#code-status').textContent='Loading archived file…';dialog.showModal();
 try{let source=window.PAPER_RUN_SOURCES?.[r.file];if(source===undefined){const response=await fetch('supplement/'+r.file.split('/').map(encodeURIComponent).join('/'));if(!response.ok)throw Error('File unavailable');source=await response.text();}document.querySelector('#detail-code').textContent=source;document.querySelector('#code-status').textContent='Read-only archive. MATLAB code is displayed, not executed.'}
 catch(err){document.querySelector('#code-status').textContent='Unable to display the file. Use its download link above.'}
}
document.querySelector('#close-dialog').addEventListener('click',()=>dialog.close());
(window.PAPER_STUDY_DATA ? Promise.resolve(window.PAPER_STUDY_DATA) : fetch('assets/results.json').then(r=>{if(!r.ok)throw Error('Dataset unavailable');return r.json()})).then(data=>{
 study=data;for(const key of ['assistant','prompt','stage','status'])document.querySelector('#filter-'+key).addEventListener('change',render);
 const rows=document.querySelector('#coverage-rows');
 for(const r of study.coverage){const tr=document.createElement('tr');tr.append(text('th',`${names[r.assistant]} · r${r.rep}`));for(const k of ['C1_equations','C2_functions','C3_position_solver','C4_comments'])tr.append(text('td',r[k]==='1'?'Present':r[k]==='0'?'Absent':'Not assessed'));rows.append(tr)}
 render();
}).catch(()=>{document.querySelector('#run-count').textContent='Interactive data unavailable. The downloadable CSVs retain all observations.'});
