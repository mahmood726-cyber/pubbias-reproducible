"""Portable orchestration of original reference-one.R on the frozen final corpus."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess

ROOT=Path(__file__).resolve().parents[1]

def rr(x):
    if x is None:return 'NULL'
    if isinstance(x,bool):return 'TRUE' if x else 'FALSE'
    if isinstance(x,str):return json.dumps(x)
    if isinstance(x,dict):return 'list('+','.join(rr(k)+'='+rr(v) for k,v in x.items())+')'
    if isinstance(x,list):return ('list(' if any(isinstance(v,(dict,list)) for v in x) else 'c(')+','.join(rr(v) for v in x)+')'
    return repr(x)

def invoke(script, output, env, log):
    with log.open('wb') as f:
        p=subprocess.Popen([env.get('RSCRIPT','Rscript'),str(script)],env=env,stdout=f,stderr=subprocess.STDOUT)
        try:p.wait(timeout=120)
        except subprocess.TimeoutExpired:p.kill();p.wait()
    return json.loads(output.read_text(encoding='utf-8')) if output.exists() else {}

def main():
    p=argparse.ArgumentParser();p.add_argument('--output',type=Path,default=ROOT/'rerun');a=p.parse_args();out=a.output.resolve()
    out.mkdir(parents=True,exist_ok=True)
    if (out/'reference.json').exists():raise SystemExit('Refusing to overwrite existing reference.json; use a fresh output directory.')
    if not shutil.which(os.environ.get('RSCRIPT','Rscript')):raise SystemExit('Rscript is not available')
    version_script=out/'versions.R'
    version_script.write_text('stopifnot(getRversion()=="4.6.0",packageVersion("metafor")=="5.2.1",packageVersion("meta")=="8.5.0",packageVersion("metadat")=="1.6.0")\ncat(R.version.string)',encoding='utf-8')
    run=subprocess.run([os.environ.get('RSCRIPT','Rscript'),str(version_script)],capture_output=True,text=True,check=True)
    reference={'versions':{'R':run.stdout.strip(),'metafor':'5.2.1','meta':'8.5.0','metadat':'1.6.0'},'datasets':{}}
    original=ROOT/'bench/original/reference-one.R';source=original.read_text(encoding='utf-8')
    for i,d in enumerate(json.loads((ROOT/'data/corpus.json').read_text(encoding='utf-8'))):
        inp=out/f'input-{i}.R';dest=out/f'result-{i}.json';val=dict(d);binary=val.pop('binary');expr=rr(val)
        if binary:expr=expr[:-1]+',binary=data.frame('+','.join(k+'='+rr([r[k] for r in binary]) for k in binary[0])+'))'
        inp.write_text('corpus<-list('+rr(d['id'])+'='+expr+')',encoding='utf-8')
        env=os.environ|{'ONE_INPUT':str(inp),'ONE_OUTPUT':str(dest)}
        values=invoke(original,dest,env,out/f'run-{i}.log')
        methods=['egger_lm','egger_rma','begg','trimfill','selection']+(['peters','harbord'] if binary else [])
        if d['id']=='dat.mccurdy2020':
            header=source.split("source(Sys.getenv('ONE_INPUT'))")[0]
            for m in methods:
                line=next(x for x in source.splitlines() if x.strip().startswith('for(model')) if m.startswith('egger') else next(x for x in source.splitlines() if x.strip().startswith('r$'+m+'<-'))
                if m.startswith('egger'):line=line.replace("c('lm','rma')",rr(m.split('_')[1]))
                script=out/f'large-{m}.R';target=out/f'large-{m}.json'
                script.write_text(header+"source(Sys.getenv('ONE_INPUT'));id<-names(corpus)[1];d<-corpus[[id]];y<-d$yi;v<-d$vi;r<-list()\n"+line+"\nwritej(r,Sys.getenv('ONE_OUTPUT'))",encoding='utf-8')
                result=invoke(script,target,env|{'ONE_OUTPUT':str(target)},out/f'large-{m}.log')
                values[m]=result.get(m,{'value':{'unavailable':True,'error':'Independent method attempt exceeded 120 seconds or failed; see method log'},'warnings':[]})
        for m in methods:
            values.setdefault(m,{'value':{'unavailable':True,'error':'120-second per-configuration R execution limit or worker failure; see run log'},'warnings':[]})
        reference['datasets'][d['id']]=values
        (out/'reference.json').write_text(json.dumps(reference,indent=2),encoding='utf-8')
        print('R',i+1,d['id'],flush=True)
    print('REFERENCE COMPLETE:',len(reference['datasets']),'configurations')

if __name__=='__main__':main()
