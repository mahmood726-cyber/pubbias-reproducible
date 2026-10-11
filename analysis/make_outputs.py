"""Rebuild publication outputs from archived results only; no R/browser/network needed."""
import argparse
import csv
import json
import math
from collections import defaultdict
from pathlib import Path
from statistics import NormalDist
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
METHODS = {'egger_lm': ('egger', ['statistic','p','b0','limit']), 'begg': ('begg',['tau','p']),
           'trimfill': ('trimfill',['k0','side','est','se','tau2']),
           'peters': ('peters',['statistic','p']), 'harbord': ('harbord',['statistic','p']),
           'selection': ('selection',['mu','se','tau2','delta','LRT','LRTp'])}
LABELS = {'egger_lm':'Egger','begg':'Begg','trimfill':'Trim-and-fill','peters':'Peters','harbord':'Harbord'}

def read(p):
    return json.loads(p.read_text(encoding='utf-8'))

def dump(p, x):
    p.write_text(json.dumps(x, indent=2, ensure_ascii=False, allow_nan=False)+'\n', encoding='utf-8')

def compare(app, ref):
    rows=[]
    for dataset, r in ref.items():
        for method,(am,fields) in METHODS.items():
            if method not in r: continue
            rv=r[method]['value']; av=app.get(dataset,{}).get(am, {'error':app.get(dataset,{}).get('error','missing')})
            if av is None: av={'error':'null result'}
            if method in ('peters','harbord') and 'error' not in rv and rv.get('statistic') is None and rv.get('p') is None:
                rv={'error':'meta::metabias returned no statistic or p-value (insufficient informative rows)','raw':rv}
            base={'dataset':dataset,'method':method}
            if 'error' in rv or 'error' in av:
                ok='error' in rv and 'error' in av and not rv.get('unavailable') and not av.get('unavailable')
                rows.append(dict(base, quantity='refusal',app=av,reference=rv,difference=None,tolerance=0,passed=bool(ok)))
                continue
            for q in fields:
                a=av.get(q); b=rv.get(q)
                if q=='delta': a=a[1] if isinstance(a,list) else a; b=b[1] if isinstance(b,list) else b
                tol=1e-6 if method in ('trimfill','selection') and q not in ('k0','side') else 1e-9
                diff=(0 if a==b else 1) if q=='side' else (abs(a-b)/(1 if q in ('p','LRTp') else max(1,abs(b))) if isinstance(a,(int,float)) and isinstance(b,(int,float)) and math.isfinite(a) and math.isfinite(b) else None)
                rows.append(dict(base,quantity=q,app=a,reference=b,difference=diff,tolerance=tol,passed=diff is not None and diff<=tol))
    return rows

def summarize(rows):
    grouped=defaultdict(list)
    for r in rows: grouped[r['method']+'.'+r['quantity']].append(r)
    return {k:dict(checks=len(v),passing=sum(r['passed'] for r in v),max_difference=max([r['difference'] for r in v if r['difference'] is not None] or [0]),tolerance=v[0]['tolerance']) for k,v in grouped.items()}

def csvwrite(p, fields, rows):
    with p.open('w',encoding='utf-8',newline='') as f:
        w=csv.DictWriter(f,fieldnames=fields); w.writeheader();w.writerows(rows)

