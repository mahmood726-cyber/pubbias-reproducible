Publication-bias validation, job 6b: **FAIL full numerical parity; requested experimental-selection fallback delivered.**

Original: **1832/2950 checks pass**. Final patched2: **2335/2950 checks pass**. Trim-and-fill passes all five quantities on all 150 numerically comparable configurations at the unchanged tolerances. Begg tau and p each pass 151/152. Peters and Harbord statistics and p-values each pass 112/112. Selection remains unvalidated.

Configuration and provenance

Enumerated 114 installed metadat datasets; used 75, excluded 39. The unchanged original corpus contains 152 configurations, including 114 binary configurations. Both original and patched2 were actually rerun through the original Chrome/CDP harness on all configurations. The original rerun reproduces app.json exactly. The original R reference.json is reused unchanged: this follow-up does not claim a new full R corpus run. Installed metafor 5.2-1 source was inspected anew with R 4.6.0; source dumps are rma.uni-installed.txt and .selmodel.ll.stepfun-installed.txt, alongside the earlier selmodel.rma.uni.txt. Installed metadat is 1.6.0 and meta is 8.5-0, as recorded by the original R run.

Read-only source commit at this follow-up: `1ef55587c3d79bcfbf6de6b23dc6209e800a5946`. The prior job used `39f172b00233d072bdce5cfe4c7137f79167708a`; the intervening commit changes rare-events-glmm only. Byte hashes confirm that pubbias-tests/index.html, shared/selmodel.js and shared/ma-core.js still equal the original copies. No source-repository writes, installs, pushes, deployments, or portfolio updates were performed. All new files and copies are in this job folder.

The corpus uses supplied effects/variances or squared supplied SEs, and metafor::escalc(OR, add=0.5, to="only0", drop00=FALSE) for paired binary counts. Mappings, retained source-row indices and exact values remain in corpus.json and scripts/reference.R; installed source documentation remains in source-documentation.json. Kearon's corrected TP/FN/FP/TN orientation from job 6 is retained. The audit does not invent study IDs or dates or interpret these stress-test poolings clinically. There are 25 configurations below the page's k=5 minimum; engine results for those are not successful page analyses.

| Component | Static or dynamic | Evidence / transformation |
|---|---|---|
| Corpus and R reference | Dynamic outputs retained unchanged | Original installed R package calls; SHA-256 recorded in provenance2.json |
| Model settings / tolerances | Static | Egger lm, Begg exact when untied, L0 REML, selection step 0.025; 1e-9 closed form, 1e-6 iterative |
| Fisher-scoring defaults | Static source-backed algorithm constants | Installed rma.uni: HE start, threshold 1e-5, maxiter 100, step halving, ll0check |
| App estimates and pass counts | Dynamic | Actual Chrome runs, unchanged compare.py; no expected answers in patched code |
| Selection bounds | Static source-backed constraint | delta in [0,100], delta1 fixed to one |
| Dataset display labels | Static metadata | No clinical identifiers added or changed |

Execution and comparison

The unchanged scripts/run-app.cjs loads the app's own files and exposes existing closed-over functions using a debugger breakpoint. No extracted or reimplemented audit engine substitutes for the shipped code. For the same-corpus primary comparison, rows contain te and sqrt(vi), and the page squares SE. Numeric errors are |app-R|/max(1,|R|), except absolute errors for p-values. Side uses exact equality. No tolerance was widened. Refusals count at method level; a reference timeout is never a successful matched refusal.

