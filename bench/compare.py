import json,sys,math
from pathlib import Path
app=json.loads(Path(sys.argv[1] if len(sys.argv)>1 else 'app.json').read_text())
ref=json.loads(Path('reference.json').read_text())['datasets']
summary={}; failures=[]; refusals=[]
mapping={'egger_lm':('egger',['statistic','p','b0','limit']),'begg':('begg',['tau','p']),'trimfill':('trimfill',['k0','side','est','se','tau2']),'selection':('selection',['mu','se','tau2','delta','LRT','LRTp']),'peters':('peters',['statistic','p']),'harbord':('harbord',['statistic','p'])}
for id,r in ref.items():
 for method,(am,fields) in mapping.items():
  if method not in r:continue
  rv=r[method]['value']; av=app.get(id,{}).get(am,{'error':app.get(id,{}).get('error','missing')})
  if av is None:av={'error':'null result'}
  if method in ('peters','harbord') and 'error' not in rv and rv.get('statistic') is None and rv.get('p') is None:
   rv={'error':'meta::metabias returned no statistic or p-value (insufficient informative rows)','raw':rv}
  if 'error' in rv or 'error' in av:
   ok='error' in rv and 'error' in av and not rv.get('unavailable') and not av.get('unavailable')
   key=method+'.refusal';s=summary.setdefault(key,dict(checks=0,passing=0,max_difference=0,tolerance=0));s['checks']+=1;s['passing']+=ok
   refusals.append(dict(dataset=id,method=method,reference=rv,app=av,pass_check=ok))
   if not ok:failures.append(refusals[-1])
   continue
  for f in fields:
   xx=rv.get(f); yy=av.get(f)
   if f=='delta':xx=xx[1] if isinstance(xx,list) else xx;yy=yy[1] if isinstance(yy,list) else yy
   tol=1e-6 if method in ('trimfill','selection') and f not in ('k0','side') else 1e-9
   # Variances retain 1e-6; no blanket flat-likelihood tolerance relaxation.
   diff=(0 if xx==yy else 1) if f=='side' else (abs(xx-yy)/(1 if f in ('p','LRTp') else max(1,abs(xx))) if isinstance(xx,(int,float)) and isinstance(yy,(int,float)) and math.isfinite(xx) and math.isfinite(yy) else None)
   ok=diff is not None and diff<=tol
   key=method+'.'+f;s=summary.setdefault(key,dict(checks=0,passing=0,max_difference=0,tolerance=tol));s['checks']+=1;s['passing']+=ok
   if diff is not None:s['max_difference']=max(s['max_difference'],diff)
   if not ok:failures.append(dict(dataset=id,method=method,quantity=f,reference=xx,app=yy,difference=diff))
out=dict(app_file=sys.argv[1] if len(sys.argv)>1 else 'app.json',reference_configurations=len(ref),app_configurations=len(app),quantities=summary,failures=failures,refusals=refusals,checks=sum(s['checks'] for s in summary.values()),passing=sum(s['passing'] for s in summary.values()))
for k,s in summary.items():print(f"{k}: {s['passing']}/{s['checks']} pass; max difference={s['max_difference']:.17g}; tolerance={s['tolerance']}")
print(f"{out['passing']}/{out['checks']} checks pass")
Path(sys.argv[2] if len(sys.argv)>2 else 'comparison-original.json').write_text(json.dumps(out,indent=2),encoding='utf-8')
