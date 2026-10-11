.libPaths(c(Sys.getenv('R_LIBS_USER'),.libPaths()))
library(metafor)
library(meta)
options(warn=1)
js <- function(x) {
 if(is.null(x)) return('null')
 if(is.data.frame(x)) return(js(lapply(seq_len(nrow(x)),function(i)as.list(x[i,,drop=FALSE]))))
 if(is.list(x)) {v<-vapply(x,js,''); if(!is.null(names(x)))return(paste0('{',paste(paste0(vapply(names(x),js,''),':',v),collapse=','),'}'));return(paste0('[',paste(v,collapse=','),']'))}
 if(length(x)!=1)return(paste0('[',paste(vapply(as.list(x),js,''),collapse=','),']'))
 if(is.na(x))return('null')
 if(is.character(x))return(paste0('"',gsub('\n','\\n',gsub('"','\\"',gsub('\\','\\\\',x,fixed=TRUE),fixed=TRUE),fixed=TRUE),'"'))
 if(is.logical(x))return(if(x)'true' else 'false')
 if(!is.finite(x))return('null');sprintf('%.17g',x)
}
writej<-function(x,p)writeLines(js(x),p,useBytes=TRUE)
items<-unique(data(package='metadat')$results[,'Item'])
corpus<-list(); inventory<-list(); docs<-list()
add<-function(id,d,y,v,source,binary=NULL) {
 ok<-is.finite(y)&is.finite(v)&v>0
 if(sum(ok)<3)return(FALSE)
 corpus[[id]]<<-list(id=id,source=source,k=sum(ok),removed=sum(!ok),row_indices=which(ok),yi=unname(y[ok]),vi=unname(v[ok]),binary=if(is.null(binary))NULL else binary[ok,,drop=FALSE]);TRUE
}
bin<-function(id,d,a,b,c,e,source) {
 good<-complete.cases(a,b,c,e)&a>=0&b>=0&c>=0&e>=0&(a+b)>0&(c+e)>0
 a[!good]<-b[!good]<-c[!good]<-e[!good]<-NA
 z<-escalc(measure='OR',ai=a,bi=b,ci=c,di=e,add=.5,to='only0',drop00=FALSE)
 add(id,d,z$yi,z$vi,source,data.frame(e1=a,n1=a+b,e2=c,n2=c+e))
}
for(n in items) {
 e<-new.env();data(list=n,package='metadat',envir=e);obj<-e[[n]];before<-length(corpus)
 # Preserve installed package documentation as source evidence for column semantics.
 h<-tryCatch(utils:::.getHelpFile(help(n,package='metadat')),error=function(e)NULL)
 if(!is.null(h))docs[[n]]<-gsub('[[:cntrl:]]',' ',paste(capture.output(tools::Rd2txt(h)),collapse=' '))
 frames<-if(is.data.frame(obj))setNames(list(obj),'') else if(is.list(obj))obj[vapply(obj,is.data.frame,TRUE)] else list()
 for(fi in seq_along(frames)) {
 f<-names(frames)[fi]
 d<-frames[[fi]];id<-paste0(n,if(nchar(f))paste0('/',f) else ''); if(n=='dat.kearon1998')d$fp<-d$nn-d$tn;cols<-names(d)
 if(all(c('yi','vi')%in%cols))add(id,d,d$yi,d$vi,'provided yi/vi')
 # Explicit alternative effect/variance or SE columns; no inferred effect scale conversions.
 pairs<-list(c('wmwstat','stderr','se'),c('mean','SE','se'),c('s1','vars1','var'),c('s2','vars2','var'),c('s3','vars3','var'),c('es.z','vi.z','var'),c('logOR','varlogOR','var'),c('b','SE','se'),c('smd','se','se'),c('lnHR','selnHR','se'),c('diff','se','se'),c('mean','se','se'),c('total.logrr','total.se','se'),c('female.logrr','female.se','se'),c('male.logrr','male.se','se'),c('sex.logrrr','sex.se','se'),c('sgrq.md','sgrq.se','se'),c('fev1.md','fev1.se','se'),c('yi_iq','vi_iq','var'))
 for(q in pairs)if(all(q[1:2]%in%cols))add(paste0(id,'/',q[1]),d,d[[q[1]]],if(q[3]=='se')d[[q[2]]]^2 else d[[q[2]]],paste(q,collapse='/'))
 for(i in 1:4)if(all(c(paste0('y',i,'i'),paste0('v',i,'i'))%in%cols))add(paste0(id,'/y',i,'i'),d,d[[paste0('y',i,'i')]],d[[paste0('v',i,'i')]],'provided endpoint effect/variance')
 specs<-list(c('ai','n1i','ci','n2i','n'),c('ai','bi','ci','di','cells'),c('tpos','tneg','cpos','cneg','cells'),c('Ee','Ne','Ec','Nc','n'),c('xt','nt','xc','nc','n'),c('x.a','n.a','x.p','n.p','n'),c('waward','wtotal','maward','mtotal','n'),c('x.nrt','n.nrt','x.ctrl','n.ctrl','n'),c('hcq_arm_event','hcq_arm_total','control_arm_event','control_arm_total','n'),c('resp.halo','fail.halo','resp.plac','fail.plac','cells'),c('n.cbt.rec','n.cbt.non','n.ctrl.rec','n.ctrl.non','cells'),c('ihd.exp','noihd.exp','ihd.cont','noihd.cont','cells'),c('non.pos','non.neg','cir.pos','cir.neg','cells'),c('xTi','nTi','xCi','nCi','n'),c('lh.le','lh.re','rh.le','rh.re','cells'),c('TP','FP','FN','TN','cells'),c('tp','np','fp','nn','n'))
 for(i in 1:6)specs<-c(specs,list(c(paste0('ep',i,'t'),'nt',paste0('ep',i,'c'),'nc','n')))
 for(i in 1:4)specs<-c(specs,list(c(paste0('e',i,'i'),'nei',paste0('c',i,'i'),'nci','n')))
 for(ep in c('mi','stroke','death','vdeath'))specs<-c(specs,list(c(paste0('p2y12.',ep),'p2y12.total',paste0('aspirin.',ep),'aspirin.total','n')))
 for(ep in c('exa','sexa','hospi','deaths','sae','dropout'))specs<-c(specs,list(c(paste0('tiotropium.',ep),'tiotropium.total',paste0('placebo.',ep),'placebo.total','n')))
 for(ep in c('infarction','death'))specs<-c(specs,list(c(paste0('treat.',ep),'treat.total',paste0('cont.',ep),'cont.total','n')))
 for(ep in c('b','o','d'))specs<-c(specs,list(c(paste0(ep,'.xti'),'nti',paste0(ep,'.xci'),'nci','n')))
 specs<-c(specs,list(c('pre.xti','pre.nti','pre.xci','pre.nci','n')))
 for(ep in c('ped','stb','ned'))specs<-c(specs,list(c(paste0(ep,'.xti'),'fup.nti',paste0(ep,'.xci'),'fup.nci','n')))
 for(ep in c('resp','remi','loss','loss.ae','ae'))for(j in 2:3)specs<-c(specs,list(c(paste0(ep,'1'),'n1',paste0(ep,j),paste0('n',j),'n')))
 for(q in specs)if(all(q[1:4]%in%cols)) {a<-d[[q[1]]];b<-d[[q[2]]];cc<-d[[q[3]]];dd<-d[[q[4]]];if(q[5]=='n'){b<-b-a;dd<-dd-cc};bin(paste0(id,'/OR:',q[1],':',q[3]),d,a,b,cc,dd,paste(q,collapse='/'))}
 if(n=='dat.tian2009')for(ep in c('deaths','infarcts')) {
 aa<-data.frame(study=d$study,trt=d$group,event=d[[ep]],n=d$n);tt<-sort(unique(aa$trt));
 x<-merge(aa[aa$trt==tt[1],],aa[aa$trt==tt[2],],by='study');
 bin(paste0(id,'/OR:',ep),x,x$event.x,x$n.x-x$event.x,x$event.y,x$n.y-x$event.y,paste('paired study/group',ep,'n'))
 }
 # Arm-level network data: preserve named pairwise treatment comparisons; do not pool different contrasts.
 arm<-switch(n,dat.baker2009=c('study','treatment','exac','total'),dat.dogliotti2014=c('study','treatment','stroke','total'),dat.dong2013=c('id','treatment','death','randomized'),dat.gurusamy2011=c('study','treatment','death','n'),dat.hasselblad1998=c('id','trt','xi','ni'),dat.linde2016=c('id','int','resp','n'),dat.pagliaro1992=c('study','trt','xi','ni'),dat.woods2010=c('author','treatment','r','N'),NULL)
 if(!is.null(arm)) {aa<-data.frame(study=d[[arm[1]]],trt=as.character(d[[arm[2]]]),event=d[[arm[3]]],n=d[[arm[4]]]); tt<-sort(unique(aa$trt));if(length(tt)>1)for(q in combn(tt,2,simplify=FALSE)){x<-merge(aa[aa$trt==q[1],],aa[aa$trt==q[2],],by='study');if(nrow(x)>=3)bin(paste0(id,'/OR:',paste(q,collapse=':')),x,x$event.x,x$n.x-x$event.x,x$event.y,x$n.y-x$event.y,paste(arm,collapse='/'))}}
 }
 inventory[[n]]<-list(dataset=n,used=length(corpus)>before,configurations=names(corpus)[seq_along(corpus)>before],reason=if(length(corpus)>before)'usable effect/variance or binary contrasts; see corpus source fields' else 'no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows',columns=names(obj))
}
writej(unname(corpus),'corpus.json');writej(inventory,'dataset-disposition.json');writej(docs,'source-documentation.json')
cat('CORPUS',length(corpus),'configurations from',sum(vapply(inventory,function(x)x$used,TRUE)),'of',length(items),'datasets\n')
ref<-list(); warnings<-list()
capture<-function(expr) {w<-character(); value<-tryCatch(withCallingHandlers(expr,warning=function(e){w<<-c(w,conditionMessage(e));invokeRestart('muffleWarning')}),error=function(e)list(error=conditionMessage(e)));list(value=value,warnings=w)}
for(id in names(corpus)) {
 d<-corpus[[id]];y<-d$yi;v<-d$vi;r<-list()
 for(model in c('lm','rma'))r[[paste0('egger_',model)]]<-capture({m<-rma(y,v,method='REML');z<-regtest(m,model=model,predictor='sei',ret.fit=TRUE);list(statistic=z$zval,p=z$pval,b0=as.numeric(coef(z$fit)[2]),limit=as.numeric(coef(z$fit)[1]))})
 r$begg<-capture({z<-ranktest(y,vi=v);list(tau=z$tau,p=z$pval)})
 r$trimfill<-capture({z<-trimfill(rma(y,v,method='REML'),estimator='L0');list(k0=z$k0,side=z$side,est=as.numeric(z$b),se=z$se,tau2=z$tau2)})
 r$selection<-if(d$k<4)list(value=list(error='k < 4'),warnings=character()) else capture({z<-selmodel(rma(y,v,method='ML'),type='stepfun',steps=.025);list(mu=as.numeric(z$b),se=z$se,tau2=z$tau2,delta=unname(z$delta),LRT=z$LRT,LRTp=z$LRTp)})
 if(!is.null(d$binary))for(method in c('Peters','Harbord'))r[[tolower(method)]]<-capture({b<-d$binary;z<-metabias(metabin(b$e1,b$n1,b$e2,b$n2,sm='OR',method='Inverse',allstudies=TRUE),method.bias=method,k.min=3);list(statistic=unname(z$statistic),p=z$p.value)})
 ref[[id]]<-r;writej(list(versions=list(R=R.version.string,metafor=as.character(packageVersion('metafor')),metadat=as.character(packageVersion('metadat')),meta=as.character(packageVersion('meta'))),datasets=ref),'reference.json')
 cat('REFERENCE',length(ref),'/',length(corpus),id,'\n');flush.console()
}
cat('REFERENCE COMPLETE:',length(ref),'configurations\n')
