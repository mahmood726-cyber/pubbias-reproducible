import json
from pathlib import Path
def read(n):return json.loads(Path(n).read_text(encoding='utf-8'),strict=False)
def write(n,x):Path(n).write_text(json.dumps(x,indent=2,ensure_ascii=True),encoding='utf-8')
base=read('corpus.json');extra=read('supplement-corpus.json');byid={d['id']:d for d in base};byid.update({d['id']:d for d in extra});write('corpus.json',list(byid.values()))
a=read('reference.json');b=read('supplement-reference.json');a['datasets'].update(b['datasets']);assert set(a['datasets'])==set(byid);write('reference.json',a)
for n in ['dataset-disposition.json','source-documentation.json']:
 a=read(n);a.update(read('supplement-'+n));write(n,a)
print('MERGE COMPLETE:',len(byid),'configurations')
