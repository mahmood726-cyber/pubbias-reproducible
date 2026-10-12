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
# Hash the contract before trusting its file pins. Base/tools has MD5 on this
# installation; prefer SHA-256 if a future tools version exposes it.
hash_file<-function(path, algorithm) {
  if(algorithm=='sha256')return(unname(get('sha256sum',asNamespace('tools'))(path)))
  unname(tools::md5sum(path))
}
algorithm<-if(exists('sha256sum',asNamespace('tools'),inherits=FALSE))'sha256' else 'md5'
contract_pin<-c(sha256='0e63b91baed36186e624adfca7661981818127a6ef306e7740a4bcb929461dbb',md5='7623510f33cfab38b2da04ac9da6aef5')
verify_hash<-function(path,want) {
  if(!file.exists(path)||!identical(hash_file(path,algorithm),want))stop('Archive integrity mismatch: ',basename(path))
}
verify_hash(file.path(root,'validation-contract.json'),unname(contract_pin[[algorithm]]))
contract<-readj(file.path(root,'validation-contract.json'))
stopifnot(identical(contract$archive$version,'app-merged-3dcc679 / paper-ledger-2113'))
for(f in names(contract$archive$files))verify_hash(file.path(root,f),contract$archive$files[[f]][[algorithm]])
cat('Archive integrity PASS:',algorithm,'(strongest available in base R/tools);',contract$archive$version,'\n')
corpus<-readj(file.path(root,'data/corpus.json'))
app<-readj(file.path(root,'results/app-merged-3dcc679.json'))
expected<-read.csv(file.path(root,'outputs/table2_failed_checks.csv'),check.names=FALSE,stringsAsFactors=FALSE)
identity<-function(id,method,q)paste(id,method,q,sep=' | ')
known<-with(expected,identity(dataset_configuration,method,quantity))
expected_checks<-unlist(contract$checks)
historical<-Filter(function(x)x$method %in% names(fields),readj(file.path(root,'outputs/check_ledger.json')))
historical_keys<-vapply(historical,function(x)identity(x$dataset,x$method,x$quantity),'')
stopifnot(length(expected_checks)==2113L,!anyDuplicated(expected_checks),identical(expected_checks,historical_keys),
          sum(vapply(historical,function(x)!isTRUE(x$passed),TRUE))==6L,
          identical(contract$exceptions,Filter(function(x)!isTRUE(x$passed),historical)))
