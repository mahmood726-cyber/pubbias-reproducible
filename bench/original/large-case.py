import json,os,subprocess,concurrent.futures
from pathlib import Path
src=Path('scripts/reference.R').read_text();header=src.split('items<-unique')[0];capture=src[src.index('capture<-function'):src.index('for(id in names(corpus))')]
body=src[src.index(' d<-corpus[[id]];'):src.index(' ref[[id]]<-r;')].splitlines()
methods=['egger_lm','egger_rma','begg','trimfill','selection']
def job(method):
 if method.startswith('egger'):
  line=next(s for s in body if s.strip().startswith('for(model'));line=line.replace("c('lm','rma')",repr(method.split('_')[1]))
 else:line=next(s for s in body if s.strip().startswith('r$'+method+'<-'))
 script=f'bounded/large-{method}.R';out=f'bounded/large-{method}.json'
 Path(script).write_text(header+capture+"\nsource('bounded/input-124.R');id<-names(corpus)[1]\n"+body[0]+'\n'+line+f"\nwritej(r,'{out}')\n",encoding='utf-8')
 env=os.environ.copy();env['R_LIBS_USER']='<R_LIBS_USER>'
 with open(f'bounded/large-{method}.log','wb') as log:
  p=subprocess.Popen(['Rscript',script],env=env,stdout=log,stderr=subprocess.STDOUT)
  try:p.wait(timeout=120)
  except subprocess.TimeoutExpired:p.kill();p.wait()
 if Path(out).exists():value=json.loads(Path(out).read_text())[method]
 else:value={'value':{'unavailable':True,'error':'Independent method attempt exceeded 120 seconds or failed; see bounded/large-'+method+'.log'},'warnings':[]}
 return method,value
values={}
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
 for method,value in pool.map(job,methods):values[method]=value;print('LARGE CASE',method,'UNAVAILABLE' if value['value'].get('unavailable') else 'COMPLETE',flush=True)
Path('large-case-reference.json').write_text(json.dumps(values,indent=2),encoding='utf-8')
print('LARGE CASE COMPLETE:',sum(not x['value'].get('unavailable',False) for x in values.values()),'/ 5 method references available',flush=True)
