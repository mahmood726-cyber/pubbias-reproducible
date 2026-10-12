#!/usr/bin/env Rscript
# Recompute the five paper methods from the frozen corpus, without Python/browser.
args <- commandArgs(trailingOnly=TRUE)
script <- normalizePath(sub('^--file=', '', grep('^--file=', commandArgs(), value=TRUE)[1]), winslash='/')
root <- dirname(script)
for (p in c('metafor', 'meta')) {
  if (!requireNamespace(p, quietly=TRUE)) stop('Required installed package missing: ', p, '; no packages are downloaded.')
}
# Small strict JSON reader for this archive; jsonlite is optional, not required.
# Tokens are validated before parsing. Only quoted string literals reach parse().
readj <- function(p) {
  if(requireNamespace('jsonlite',quietly=TRUE))return(jsonlite::fromJSON(p,simplifyVector=FALSE))
  text<-paste(readLines(p,warn=FALSE,encoding='UTF-8'),collapse='\n')
  pattern<-'"(?:[^"\\\\\\x00-\\x1f]|\\\\(?:["\\\\/bfnrt]|u[0-9a-fA-F]{4}))*"|-?(?:0|[1-9][0-9]*)(?:\\.[0-9]+)?(?:[eE][+-]?[0-9]+)?|true|false|null|[{}\\[\\]:,]'
  positions<-gregexpr(pattern,text,perl=TRUE)[[1]]
  tokens<-regmatches(text,list(positions))[[1]]
  gaps<-gsub(pattern,'',text,perl=TRUE)
  if(nzchar(gsub('[[:space:]]','',gaps)))stop('Invalid JSON token: ',p)
  index<-1L
  take<-function(){if(index>length(tokens))stop('Unexpected JSON end');t<-tokens[index];index<<-index+1L;t}
  string<-function(t)eval(parse(text=gsub('\\/', '/', t, fixed=TRUE)),envir=baseenv())
  value<-function() {
    t<-take()
    if(t %in% c('{','[')) {
      object<-t=='{';end<-if(object)'}' else ']';out<-list()
      if(tokens[index]==end){take();return(out)}
      repeat {
        if(object){key<-take();if(substr(key,1,1)!='"')stop('Invalid object key');key<-string(key);if(key %in% names(out))stop('Duplicate JSON key');if(take()!=':')stop('Missing JSON colon')}
        v<-value()
        if(object)out[key]<-list(v) else out[length(out)+1L]<-list(v)
        delim<-take();if(delim==end)break;if(delim!=',')stop('Missing JSON separator')
      }
      return(out)
    }
    if(substr(t,1,1)=='"')return(string(t))
    if(t=='null')return(NULL)
    if(t=='true')return(TRUE)
    if(t=='false')return(FALSE)
    n<-suppressWarnings(as.numeric(t));if(!is.finite(n))stop('Invalid JSON number');n
  }
  result<-value();if(index!=length(tokens)+1L)stop('Trailing JSON tokens');result
}
js <- function(x) {
  if(is.null(x))return('null')
  if(is.list(x)) {
    v<-vapply(x,js,'')
    if(!is.null(names(x)))return(paste0('{',paste(paste0(vapply(names(x),js,''),':',v),collapse=','),'}'))
    return(paste0('[',paste(v,collapse=','),']'))
  }
  if(length(x)!=1)return(js(as.list(x)))
  if(is.na(x))return('null')
  if(is.character(x)) {
    x<-gsub('\\','\\\\',x,fixed=TRUE);x<-gsub('"','\\"',x,fixed=TRUE)
    for(pair in list(c('\n','\\n'),c('\r','\\r'),c('\t','\\t')))x<-gsub(pair[1],pair[2],x,fixed=TRUE)
    return(paste0('"',x,'"'))
  }
  if(is.logical(x))return(if(x)'true' else 'false')
  if(!is.finite(x))return('null');sprintf('%.17g',x)
}
writej <- function(x,p)writeLines(js(x),p,useBytes=TRUE)
capture <- function(expr) {
  tryCatch(withCallingHandlers(expr,warning=function(w)invokeRestart('muffleWarning')),
           error=function(e)list(error=conditionMessage(e)))
}
fields <- list(egger_lm=c('statistic','p','b0','limit'),begg=c('tau','p'),
               trimfill=c('k0','side','est','se','tau2'),peters=c('statistic','p'),harbord=c('statistic','p'))
