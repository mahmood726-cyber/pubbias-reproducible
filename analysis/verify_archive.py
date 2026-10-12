"""Verify archive integrity, source labels, tables, image metadata and local assets."""
import csv
import hashlib
import json
from pathlib import Path
import re
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
def load(p):return json.loads((ROOT/p).read_text(encoding='utf-8'))
def main():
    manifest=load('SOURCE_SHA256.json')
    for name,want in manifest.items():assert hashlib.sha256((ROOT/name).read_bytes()).hexdigest()==want,name
    app=load('results/app-sha256.json')
    for name,want in app.items():assert hashlib.sha256((ROOT/'app'/name).read_bytes()).hexdigest()==want,name
    page=ROOT/'app/pubbias-tests/index.html'
    for name in re.findall(r'(?:src|href)="([^"]+)"',page.read_text(encoding='utf-8')):
        if name.startswith('../') and Path(name).suffix in ['.js','.css']:assert (page.parent/name).is_file(),name
    for n in ['corpus.json','dataset-disposition.json']:assert (ROOT/'data'/n).read_bytes()==(ROOT/'results'/n).read_bytes()
    refs=load('results/reference.json')['datasets'];corpus=load('data/corpus.json');disposition=load('data/dataset-disposition.json')
    contract=load('validation-contract.json')
    checks=[r for r in load('outputs/check_ledger.json') if r['method'] in ['egger_lm','begg','trimfill','peters','harbord']]
    assert contract['configurations']==[d['id'] for d in corpus]
    assert contract['checks']==[' | '.join([r['dataset'],r['method'],r['quantity']]) for r in checks]
    assert len(set(contract['checks']))==len(checks)==2113
    assert contract['exceptions']==[r for r in checks if not r['passed']]
    assert len({d['id'] for d in corpus})==len(corpus)
    for d in corpus:
        assert d['id'] in refs and d['id'].split('/')[0] in disposition
        assert len(d['yi'])==len(d['vi'])==len(d['row_indices'])==d['k']
    with (ROOT/'outputs/table1_by_method.csv').open(encoding='utf-8',newline='') as f:table=list(csv.DictReader(f))
    total=table.pop();assert int(total['checks'])==sum(int(r['checks']) for r in table)==2113
    assert int(total['passed'])==sum(int(r['passed']) for r in table)==2107
    with (ROOT/'outputs/table2_failed_checks.csv').open(encoding='utf-8',newline='') as f:failed=list(csv.DictReader(f))
    expected={('dat.mccurdy2020','Begg','tau'),('dat.mccurdy2020','Begg','p'),('dat.mccurdy2020','Trim-and-fill','refusal')}|{('dat.baker2009/OR:Placebo:Salmeterol',m,'refusal') for m in ['Egger','Peters','Harbord']}
    assert {(r['dataset_configuration'],r['method'],r['quantity']) for r in failed}==expected and len(failed)==6
    for name,info in load('outputs/sizes.json').items():
        with Image.open(ROOT/'outputs'/name) as im:
            assert (im.width,im.height)==(info['width_pixels'],info['height_pixels'])
            assert abs(im.width/300*25.4-170)<.1
            assert all(abs(float(d)-300)<.001 for d in im.info['dpi'])
    for stem in ['figure2_agreement','visual_abstract']:
        with Image.open(ROOT/'outputs'/f'{stem}.png') as a,Image.open(ROOT/'outputs'/f'{stem}.tif') as b:assert a.convert('RGB').tobytes()==b.convert('RGB').tobytes()
    title='Small-study effects and publication bias tests in the browser: a tool validated against the R packages metafor and meta'
    z=load('.zenodo.json');assert z['title']==title and z['creators']==[{'name':'Ahmad, Mahmood'}]
    assert title in (ROOT/'CITATION.cff').read_text(encoding='utf-8')
    h=load('results/hackshaw-reml.json');assert h['dataset']=='dat.hackshaw1998' and h['k']==37 and h['metafor']=='5.2.1'
    assert all(c['pass'] for c in load('outputs/ui-smoke.json'))
    print(f'ARCHIVE PASS: {len(app)} app hashes; {len(manifest)} source hashes; corpus, six failure identities, tables, metadata, paired image pixels and offline UI checks verified.')
if __name__=='__main__':main()
