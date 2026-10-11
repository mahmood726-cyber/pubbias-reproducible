import json
from pathlib import Path
p=Path('reference.json');d=json.loads(p.read_text());d['datasets']['dat.mccurdy2020']=json.loads(Path('large-case-reference.json').read_text());p.write_text(json.dumps(d,indent=2),encoding='utf-8')
print('FINAL REFERENCE:',len(d['datasets']),'configurations;',sum(v['value'].get('unavailable',False) for r in d['datasets'].values() for v in r.values()),'method references unavailable')
