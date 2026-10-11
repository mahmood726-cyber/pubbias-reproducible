from pathlib import Path
src=Path('scripts/reference.R').read_text(encoding='utf-8');head=src.split('items<-unique')[0]
s=head+'''
source('corpus.R')
ids<-c('dat.cannon2006/OR:ep5t:ep5c','dat.chiarito2020/OR:p2y12.stroke:aspirin.stroke','dat.greenland1992/b')
out<-list()
for(d in corpus){
 if(d$id=='dat.mccurdy2020') {q<-ranktest(d$yi,vi=sqrt(d$vi)^2);out[[d$id]]<-list(begg_roundtrip=list(tau=q$tau,p=q$pval))}
 if(!(d$id %in% ids))next
 z<-trimfill(rma(d$yi,d$vi,method='REML',control=list(threshold=1e-10,maxiter=1000)),estimator='L0')
 f<-rma(z$yi,z$vi,method='REML',control=list(threshold=1e-10,maxiter=1000))
 out[[d$id]]<-list(trimfill_final_tight=list(k0=z$k0,side=z$side,est=as.numeric(f$b),se=f$se,tau2=f$tau2))
}
writej(out,'targeted-diagnostics.json')
cat('TARGETED DIAGNOSTICS COMPLETE:',length(out),'configurations\\n')
'''
Path('scripts/targeted-diagnostics.R').write_text(s,encoding='utf-8')