def figures(out, rows, numbers):
    plt.rcParams.update({'font.family':'DejaVu Sans','font.size':8,'axes.titlesize':9,'axes.labelsize':8,'xtick.labelsize':8,'ytick.labelsize':8,'legend.fontsize':8})
    fig,axs=plt.subplots(3,2,figsize=(170/25.4,9.8))
    for ax,(m,label) in zip(axs.flat,LABELS.items()):
        qs=METHODS[m][1]; selected=[r for r in rows if r['method']==m and r['quantity']!='refusal']
        for j,q in enumerate(qs):
            rr=[r for r in selected if r['quantity']==q]
            # One value per configuration/quantity (each quantity is scalar here).
            rr.sort(key=lambda r:r['dataset'])
            for passed in [True,False]:
                points=[(j+(i/max(len(rr)-1,1)-.5)*.48, math.log10(max(r['difference'],1e-16)) if r['difference'] is not None else -2) for i,r in enumerate(rr) if r['passed']==passed]
                if points: ax.scatter(*zip(*points),s=6 if passed else 28,c='#24658a' if passed else '#b22d30',marker='o' if passed else 'x',alpha=.5 if passed else 1)
            if rr: ax.plot([j-.38,j+.38],[math.log10(rr[0]['tolerance'])]*2,'--',color='#555',lw=1)
        refusals=[r for r in rows if r['method']==m and r['quantity']=='refusal']
        ax.set_title(f'{label} | numeric {sum(r["passed"] for r in selected)}/{len(selected)}')
        ax.set_xticks(range(len(qs)),qs);ax.set_ylim(-16.8,-2);ax.set_yticks([-16,-12,-9,-6,-3]);ax.grid(axis='y',alpha=.2)
        ax.set_ylabel('log10 difference');ax.text(.02,.95,f'Refusals: {sum(r["passed"] for r in refusals)}/{len(refusals)} match',transform=ax.transAxes,va='top',fontsize=8)
    axs.flat[-1].axis('off')
    axs.flat[-1].text(0,1,'App versus R\n\nBlue: passing numeric check\nRed ×: failed numeric check\nDashed: quantity tolerance\nZero / <1e−16 drawn at −16\n\nEach dot: configuration × quantity\nRefusals have no numeric distance.\nFour failed refusals: see Table 2.\n\nSelection omitted:\nexperimental, not validated.',va='top',fontsize=8,linespacing=1.65)
    fig.suptitle('Agreement of five publication-bias methods',fontsize=11)
    fig.tight_layout(rect=(0,0,.995,.97)); savefig(fig,out,'figure2_agreement');plt.close(fig)
    fig=plt.figure(figsize=(170/25.4,3.65))
    boxes=[('Problem','Small-study effects\nand publication bias\nare commonly\nexamined in R.'),('Tool','allmeta runs\nfive standard\nmethods offline\nin the browser.'),('Validation',f'{numbers["datasets_used"]["value"]} datasets\n{numbers["configurations"]["value"]} configurations\nAgainst R packages\nmetafor and meta.'),('Result',f'{numbers["passed"]["value"]:,} of {numbers["checks"]["value"]:,}\nchecks pass\n({numbers["validated_methods"]["value"]} validated methods);\n{numbers["failures"]["value"]} exceptions explained')]
    for i,(heading,body) in enumerate(boxes):
        x=.02+i*.245
        fig.patches.append(FancyBboxPatch((x,.25),.22,.52,boxstyle='round,pad=0.008',transform=fig.transFigure,facecolor=['#f4ece8','#e8f0f7','#eaf4ec','#fdf6e3'][i],edgecolor='#999'))
        fig.text(x+.11,.70,heading,ha='center',weight='bold',fontsize=10)
        fig.text(x+.11,.49,body,ha='center',va='center',fontsize=8,linespacing=1.6)
    fig.text(.5,.89,'Small-study effects and publication bias in the browser',ha='center',fontsize=11,weight='bold')
    fig.text(.5,.13,'Selection: experimental, not validated. Thompson–Sharp: not compared.',ha='center',fontsize=8)
    fig.text(.5,.07,f'{numbers["below_page_minimum"]["value"]} configurations below the page minimum were tested through the engine.',ha='center',fontsize=8)
    savefig(fig,out,'visual_abstract');plt.close(fig)

def savefig(fig,out,name):
    for ext in ('png','tif'): fig.savefig(out/f'{name}.{ext}',dpi=300)