| Quantity | Original pass/checks | Patched2 pass/checks | Original max difference | Patched2 max difference | Tolerance |
|---|---:|---:|---:|---:|---:|
| begg.p | 0/152 | 151/152 | 0.39849189195372992 | 0.00016333806733537237 | 1e-09 |
| begg.tau | 140/152 | 151/152 | 0.018794596974297278 | 3.6453158183055723e-06 | 1e-09 |
| egger_lm.b0 | 151/151 | 151/151 | 4.072473933436057e-14 | 4.072473933436057e-14 | 1e-09 |
| egger_lm.limit | 151/151 | 151/151 | 8.7216400483994969e-15 | 8.7216400483994969e-15 | 1e-09 |
| egger_lm.p | 151/151 | 151/151 | 2.5844409945463553e-11 | 2.5844409945463553e-11 | 1e-09 |
| egger_lm.refusal | 0/1 | 0/1 | 0 | 0 | 0 |
| egger_lm.statistic | 151/151 | 151/151 | 7.7889706747075245e-14 | 7.7889706747075245e-14 | 1e-09 |
| harbord.p | 54/112 | 112/112 | 0.61798691733069011 | 8.5991908038707265e-12 | 1e-09 |
| harbord.refusal | 0/2 | 1/2 | 0 | 0 | 0 |
| harbord.statistic | 54/112 | 112/112 | 2.4480132348964307 | 9.0558170732867308e-15 | 1e-09 |
| peters.p | 54/112 | 112/112 | 0.8094917535511571 | 1.0790590643239284e-11 | 1e-09 |
| peters.refusal | 0/2 | 1/2 | 0 | 0 | 0 |
| peters.statistic | 54/112 | 112/112 | 0.98107073828193536 | 6.4392935428259079e-15 | 1e-09 |
| selection.LRT | 33/137 | 33/137 | 0.64819362941950753 | 0.49036056517549448 | 1e-06 |
| selection.LRTp | 40/137 | 40/137 | 0.23638652389984977 | 0.095141309918707895 | 1e-06 |
| selection.delta | 19/137 | 19/137 | 43166194373815.508 | 99.199984961973499 | 1e-06 |
| selection.mu | 30/137 | 35/137 | 0.27389710922728472 | 0.1189406447128233 | 1e-06 |
| selection.refusal | 8/15 | 8/15 | 0 | 0 | 0 |
| selection.se | 27/137 | 40/137 | 0.29519638237777751 | 0.29519636786145337 | 1e-06 |
| selection.tau2 | 52/137 | 53/137 | 0.045368980299833037 | 0.026180530820619545 | 1e-06 |
| trimfill.est | 136/150 | 150/150 | 5.7498737888237936e-05 | 2.7258445855582714e-15 | 1e-06 |
| trimfill.k0 | 150/150 | 150/150 | 0 | 0 | 1e-09 |
| trimfill.refusal | 0/2 | 1/2 | 0 | 0 | 0 |
| trimfill.se | 124/150 | 150/150 | 5.5217907173913013e-05 | 6.2633099198509302e-16 | 1e-06 |
| trimfill.side | 150/150 | 150/150 | 0 | 0 | 1e-09 |
| trimfill.tau2 | 103/150 | 150/150 | 1.5780829431528628e-05 | 2.0434614306219076e-15 | 1e-06 |

Failure causes and final proposed changes

- `patched2/pubbias-tests/index.html:482`: replaces the intercept-only golden-section REML with the algebraic O(k) form of metafor's default Fisher-scoring update: (y'P²y-tr(P))/tr(P²). Uses HE initialization, 1e-5 absolute tau²-change stopping threshold, 100-iteration cap, zero-boundary step halving, and metafor's ll0check tolerance eps^0.25. Single-study trimmed subsets have tau²=0. The full unaugmented REML fit is checked before trimming so its convergence failure is not silently ignored. The REML side-regression implementation is unchanged and matches all 150 comparable sides; this is not a claim of a general replacement for metafor meta-regression.
- Trim-and-fill has one matched convergence refusal (Baker Placebo:Salmeterol) and one unavailable reference (McCurdy, prior R call exceeded 120 seconds). Its numeric 150/150 results do not count the timeout as validation. Maximum estimate/SE/tau² discrepancies are around 1e-15.
- Begg retains the exact inversion distribution for untied ranks, joint tie correction, exact floating-point tie groups and accurate normal tails from fix.patch. McCurdy remains the sole failure: vi -> sqrt(vi) -> SE² changes exact ties. The unchanged harness cannot recover information discarded by that conversion. The prior targeted-diagnostics.json demonstrates agreement when R is given the same squared-SE values; this diagnostic does not replace the original reference or count as 152/152.
- Peters and Harbord retain raw counts for their regression/score statistics; the continuity correction is restricted to effect/variance derivation. Noninformative double-zero/double-all-event rows are filtered. Each method retains one unmatched reference refusal for Baker: R failed while fitting its parent REML model, while the direct closed-form app test returns a number. Egger's sole refusal mismatch has the same cause. No unrelated parent-model gate was added to these closed-form engine functions merely to raise audit counts.
- `patched2/pubbias-tests/index.html:577`: a failed analysis clears the previously exportable result and shows the actual error. This is verified after a successful prior analysis, using Baker's actual REML nonconvergence.
- `patched2/pubbias-tests/index.html:628`: selection is labeled ML with the exact warning **experimental, not validated against metafor**, also present in the footer. The `method:'REML'` option remains only for starting values, as in the unchanged audit harness; the fitted likelihood and null LRT are ML. The shared selection file keeps the prior 0–100 delta-bound correction, removes its parity claim and explicitly documents the experimental status. The existing approximate optimiser and Hessian remain a limitation.
- `patched2/pubbias-tests/index.html:640`: exports `egger_t`; keeps `egger_z` as a documented deprecated compatibility alias for the same t statistic. Footer wording now calls it a t statistic. Blanket R-parity claims and fixture-derived numbers were removed from the page introduction/footer.

