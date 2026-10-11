import json,os,subprocess,concurrent.futures
from pathlib import Path
def load(p):return json.loads(Path(p).read_text(encoding='utf-8'),strict=False)
def write(p,x):Path(p).write_text(json.dumps(x,indent=2,ensure_ascii=True),encoding='utf-8')
def rr(x):
 if x is None:return 'NULL'
 if isinstance(x,bool):return 'TRUE' if x else 'FALSE'
 if isinstance(x,str):return json.dumps(x)
 if isinstance(x,dict):return 'list('+','.join(rr(k)+'='+rr(v) for k,v in x.items())+')'
 if isinstance(x,list):return 'list('+','.join(rr(v) for v in x)+')' if any(isinstance(v,(dict,list)) for v in x) else 'c('+','.join(rr(v) for v in x)+')'
 return repr(x)
corpus=load('corpus.json');by={d['id']:d for d in corpus};by.update({d['id']:d for d in load('supplement-corpus.json')});corpus=list(by.values());write('corpus.json',corpus)
ref=load('reference.json');ref['datasets'].update(load('supplement-reference.json')['datasets'])
for name in ['dataset-disposition.json','source-documentation.json']:
 x=load(name);x.update(load('supplement-'+name));write(name,x)
src=Path('scripts/reference.R').read_text();header=src.split('items<-unique')[0];capture=src[src.index('capture<-function'):src.index('for(id in names(corpus))')]
body=src[src.index(' d<-corpus[[id]];'):src.index(' ref[[id]]<-r;')]
parts=[]
for line in body.splitlines():
 parts.append(line)
 if '<-capture(' in line or line.strip().startswith('for(model') or line.strip().startswith('r$selection') or line.strip().startswith('if(!is.null(d$binary))'):parts.append(" writej(r,Sys.getenv('ONE_OUTPUT'))")
body='\n'.join(parts)
Path('scripts/reference-one.R').write_text(header+capture+"\nsource(Sys.getenv('ONE_INPUT'));id<-names(corpus)[1]\n"+body+"\nwritej(r,Sys.getenv('ONE_OUTPUT'))\n",encoding='utf-8')
Path('bounded').mkdir(exist_ok=True)
env=os.environ.copy();env['R_LIBS_USER']='<R_LIBS_USER>'
def job(pair):
 i,d=pair;inp=f'bounded/input-{i}.R';out=f'bounded/result-{i}.json';log=f'bounded/run-{i}.log'
 # R writer needs a data frame for binary count columns.
 val=dict(d);b=val.pop('binary');expr=rr(val)
 if b:expr=expr[:-1]+',binary=data.frame('+','.join(k+'='+rr([r[k] for r in b]) for k in b[0])+'))'
 Path(inp).write_text('corpus<-list('+rr(d['id'])+'='+expr+')',encoding='utf-8');e=env|{'ONE_INPUT':inp,'ONE_OUTPUT':out}
 timed=False
 with open(log,'wb') as fh:
  p=subprocess.Popen(['Rscript','scripts/reference-one.R'],env=e,stdout=fh,stderr=subprocess.STDOUT)
  try:p.wait(timeout=120)
  except subprocess.TimeoutExpired:p.kill();p.wait();timed=True
 r=load(out) if Path(out).exists() else {}
 methods=['egger_lm','egger_rma','begg','trimfill','selection']+(['peters','harbord'] if b else [])
 for m in methods:
  if m not in r:r[m]={'value':{'unavailable':True,'error':'120-second per-configuration R execution limit' if timed else 'R worker failed; see '+log},'warnings':[]}
 return d['id'],r,timed
missing=[(i,d) for i,d in enumerate(corpus) if d['id'] not in ref['datasets']]
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
 for id,r,timed in pool.map(job,missing):
  ref['datasets'][id]=r;write('reference.json',ref);print('BOUNDED REFERENCE',id,'TIMEOUT' if timed else 'COMPLETE',flush=True)
write('reference.json',ref)
print('REFERENCE COVERAGE COMPLETE:',len(ref['datasets']),'configurations;',sum(v['value'].get('unavailable',False) for d in ref['datasets'].values() for v in d.values()),'method configurations unavailable',flush=True)