labels <- c(egger_lm='Egger',begg='Begg',trimfill='Trim-and-fill',peters='Peters',harbord='Harbord')
appkeys <- c(egger_lm='egger',begg='begg',trimfill='trimfill',peters='peters',harbord='harbord')
compute <- function(d, method) {
  y <- unlist(d$yi); v <- unlist(d$vi)
  switch(method,
    egger_lm={
      m <- metafor::rma(y,v,method='REML')
      z <- metafor::regtest(m,model='lm',predictor='sei',ret.fit=TRUE)
      list(statistic=z$zval,p=z$pval,b0=as.numeric(coef(z$fit)[2]),limit=as.numeric(coef(z$fit)[1]))
    },
    begg={z<-metafor::ranktest(y,vi=v);list(tau=z$tau,p=z$pval)},
    trimfill={
      z<-metafor::trimfill(metafor::rma(y,v,method='REML'),estimator='L0')
      list(k0=z$k0,side=z$side,est=as.numeric(z$b),se=z$se,tau2=z$tau2)
    },
    peters=,harbord={
      b<-as.data.frame(do.call(rbind,lapply(d$binary,unlist)))
      z<-meta::metabias(meta::metabin(b$e1,b$n1,b$e2,b$n2,sm='OR',method='Inverse',allstudies=TRUE),method.bias=labels[[method]],k.min=3)
      list(statistic=unname(z$statistic),p=z$p.value)
    },stop('Unknown method'))
}