Selection attempt (archived; not shipped in fix2.patch)

The real implementation attempt is selection-attempt2.js, produced by scripts/attempt-selection2.py and executed on the full corpus in app-selection-attempt2.json. It replaced the normal approximation with an incomplete-gamma CDF, refined the normal quantile, aligned the p-interval endpoint rule, retained 0–100 logistic bounds, tried three deterministic Nelder-Mead starts with restarts, and used a natural-parameter Richardson Hessian that excludes near-zero tau²/delta parameters. Installed metafor uses BFGS by default, tau2tol=min(vi/10,1e-4), natural-parameter numDeriv Hessians, and delta starts 1,0.8. The attempted Hessian follows that boundary treatment but is not an exact port of numDeriv. The LRT attempt uses max(0,2*(ll_selection-ll_nullML)). It did not achieve parity and was therefore withdrawn from the final patch; the minimal experimental fallback was used instead. No claim that this attempt reproduces metafor's optimiser path or Hessian is made.

| Selection quantity | Original | Numerical attempt | Final patched2 |
|---|---:|---:|---:|
| selection.LRT | 33/137 | 43/137 | 33/137 |
| selection.LRTp | 40/137 | 41/137 | 40/137 |
| selection.delta | 19/137 | 22/137 | 19/137 |
| selection.mu | 30/137 | 38/137 | 35/137 |
| selection.refusal | 8/15 | 8/15 | 8/15 |
| selection.se | 27/137 | 29/137 | 40/137 |
| selection.tau2 | 52/137 | 53/137 | 53/137 |

The attempt's complete ledger is comparison-selection-attempt2.json; it includes the first Fisher-scoring revision's single-study refusal, subsequently fixed in final patched2. Comparing its overall denominator directly to final patched2 would be misleading. Selection-specific denominators are unchanged. Remaining discrepancies include optimiser/boundary solutions, unidentified interval weights, SEs, and unmatched R optimiser refusals.

Existing tests and UI verification

The requested Playwright files were copied from allmeta: trimfill-parity, selmodel-parity, and pubbias-binary-parity. Their assertions and tolerances are unchanged. The repository config normally serves localhost:8088; the common task explicitly requires Chrome and file URLs with no server, so the local test copies replace only the URL prefix and use playwright.file.config.mjs. Chrome's --allow-file-access-from-files enables the actual local glossary fetch. Missing local CSS/glossary assets were copied from source. The first run had 3 passes/2 failures due solely to missing CSS and file-origin CORS; all numeric assertions had already passed. After fixing the test transport, all 5 tests pass. The trimfill spec tests shared/trimfill.js on funnel-plot with FE/DL, not this page's inline REML; the full-corpus comparison is the evidence for the latter. The single selection fixture's looser checks do not establish full-corpus parity.

