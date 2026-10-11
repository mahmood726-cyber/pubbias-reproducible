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
capture<-function(expr) {w<-character(); value<-tryCatch(withCallingHandlers(expr,warning=function(e){w<<-c(w,conditionMessage(e));invokeRestart('muffleWarning')}),error=function(e)list(error=conditionMessage(e)));list(value=value,warnings=w)}

source(Sys.getenv('ONE_INPUT'));id<-names(corpus)[1]
 d<-corpus[[id]];y<-d$yi;v<-d$vi;r<-list()
 for(model in c('lm','rma'))r[[paste0('egger_',model)]]<-capture({m<-rma(y,v,method='REML');z<-regtest(m,model=model,predictor='sei',ret.fit=TRUE);list(statistic=z$zval,p=z$pval,b0=as.numeric(coef(z$fit)[2]),limit=as.numeric(coef(z$fit)[1]))})
 writej(r,Sys.getenv('ONE_OUTPUT'))
 r$begg<-capture({z<-ranktest(y,vi=v);list(tau=z$tau,p=z$pval)})
 writej(r,Sys.getenv('ONE_OUTPUT'))
 r$trimfill<-capture({z<-trimfill(rma(y,v,method='REML'),estimator='L0');list(k0=z$k0,side=z$side,est=as.numeric(z$b),se=z$se,tau2=z$tau2)})
 writej(r,Sys.getenv('ONE_OUTPUT'))
 r$selection<-if(d$k<4)list(value=list(error='k < 4'),warnings=character()) else capture({z<-selmodel(rma(y,v,method='ML'),type='stepfun',steps=.025);list(mu=as.numeric(z$b),se=z$se,tau2=z$tau2,delta=unname(z$delta),LRT=z$LRT,LRTp=z$LRTp)})
 writej(r,Sys.getenv('ONE_OUTPUT'))
 if(!is.null(d$binary))for(method in c('Peters','Harbord'))r[[tolower(method)]]<-capture({b<-d$binary;z<-metabias(metabin(b$e1,b$n1,b$e2,b$n2,sm='OR',method='Inverse',allstudies=TRUE),method.bias=method,k.min=3);list(statistic=unname(z$statistic),p=z$p.value)})
 writej(r,Sys.getenv('ONE_OUTPUT'))
writej(r,Sys.getenv('ONE_OUTPUT'))
