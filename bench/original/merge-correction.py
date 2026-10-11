import json
from pathlib import Path
def read(p):return json.loads(Path(p).read_text(encoding='utf-8'))
def write(p,d):Path(p).write_text(json.dumps(d,indent=2),encoding='utf-8')
prefix='dat.kearon1998/'
c=read('corpus.json');c=[d for d in c if not d['id'].startswith(prefix)]+read('correction-corpus.json');write('corpus.json',c)
r=read('reference.json');r['datasets']={k:v for k,v in r['datasets'].items() if not k.startswith(prefix)};r['datasets'].update(read('correction-reference.json')['datasets']);write('reference.json',r)
for p in ['dataset-disposition.json','source-documentation.json']:
 d=read(p);d.update(read('correction-'+p));write(p,d)
print('SOURCE REVIEW CORRECTION: Kearon uses false positives nn-tn as control events; corpus remains',len(c),'configurations')