The unchanged pubbias-tests/tests/test_against_metafor.py was run with python -m pytest. Its hard-coded R-4.5.2 executable is absent; its own existing fallback finds R-4.6.0. No test or R-path edits were made. Ten Python tests pass; nine R-dependent tests fail because pb-tiny.R requires jsonlite, which is absent from the supplied R library. No packages were installed. The fixture tests compare pinned R results and mirrored Python formulas, not a new full browser corpus run. pytest2.log retains the complete failures. The log-capture helper initially hit a Windows console-encoding error after saving the log; that helper is now UTF-8 and the saved pytest summary is intact.

ui-smoke2 checks the experimental warning, Egger t compatibility alias, k=3 refusal, k=5 results, clearing stale results after REML refusal, and visible refusal text: 6/6 pass.

Coverage boundary: the fixed original corpus/harness compares Egger, Begg, trim-and-fill, selection, Peters and Harbord. It does not compare the displayed Thompson-Sharp variant or every plotting/export behavior. No claim of parity for everything displayed on the page is made. Selection uses the explicitly authorized experimental fallback.

Exact commands run for final artifacts (working directory: this job folder)

```powershell
$env:R_LIBS_USER='<R_LIBS_USER>'
Rscript scripts/inspect2.R
python scripts/build2.py
node scripts/run-app.cjs patched2 app-patched2-first.json
python compare.py app-patched2-first.json comparison-patched2-first.json
python scripts/attempt-selection2.py
node scripts/run-app.cjs patched2 app-selection-attempt2.json
python compare.py app-selection-attempt2.json comparison-selection-attempt2.json
python scripts/finalize2.py
python scripts/run2.py app-original2.log node scripts/run-app.cjs original app-original2.json
python scripts/run2.py app-patched2.log node scripts/run-app.cjs patched2 app-patched2.json
python scripts/run2.py compare-original2.log python compare.py app-original2.json comparison-original2.json
python scripts/run2.py compare-patched2.log python compare.py app-patched2.json comparison-patched2.json
python scripts/run2.py playwright2.log node patched2/hub/shared/tests/node_modules/@playwright/test/cli.js test --config patched2/hub/shared/tests/playwright.file.config.mjs trimfill-parity.spec.mjs selmodel-parity.spec.mjs pubbias-binary-parity.spec.mjs
python scripts/run2.py pytest2.log python -m pytest patched2/pubbias-tests/tests/test_against_metafor.py -q -p no:cacheprovider
python scripts/test-assets2.py
python scripts/run2.py playwright2-final.log node patched2/hub/shared/tests/node_modules/@playwright/test/cli.js test --config patched2/hub/shared/tests/playwright.file.config.mjs trimfill-parity.spec.mjs selmodel-parity.spec.mjs pubbias-binary-parity.spec.mjs
python scripts/run2.py ui-smoke2.log node scripts/ui-smoke2.cjs
python scripts/run2.py patch-check2.log python scripts/package2.py
python scripts/report2.py
```

The first/attempt browser command output was captured in app-patched2-first.log and app-selection-attempt2.log. The packaging script executes plain `git -C C:/Projects/allmeta-work apply --check <absolute-job-path>/fix2.patch`; no whitespace-ignore flag is needed. It preserves the source's CRLF line endings in the proposed files and writes UTF-8 without BOM. Test transport changes, copied test dependencies, and audit scripts are not in fix2.patch: it changes only pubbias-tests/index.html and shared/selmodel.js.

Verbatim final console lines

`app-original2.log`

```text
APP COMPLETE: 152 configurations
```

`app-patched2.log`

```text
APP COMPLETE: 152 configurations
```

`compare-original2.log`

