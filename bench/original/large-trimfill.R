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

source('bounded/input-124.R');id<-names(corpus)[1]
 d<-corpus[[id]];y<-d$yi;v<-d$vi;r<-list()
 r$trimfill<-capture({z<-trimfill(rma(y,v,method='REML'),estimator='L0');list(k0=z$k0,side=z$side,est=as.numeric(z$b),se=z$se,tau2=z$tau2)})
writej(r,'bounded/large-trimfill.json')
