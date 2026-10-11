const fs=require('fs'),path=require('path'),{pathToFileURL}=require('url');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE || 'playwright');
(async()=>{
 const browser=await chromium.launch({channel:'chrome',headless:true,args:['--allow-file-access-from-files']});
 const page=await browser.newPage(),checks=[]; await page.route(/^https?:/, r=>r.abort());
 await page.goto(pathToFileURL(path.resolve('app/pubbias-tests/index.html')).href);
 function check(name,ok){checks.push({name,pass:!!ok});if(!ok)throw Error(name);}
 let r=await page.evaluate(()=>({result:window._almLastPubbias(),text:document.body.textContent}));
 check('experimental selection warning visible',r.text.includes('experimental, not validated against metafor'));
 check('Egger t with compatibility alias',r.result.egger_t===r.result.egger_z);
 const corpus=JSON.parse(fs.readFileSync('data/corpus.json'));
 const d=corpus.find(d=>d.id==='dat.bangertdrowns2004');
 for(const n of [3,5]){
  await page.selectOption('#format','te-se');await page.fill('#src',d.yi.slice(0,n).map((y,i)=>`${y},${Math.sqrt(d.vi[i])}`).join('\n'));await page.click('#btn-run');
  r=await page.evaluate(()=>({result:window._almLastPubbias(),rows:document.querySelectorAll('#body tr').length}));
  check('k='+n+' UI contract',n===3?r.result===null:r.result&&r.result.k===5&&r.rows>=4);
 }
 const bad=corpus.find(d=>d.id==='dat.baker2009/OR:Placebo:Salmeterol');
 await page.fill('#src',bad.yi.map((y,i)=>`${y},${Math.sqrt(bad.vi[i])}`).join('\n'));await page.click('#btn-run');
 r=await page.evaluate(()=>({result:window._almLastPubbias(),text:document.querySelector('#body').textContent}));
 check('REML refusal clears previous export',r.result===null);
 check('REML refusal shown to user',r.text.includes('Analysis unavailable:')&&r.text.includes('Fisher scoring'));
 await browser.close();fs.writeFileSync('outputs/ui-smoke.json',JSON.stringify(checks,null,2));console.log(`UI SMOKE2: ${checks.filter(c=>c.pass).length}/${checks.length} checks pass`);
})().catch(e=>{console.error(e);process.exit(1)});