```text
egger_lm.statistic: 151/151 pass; max difference=7.7889706747075245e-14; tolerance=1e-09
egger_lm.p: 151/151 pass; max difference=2.5844409945463553e-11; tolerance=1e-09
egger_lm.b0: 151/151 pass; max difference=4.072473933436057e-14; tolerance=1e-09
egger_lm.limit: 151/151 pass; max difference=8.7216400483994969e-15; tolerance=1e-09
begg.tau: 140/152 pass; max difference=0.018794596974297278; tolerance=1e-09
begg.p: 0/152 pass; max difference=0.39849189195372992; tolerance=1e-09
trimfill.k0: 150/150 pass; max difference=0; tolerance=1e-09
trimfill.side: 150/150 pass; max difference=0; tolerance=1e-09
trimfill.est: 136/150 pass; max difference=5.7498737888237936e-05; tolerance=1e-06
trimfill.se: 124/150 pass; max difference=5.5217907173913013e-05; tolerance=1e-06
trimfill.tau2: 103/150 pass; max difference=1.5780829431528628e-05; tolerance=1e-06
selection.mu: 30/137 pass; max difference=0.27389710922728472; tolerance=1e-06
selection.se: 27/137 pass; max difference=0.29519638237777751; tolerance=1e-06
selection.tau2: 52/137 pass; max difference=0.045368980299833037; tolerance=1e-06
selection.delta: 19/137 pass; max difference=43166194373815.508; tolerance=1e-06
selection.LRT: 33/137 pass; max difference=0.64819362941950753; tolerance=1e-06
selection.LRTp: 40/137 pass; max difference=0.23638652389984977; tolerance=1e-06
peters.statistic: 54/112 pass; max difference=0.98107073828193536; tolerance=1e-09
peters.p: 54/112 pass; max difference=0.8094917535511571; tolerance=1e-09
harbord.statistic: 54/112 pass; max difference=2.4480132348964307; tolerance=1e-09
harbord.p: 54/112 pass; max difference=0.61798691733069011; tolerance=1e-09
selection.refusal: 8/15 pass; max difference=0; tolerance=0
egger_lm.refusal: 0/1 pass; max difference=0; tolerance=0
trimfill.refusal: 0/2 pass; max difference=0; tolerance=0
peters.refusal: 0/2 pass; max difference=0; tolerance=0
harbord.refusal: 0/2 pass; max difference=0; tolerance=0
1832/2950 checks pass
```

`compare-patched2.log`

```text
egger_lm.statistic: 151/151 pass; max difference=7.7889706747075245e-14; tolerance=1e-09
egger_lm.p: 151/151 pass; max difference=2.5844409945463553e-11; tolerance=1e-09
egger_lm.b0: 151/151 pass; max difference=4.072473933436057e-14; tolerance=1e-09
egger_lm.limit: 151/151 pass; max difference=8.7216400483994969e-15; tolerance=1e-09
begg.tau: 151/152 pass; max difference=3.6453158183055723e-06; tolerance=1e-09
begg.p: 151/152 pass; max difference=0.00016333806733537237; tolerance=1e-09
trimfill.k0: 150/150 pass; max difference=0; tolerance=1e-09
trimfill.side: 150/150 pass; max difference=0; tolerance=1e-09
trimfill.est: 150/150 pass; max difference=2.7258445855582714e-15; tolerance=1e-06
trimfill.se: 150/150 pass; max difference=6.2633099198509302e-16; tolerance=1e-06
trimfill.tau2: 150/150 pass; max difference=2.0434614306219076e-15; tolerance=1e-06
selection.mu: 35/137 pass; max difference=0.1189406447128233; tolerance=1e-06
selection.se: 40/137 pass; max difference=0.29519636786145337; tolerance=1e-06
selection.tau2: 53/137 pass; max difference=0.026180530820619545; tolerance=1e-06
selection.delta: 19/137 pass; max difference=99.199984961973499; tolerance=1e-06
selection.LRT: 33/137 pass; max difference=0.49036056517549448; tolerance=1e-06
selection.LRTp: 40/137 pass; max difference=0.095141309918707895; tolerance=1e-06
peters.statistic: 112/112 pass; max difference=6.4392935428259079e-15; tolerance=1e-09
peters.p: 112/112 pass; max difference=1.0790590643239284e-11; tolerance=1e-09
harbord.statistic: 112/112 pass; max difference=9.0558170732867308e-15; tolerance=1e-09
harbord.p: 112/112 pass; max difference=8.5991908038707265e-12; tolerance=1e-09
selection.refusal: 8/15 pass; max difference=0; tolerance=0
egger_lm.refusal: 0/1 pass; max difference=0; tolerance=0
trimfill.refusal: 1/2 pass; max difference=0; tolerance=0
peters.refusal: 1/2 pass; max difference=0; tolerance=0
harbord.refusal: 1/2 pass; max difference=0; tolerance=0
2335/2950 checks pass
```