cat('Immutable historical replay ledger: 2107/2113; six documented FAILs; coverage PASS\n')
ids<-vapply(corpus,function(d)d$id,'')
stopifnot(length(ids)==152L, !anyDuplicated(ids),setequal(ids,names(app)),length(known)==6L,!anyDuplicated(known))
stopifnot(setequal(ids,unlist(contract$configurations)))
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
tol_for<-function(method,q)if(method=='trimfill' && q %in% c('est','se','tau2'))1e-6 else if(q=='side')0 else 1e-9
close_value<-function(x,y,method,q) {
  if(q=='side')return(is.character(x)&&identical(x,y))
  scalar(x)&&scalar(y)&&abs(x-y)/(if(q=='p')1 else max(1,abs(y)))<=tol_for(method,q)
}
valid_app<-function(av,method) {
  if(!is.list(av)||!length(av))return(FALSE)
  if('error' %in% names(av))return(is.character(av$error)&&length(av$error)==1L&&nzchar(av$error))
  all(vapply(fields[[method]],function(q)if(q=='side')is.character(av[[q]])&&length(av[[q]])==1L&&av[[q]] %in% c('left','right') else scalar(av[[q]]),TRUE))
}
documented<-function(id,method,q,av,rv) {
  hit<-Filter(function(e)identical(e$dataset,id)&&identical(e$method,method)&&identical(e$quantity,q),contract$exceptions)
  if(length(hit)!=1L)return(FALSE)
  e<-hit[[1]]
  if(q!='refusal')return(close_value(av,e$app,method,q)&&close_value(rv,e$reference,method,q))
  if(!is.null(av$error)||!all(vapply(fields[[method]],function(f)close_value(av[[f]],e$app[[f]],method,f),TRUE)))return(FALSE)
  if(isTRUE(e$reference$unavailable))return(isTRUE(rv$unavailable)&&identical(rv$workerStatus,'timeout')&&identical(rv$exitStatus,124L)&&identical(rv$stage,'method-computation'))
  identical(rv$error,e$reference$error)&&!isTRUE(rv$unavailable)
}
showvalue<-js
record<-function(id,method,q,av,rv,diff,tol,pass) {
  n<<-n+1L
  key<-identity(id,labels[[method]],q)
  ledger[[n]]<<-data.frame(dataset_configuration=id,method=labels[[method]],quantity=q,
    App=showvalue(av),R=showvalue(rv),Difference=diff,Tolerance=tol,
    Verdict=if(pass)'PASS' else 'FAIL',Known_exception=!pass&&documented(id,method,q,av,rv),stringsAsFactors=FALSE)
}
worker<-function(d,methods,tag) {
  input<-file.path(scratch,paste0(tag,'-input.json')); output<-file.path(scratch,paste0(tag,'-result.json'))
  log<-file.path(scratch,paste0(tag,'.log'))
  writej(list(data=d,methods=methods),input)
  status<-tryCatch(suppressWarnings(system2(file.path(R.home('bin'),'Rscript'),
    c(shQuote(script),'--worker',shQuote(input),shQuote(output)),stdout=log,stderr=log,timeout=120)),error=function(e)NA_integer_)
  state<-if(is.na(status)||status %in% c(126,127))'start-failure' else if(status==124)'timeout' else if(status!=0)'crash' else 'success'
  result<-if(file.exists(output))tryCatch(readj(output),error=function(e)list()) else list()
  for(method in methods) {
    if(state!='success'||is.null(result[[method]]))result[[method]]<-list(unavailable=TRUE,
      error=paste('Independent method attempt',state),workerStatus=if(state=='success')'missing-result' else state,
      exitStatus=as.integer(status),stage=if(state=='start-failure')'startup' else 'method-computation')
    else result[[method]]$workerStatus<-'success'
  }
  if(state!='success')cat('Worker',d$id,paste(methods,collapse=','),'status',state,status,'\n')
  result
}
refusal_reason<-function(v,method,d) {
  if(isTRUE(v$unavailable)||is.null(v$error))return(NULL)
  e<-sub('^Error: ','',v$error)
  if(method %in% c('peters','harbord') && e %in% c('Insufficient informative rows.','meta::metabias returned no statistic or p-value (insufficient informative rows)')) {
    informative<-vapply(d$binary,function(b)b$e1+b$e2>0 && b$e1+b$e2<b$n1+b$n2,TRUE)
    if(!is.null(d$binary)&&sum(informative)<3)return('insufficient-informative-rows')
  }
  if(e %in% c('Fisher scoring algorithm did not converge.',"Fisher scoring algorithm did not converge. See 'help(rma)' for possible remedies."))return('reml-nonconvergence')
  if(method=='trimfill'&&e=='Trim and fill algorithm did not converge.')return('trimfill-nonconvergence')
  NULL
}
for(i in seq_along(corpus)) {
  d<-corpus[[i]]
  stopifnot(scalar(d$k),d$k>0,d$k==as.integer(d$k),length(d$yi)==d$k,length(d$vi)==d$k,all(vapply(d$yi,scalar,TRUE)),all(vapply(d$vi,scalar,TRUE)),all(unlist(d$vi)>0))
  methods<-c('egger_lm','begg',if(!is.null(d$binary))c('peters','harbord'),'trimfill')
  for(method in methods)if(!valid_app(app[[d$id]][[appkeys[[method]]]],method))stop('Missing or invalid app method record: ',d$id,'/',method)
  if(!is.null(d$binary))stopifnot(length(d$binary)==d$k,all(vapply(d$binary,function(b)all(vapply(c('e1','n1','e2','n2'),function(q)scalar(b[[q]]),TRUE))&&b$n1>0&&b$n2>0&&b$e1>=0&&b$e2>=0&&b$e1<=b$n1&&b$e2<=b$n2,TRUE)))
  ref<-list()
  for(method in methods) {
    if(d$id=='dat.mccurdy2020' && method=='trimfill') {
      ref[[method]]<-worker(d,method,paste0(i,'-trimfill'))[[method]]
    } else {
      # Ordinary fits reuse loaded namespaces. R's elapsed-time guard is checked
      # at R interrupt points. Allow ordinary fits 600 s on loaded hosts;
      # McCurdy's isolated worker retains its documented 120 s OS hard cap.
      setTimeLimit(elapsed=600,transient=TRUE)
      ref[[method]]<-capture(compute(d,method))
      setTimeLimit(cpu=Inf,elapsed=Inf,transient=FALSE)
      if(!is.null(ref[[method]]$error) && grepl('elapsed time limit',ref[[method]]$error,fixed=TRUE))ref[[method]]$unavailable<-TRUE
    }
  }
  for(method in names(fields)) {
    if(!method %in% methods)next
    rv<-ref[[method]];av<-app[[d$id]][[appkeys[[method]]]]
    if(method %in% c('peters','harbord') && is.null(rv$error) && missing_number(rv$statistic) && missing_number(rv$p))rv<-list(error='meta::metabias returned no statistic or p-value (insufficient informative rows)')
    if(!is.null(rv$error) || !is.null(av$error)) {
      reason<-refusal_reason(av,method,d)
      pass<-!is.null(reason)&&identical(reason,refusal_reason(rv,method,d))
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
actual_checks<-identity(table$dataset_configuration,names(labels)[match(table$method,labels)],table$quantity)
# Fresh coverage allows either a complete successful field set or one refusal
# per required method. Refusal reasons and signatures are checked separately.
required_pairs<-unlist(lapply(corpus,function(d)paste(d$id,c('egger_lm','begg','trimfill',if(!is.null(d$binary))c('peters','harbord')),sep=' | ')))
actual_pairs<-paste(table$dataset_configuration,names(labels)[match(table$method,labels)],sep=' | ')
coverage<-!anyDuplicated(actual_checks)&&setequal(unique(actual_pairs),required_pairs)
for(pair in required_pairs) {
  rows<-which(actual_pairs==pair)
  method<-names(labels)[match(table$method[rows[1]],labels)]
  quantities<-table$quantity[rows]
  coverage<-coverage&&(identical(quantities,'refusal')||setequal(quantities,fields[[method]]))
}
for(e in contract$exceptions) {
  rows<-which(table$dataset_configuration==e$dataset & table$method==labels[[e$method]])
  if(e$quantity!='refusal')rows<-rows[table$quantity[rows]==e$quantity]
  if(length(rows)>0&&all(table$Verdict[rows]=='PASS'))cat('historical exception resolved:',identity(e$dataset,e$method,e$quantity),'\n')
}
cat('Fresh configuration/method coverage:',if(coverage)'PASS' else 'FAIL','\n')
unexpected<-sum(!failed$Known_exception)
cat('Unexpected failures:',unexpected,'\n')
cat(sprintf('%d/%d checks pass\n',sum(table$Verdict=='PASS'),nrow(table)))
on.exit_cleanup()
quit(status=if(unexpected>0 || !coverage)1 else 0)
