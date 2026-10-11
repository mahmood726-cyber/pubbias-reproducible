const fs=require('fs'),path=require('path');
const {pathToFileURL}=require('url');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE || 'playwright');
(async()=>{
 const root=process.argv[2]||'original', output=process.argv[3]||'app.json';
 const browser=await chromium.launch({channel:'chrome',headless:true});
 const page=await browser.newPage(); const cdp=await page.context().newCDPSession(page);
 await cdp.send('Debugger.enable');
 const url=pathToFileURL(path.resolve(root,'pubbias-tests/index.html')).href;
 const html=fs.readFileSync(path.resolve(root,'pubbias-tests/index.html'),'utf8');
 const line=html.slice(0,html.indexOf('window.__almPubBiasEngine =')).split('\n').length-1;
 await cdp.send('Debugger.setBreakpointByUrl',{url,lineNumber:line});
 cdp.on('Debugger.paused',async ev=>{
  await cdp.send('Debugger.evaluateOnCallFrame',{callFrameId:ev.callFrames[0].callFrameId,expression:'window.__audit={trimFill:trimFill,remlPool:remlPool,remlSlopeNeg:remlSlopeNeg,wls:wls}'});
  await cdp.send('Debugger.resume');
 });
 await page.goto(url); await page.waitForFunction(()=>window.__audit&&window.__almPubBiasEngine);
 await cdp.send('Debugger.disable');
 const corpus=JSON.parse(fs.readFileSync(path.resolve(__dirname,'../data/corpus.json'),'utf8')),all={};
 for(const d of corpus){
  const timer=setTimeout(()=>cdp.send('Runtime.terminateExecution').catch(()=>{}),30000);
  try {all[d.id]=await page.evaluate(d=>{
   const E=window.__almPubBiasEngine,A=window.__audit,rows=d.yi.map((te,i)=>({te,se:Math.sqrt(d.vi[i])}));
   const safe=fn=>{try{return fn()}catch(e){return {error:String(e)}}};
   const o={egger:safe(()=>E.eggerGeneric(rows)),begg:safe(()=>E.beggMazumdar(rows)),trimfill:safe(()=>{
     const tf=A.trimFill(rows);tf.side=A.remlSlopeNeg(d.yi,d.vi,d.vi.map(Math.sqrt))?'right':'left';return tf;
   }),selection:safe(()=>d.k<4?{error:'k < 4'}:window.AlmSelModel.fit(d.yi,rows.map(r=>r.se*r.se),{steps:[.025],method:'REML'}))};
   if(!o.egger.error)o.egger.limit=safe(()=>A.wls(rows.map(r=>1/r.se),rows.map(r=>r.te/r.se),rows.map(()=>1)).b1);
   if(d.binary){const b=E.parseBinary(d.binary.map(r=>[r.e1,r.n1,r.e2,r.n2].join(',')).join('\n'));o.peters=safe(()=>E.petersTest(b));o.harbord=safe(()=>E.harbordTest(b));}
   return o;
  },d);}catch(e){all[d.id]={error:String(e)}}finally{clearTimeout(timer)}
  fs.writeFileSync(output,JSON.stringify(all,null,2)); console.log('APP',Object.keys(all).length,'/',corpus.length,d.id);
 }
 await browser.close();console.log('APP COMPLETE:',Object.keys(all).length,'configurations');
})().catch(e=>{console.error(e);process.exit(1)});