`playwright2-final.log`

```text
  5 passed (48.3s)
```

`pytest2.log`

```text
9 failed, 10 passed in 43.56s
```

`ui-smoke2.log`

```text
UI SMOKE2: 6/6 checks pass
```

`patch-check2.log`

```text
PATCH CHECK: git apply --check passed against read-only allmeta; 2 files; source bytes unchanged
ENCODING CHECK: patch UTF-8 without BOM; source CRLF preserved
```

Dataset disposition (all enumerated candidates; unchanged)


| Dataset | Status | Configurations | Reason |
|---|---|---:|---|
| dat.aloe2013 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.anand1999 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.anker2025 | used | 4 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.assink2016 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.axfors2021 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.bakdash2021 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.baker2009 | used | 9 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.bangertdrowns2004 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.bartos2023 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.baskerville2012 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.bassler2004 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.bauer2002 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.bcg | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.begg1989 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.berkey1998 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.berkey1998r | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.besson2016 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.bonett2010 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.bornmann2007 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.bourassa1996 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.cannon2006 | used | 6 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.chiarito2020 | used | 4 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.cohen1981 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.colditz1994 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.collins1985a | used | 3 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.collins1985b | used | 4 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.craft2003 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.crede2010 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.crisafulli2020 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.curtin2002 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.curtis1998 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.dagostino1998 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.damico2009 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.debruin2009 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.demir2022 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.dogliotti2014 | used | 3 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.dong2013 | used | 7 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.dorn2007 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.dumouchel1994 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.egger2001 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.feng2019 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.fine1993 | used | 4 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.franchini2012 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.frank2008 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.furukawa2003 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.gibson2002 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.graves2010 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.greb2008 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.greenland1992 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.gurusamy2011 | used | 3 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.hackshaw1998 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.hahn2001 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.hannum2020 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.hart1999 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.hartmannboyce2018 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.hasselblad1998 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.higgins2008 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.hine1989 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.huber2000 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.ishak2007 | used | 4 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.kalaian1996 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.karner2014 | used | 8 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.kearon1998 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.knapp2017 | used | 2 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.konstantopoulos2011 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.landenberger2005 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.laopaiboon2015 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.lau1992 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.lee2004 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.lehmann2018 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.li2007 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.lim2014 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.linde2005 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.linde2015 | used | 10 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.linde2016 | used | 15 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.lloyd2010 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.lopez2019 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.maire2019 | used | 3 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.mccurdy2020 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.mcdaniel1994 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.meeker2017 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.metap | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.michael2013 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.molloy2014 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.moore1998 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.moura2021 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.nakagawa2007 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.nielweise2007 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.nielweise2008 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.nissen2007 | used | 2 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.normand1999 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.obrien2003 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.pagliaro1992 | used | 2 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.pignon2000 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.poole2003 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.pritz1997 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.quan2000 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.raudenbush1985 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.riley2003 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.rivera2025 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.roever2022 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.senn2013 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.spooner2002 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.steurer2006 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.stowe2010 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.tannersmith2016 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.thompson1999 | used | 2 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.tian2009 | used | 2 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.ursino2021 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.vanhowe1999 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.viechtbauer2021 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.white2020 | excluded | 0 | no supplied effect/variance or supported paired binary structure with >=3 finite positive-variance rows |
| dat.woods2010 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |
| dat.yusuf1985 | used | 1 | usable effect/variance or binary contrasts; see corpus source fields |


The complete per-check ledgers are comparison-original2.json and comparison-patched2.json. results2.json consolidates both, the selection attempt, provenance and UI checks. Unresolved failures are recorded in STUCK_FAILURES.md. No CERTIFIED, submission-ready or shipped status is claimed.
