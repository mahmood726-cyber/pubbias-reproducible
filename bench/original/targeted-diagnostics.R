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
cat('TARGETED DIAGNOSTICS COMPLETE:',length(out),'configurations\n')
