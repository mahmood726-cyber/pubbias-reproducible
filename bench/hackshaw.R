library(metafor)
data(dat.hackshaw1998, package='metadat')
z <- rma(yi, vi, data=dat.hackshaw1998, method='REML')
f <- commandArgs(trailingOnly=TRUE)[1]
cat(sprintf('{"dataset":"dat.hackshaw1998","method":"REML","R":"%s","metafor":"%s","k":%d,"OR":%.17g,"lower":%.17g,"upper":%.17g}',R.version.string,as.character(packageVersion('metafor')),z$k,exp(coef(z)),exp(z$ci.lb),exp(z$ci.ub)),file=f)