# Child R process: system2's OS timeout bounds even native code. Checkpoints let
# completed methods survive a later timeout. McCurdy trimfill gets its own 120 s.
if(length(args) && args[1]=='--worker') {
  job<-readj(args[2]); result<-list()
  for(method in unlist(job$methods)) {
    result[[method]]<-capture(compute(job$data,method))
    writej(result,args[3])
  }
  quit(status=0)
}
if(length(args))stop('Usage: Rscript validate.R')
corpus<-readj(file.path(root,'data/corpus.json'))
app<-readj(file.path(root,'results/app-merged-3dcc679.json'))
expected<-read.csv(file.path(root,'outputs/table2_failed_checks.csv'),check.names=FALSE,stringsAsFactors=FALSE)
identity<-function(id,method,q)paste(id,method,q,sep=' | ')
known<-with(expected,identity(dataset_configuration,method,quantity))
ids<-vapply(corpus,function(d)d$id,'')
stopifnot(length(ids)==152L, !anyDuplicated(ids),setequal(ids,names(app)),length(known)==6L,!anyDuplicated(known))
cat('Actual versions:',R.version.string,'\n')
for(p in c('metafor','meta','jsonlite','metadat'))if(requireNamespace(p,quietly=TRUE))cat(p,as.character(packageVersion(p)),'\n')
cat('Paper: metafor 5.2-1; meta 8.5-0; metadat 1.6-0. Selection excluded.\n')
scratch<-tempfile('.pubbias-validation-',tmpdir=root);dir.create(scratch)
on.exit_cleanup <- function()unlink(scratch,recursive=TRUE)
ledger<-list(); n<-0L
scalar<-function(x)length(x)==1 && is.numeric(x) && is.finite(x)
# Original reference-one.R serializes scalar NA/NaN/Inf as JSON null before
# compare.py turns a missing binary statistic AND p into a matched refusal.
missing_number<-function(x)is.null(x) || (length(x)==1 && is.numeric(x) && !is.finite(x))
showvalue<-js
record<-function(id,method,q,av,rv,diff,tol,pass) {
  n<<-n+1L
  key<-identity(id,labels[[method]],q)
  ledger[[n]]<<-data.frame(dataset_configuration=id,method=labels[[method]],quantity=q,
    App=showvalue(av),R=showvalue(rv),Difference=diff,Tolerance=tol,
    Verdict=if(pass)'PASS' else 'FAIL',Known_exception=key %in% known,stringsAsFactors=FALSE)
}
worker<-function(d,methods,tag) {
  input<-file.path(scratch,paste0(tag,'-input.json')); output<-file.path(scratch,paste0(tag,'-result.json'))
  log<-file.path(scratch,paste0(tag,'.log'))
  writej(list(data=d,methods=methods),input)
  status<-suppressWarnings(system2(file.path(R.home('bin'),'Rscript'),
    c(shQuote(script),'--worker',shQuote(input),shQuote(output)),stdout=log,stderr=log,timeout=120))
  result<-if(file.exists(output))readj(output) else list()
  for(method in methods)if(is.null(result[[method]]))result[[method]]<-list(unavailable=TRUE,
    error=if(status==124)'Independent method attempt exceeded 120 seconds' else 'Independent method attempt failed; no result')
  if(status!=0)cat('Worker',d$id,paste(methods,collapse=','),'status',status,'\n')
  result
}
for(i in seq_along(corpus)) {
  d<-corpus[[i]]
  stopifnot(length(d$yi)==d$k,length(d$vi)==d$k,all(is.finite(unlist(d$yi))),all(is.finite(unlist(d$vi))),all(unlist(d$vi)>0))
  methods<-c('egger_lm','begg',if(!is.null(d$binary))c('peters','harbord'),'trimfill')
  ref<-list()
  for(method in methods) {
    if(d$id=='dat.mccurdy2020' && method=='trimfill') {
      ref[[method]]<-worker(d,method,paste0(i,'-trimfill'))[[method]]
    } else {
      # Ordinary fits reuse loaded namespaces. R's elapsed-time guard is checked
      # at R interrupt points; the large trimfill fit above uses an OS hard cap.
      setTimeLimit(elapsed=120,transient=TRUE)
      ref[[method]]<-capture(compute(d,method))
      setTimeLimit(cpu=Inf,elapsed=Inf,transient=FALSE)
      if(!is.null(ref[[method]]$error) && grepl('elapsed time limit',ref[[method]]$error,fixed=TRUE))ref[[method]]$unavailable<-TRUE
    }
  }
  for(method in names(fields)) {
    if(!method %in% methods)next
    rv<-ref[[method]];av<-app[[d$id]][[appkeys[[method]]]]
    if(is.null(av))av<-list(error='null result')
    if(method %in% c('peters','harbord') && is.null(rv$error) && missing_number(rv$statistic) && missing_number(rv$p))rv<-list(error='meta::metabias returned no statistic or p-value (insufficient informative rows)')
    if(!is.null(rv$error) || !is.null(av$error)) {
      pass<-!is.null(rv$error)&&!is.null(av$error)&&!isTRUE(rv$unavailable)&&!isTRUE(av$unavailable)
      record(d$id,method,'refusal',av,rv,if(pass)0 else 1,0,pass)
    } else for(q in fields[[method]]) {
      x<-rv[[q]];y<-av[[q]]
      tol<-if(method=='trimfill' && q %in% c('est','se','tau2'))1e-6 else if(q=='side')0 else 1e-9
      diff<-if(q=='side') {if(is.character(x)&&is.character(y)&&identical(x,y))0 else Inf} else if(scalar(x)&&scalar(y))abs(x-y)/if(q=='p')1 else max(1,abs(x)) else Inf
      record(d$id,method,q,y,x,diff,tol,is.finite(diff)&&diff<=tol)
    }
  }
  cat('R',i,'/',length(corpus),d$id,'\n');flush.console()
}
table<-do.call(rbind,ledger)
dir.create(file.path(root,'outputs'),showWarnings=FALSE)
write.csv(table,file.path(root,'outputs/validate_R_table.csv'),row.names=FALSE,fileEncoding='UTF-8',eol='\n')
cat('Quantity | Passing/Checks | Maximum difference | Tolerance\n')
for(method in unique(table$method))for(q in unique(table$quantity[table$method==method])) {
  s<-table[table$method==method & table$quantity==q,]
  cat(sprintf('%s.%s | %d/%d | %.17g | %.17g\n',method,q,sum(s$Verdict=='PASS'),nrow(s),max(s$Difference),s$Tolerance[1]))
}
failed<-table[table$Verdict=='FAIL',]
cat('Failed checks (documented exceptions remain FAIL):\n')
for(i in seq_len(nrow(failed)))cat(identity(failed$dataset_configuration[i],failed$method[i],failed$quantity[i]),if(failed$Known_exception[i])' [documented]' else ' [UNEXPECTED]','\n',sep='')
cat('Historical paper: 2107/2113; a timeout may change with hardware. No archived R result is substituted.\n')
unexpected<-sum(!failed$Known_exception)
cat('Unexpected failures:',unexpected,'\n')
cat(sprintf('%d/%d checks pass\n',sum(table$Verdict=='PASS'),nrow(table)))
on.exit_cleanup()
quit(status=if(unexpected>0)1 else 0)