def main():
    p=argparse.ArgumentParser();p.add_argument('--results',type=Path,default=ROOT/'results');p.add_argument('--outputs',type=Path,default=ROOT/'outputs');p.add_argument('--expected',type=Path,default=ROOT/'expected/paper_values.json');a=p.parse_args()
    out=a.outputs;out.mkdir(parents=True,exist_ok=True)
    ref=read(a.results/'reference.json');app=read(a.results/'app-merged-3dcc679.json');oldapp=read(a.results/'app-original2.json')
    rows=compare(app,ref['datasets']);oldrows=compare(oldapp,ref['datasets']);summary=summarize(rows);oldsummary=summarize(oldrows)
    archived=read(a.results/'comparison-merged-3dcc679.json');oldledger=read(a.results/'comparison-original2.json')
    assert summary==archived['quantities'], 'Recomputed comparison differs from archived final ledger'
    assert oldsummary==oldledger['quantities'], 'Recomputed comparison differs from original ledger'
    core=[r for r in rows if r['method']!='selection'];failed=[r for r in core if not r['passed']]
    csvwrite(out/'table1_by_method.csv',['method','quantity','checks','passed','largest_difference','tolerance','all_within'],[
        dict(method=LABELS[k.split('.')[0]],quantity=k.split('.')[1],checks=v['checks'],passed=v['passing'],largest_difference='' if k.endswith('.refusal') else v['max_difference'],tolerance='exact refusal match; timeout fails' if k.endswith('.refusal') else ('exact side equality' if k.endswith('.side') else v['tolerance']),all_within=v['checks']==v['passing']) for k,v in summary.items() if not k.startswith('selection.')]+
        [dict(method='TOTAL',quantity='Selection excluded',checks=len(core),passed=sum(r['passed'] for r in core),largest_difference='',tolerance='quantity-specific',all_within=all(r['passed'] for r in core))])
    failure_rows=[]
    for r in failed:
        reason='Variance → SE → variance round trip changes exact tie groups; matched-input R diagnostic agrees.' if r['method']=='begg' else ('R reference unavailable after bounded method attempt; timeout never counts as a matched refusal.' if r['reference'].get('unavailable') else 'R parent REML model failed to converge; direct app test returned a numeric result.')
        failure_rows.append(dict(dataset_configuration=r['dataset'],method=LABELS[r['method']],quantity=r['quantity'],app_value=json.dumps(r['app']),R_value_or_error=json.dumps(r['reference']),reason=reason))
    csvwrite(out/'table2_failed_checks.csv',list(failure_rows[0]),failure_rows)
    dump(out/'check_ledger.json',rows)
    n={}
    def add(key,value,source,transform='identity'): n[key]={'value':value,'source':source,'transformation':transform}
    corpus=read(a.results/'corpus.json');disposition=read(a.results/'dataset-disposition.json')
    assert {d['id'] for d in corpus}==set(ref['datasets'])==set(app)
    add('datasets_enumerated',len(disposition),'dataset-disposition.json','count keys')
    add('datasets_used',sum(d['used'] for d in disposition.values()),'dataset-disposition.json:*.used','sum true')
    add('datasets_excluded',sum(not d['used'] for d in disposition.values()),'dataset-disposition.json:*.used','sum false')
    add('configurations',len(corpus),'corpus.json','count configurations')
    add('binary_configurations',sum(bool(d['binary']) for d in corpus),'corpus.json:*.binary','count nonempty')
    add('below_page_minimum',sum(d['k']<5 for d in corpus),'corpus.json:*.k','count k < 5')
    for k,v in [('checks',len(core)),('passed',sum(r['passed'] for r in core)),('failures',len(failed)),('numeric_failures',sum(r['quantity']!='refusal' for r in failed)),('failed_refusals',sum(r['quantity']=='refusal' for r in failed)),('unmatched_R_refusals',sum(r['quantity']=='refusal' and not r['reference'].get('unavailable') for r in failed)),('unavailable_references',sum(r['quantity']=='refusal' and bool(r['reference'].get('unavailable')) for r in failed)),('validated_methods',len(LABELS))]:add(k,v,'reference.json + app-merged-3dcc679.json','recomputed non-selection comparison')
    for m in LABELS:
        group=defaultdict(list)
        for r in core:
            if r['method']==m and r['quantity']!='refusal':group[r['dataset']].append(r)
        add(m+'_configurations',len(group),'reference.json + app-merged-3dcc679.json:'+m,'count numerically comparable configurations')
        add(m+'_passed',sum(all(r['passed'] for r in rr) for rr in group.values()),'reference.json + app-merged-3dcc679.json:'+m,'count configurations passing every quantity')
        add(m+'_max',max(r['difference'] for rr in group.values() for r in rr),'reference.json + app-merged-3dcc679.json:'+m,'maximum comparison difference')
    for name,ss in [('before',oldsummary),('after',summary)]:
        for key,field in [('passed','passing'),('checks','checks')]: add('selection_mu_'+name+'_'+key,ss['selection.mu'][field],('app-original2.json' if name=='before' else 'app-merged-3dcc679.json')+' + reference.json:selection.mu','recomputed comparison; experimental only')
    add('trimfill_prefix_max',max(v['max_difference'] for k,v in oldsummary.items() if k.startswith('trimfill.') and not k.endswith('refusal')),'app-original2.json + reference.json:trimfill','maximum comparison difference')
    h=ref['datasets']['dat.hackshaw1998']; tf=h['trimfill']['value']
    add('hackshaw_k',next(d['k'] for d in corpus if d['id']=='dat.hackshaw1998'),'corpus.json:dat.hackshaw1998.k')
    for m,qs in [('egger_lm',['statistic','p']),('begg',['tau','p']),('trimfill',['k0','side'])]:
        for q in qs:add('hackshaw_'+m+'_'+q,h[m]['value'][q],'reference.json:datasets.dat.hackshaw1998.'+m+'.value.'+q)
    z=NormalDist().inv_cdf(.975)
    for k,v in [('OR',tf['est']),('lower',tf['est']-z*tf['se']),('upper',tf['est']+z*tf['se'])]:add('hackshaw_adjusted_'+k,math.exp(v),'reference.json:datasets.dat.hackshaw1998.trimfill.value','exp(est), or exp(est ± qnorm(.975)*se)')
    hr=[r for r in core if r['dataset']=='dat.hackshaw1998' and r['quantity']!='refusal']
    add('hackshaw_max',max(r['difference'] for r in hr),'reference.json + app-merged-3dcc679.json:dat.hackshaw1998','max over all compared validated quantities')
    hh=read(a.results/'hackshaw-reml.json')
    for q in ['OR','lower','upper']:add('hackshaw_unadjusted_'+q,hh[q],'hackshaw-reml.json:'+q,'separate R REML run; exponentiated estimate/CI')
    add('hackshaw_unadjusted_OR_display',round(hh['OR'],2),'hackshaw-reml.json:OR','round to two decimals for manuscript')
    diag=read(a.results/'targeted-diagnostics.json')['dat.mccurdy2020']['begg_roundtrip']
    add('begg_roundtrip_max',max(abs(diag[q]-app['dat.mccurdy2020']['begg'][q]) for q in ['tau','p']),'targeted-diagnostics.json:dat.mccurdy2020.begg_roundtrip + app-merged-3dcc679.json','maximum absolute discrepancy')
    for k,v in ref['versions'].items():add('version_'+k,v,'reference.json:versions.'+k)
    # Static protocol numbers are declared separately, never presented as measured results.
    protocol=read(a.results/'protocol.json')
    for k,v in protocol.items():add(k,v,'protocol.json:'+k,'static protocol or source metadata; see README disclosure')
    dump(out/'numbers.json',n)
    expected=read(a.expected);report=['# Reproduction report','','All calculations read results/ only; expected values are assertions, never inputs to findings.','', '| Claim | Expected | Reproduced | Verdict |','|---|---|---|---|'];passed=0
    for k,e in expected.items():
        value=n[k]['value'];actual=value
        if 'digits' in e: actual=round(value,e['digits'])
        if 'significant' in e: actual=float(format(value,f'.{e["significant"]}g'))
        ok=actual<=e['value'] if e.get('rule')=='at_most' else actual==e['value']
        passed+=ok;report.append(f'| {k} | {e["value"]} | {actual} | {"PASS" if ok else "FAIL"} |')
    figures(out,core,n)
    sizes={}
    for f in sorted(out.iterdir()):
        if f.suffix in ('.png','.tif'):
            with Image.open(f) as im:sizes[f.name]={'width_pixels':im.width,'height_pixels':im.height,'dpi':[float(v) for v in im.info['dpi']]}
    dump(out/'sizes.json',sizes)
    notes='''Selection is EXCLUDED from both tables and the agreement figure; experimental, not validated. Thompson–Sharp was not compared. Refusal differences are not numeric and are blank in Table 1. Figures use 300 dpi, 170 mm nominal width, and text of at least 8 pt. Exact zeros and sub-1e-16 differences are plotted at −16. One scalar difference exists per configuration and quantity, so it is also that quantity's largest difference. The four nonnumeric failures are in Table 2.\n\nThe archive verifies numerical paper claims, versions and protocol constants. List numbering, citation markers, reference bibliographic years/page numbers, and PR identifiers are not experimental findings. Source documentation of the run is retained for inspection; the manuscript is published separately. No network, full R corpus rerun, or full browser rerun is implied by this reproduction.\n'''
    (out/'notes.md').write_text(notes,encoding='utf-8')
    final=f'{"PASS" if passed==len(expected) else "FAIL"}: {passed}/{len(expected)} paper-value assertions; {sum(r["passed"] for r in core)}/{len(core)} non-selection checks pass; {len(failed)} exceptions.'
    report+=['',notes,'',final];(out/'reproduction_report.md').write_text('\n'.join(report)+'\n',encoding='utf-8')
    print(final)
    return 0 if passed==len(expected) else 1

if __name__=='__main__':raise SystemExit(main())
