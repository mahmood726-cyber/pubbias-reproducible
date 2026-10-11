# Small-study effects and publication bias tests in the browser: a tool validated against the R packages metafor and meta

Version 1.0.0 · Mahmood Ahmad · MIT (bundled third-party assets retain their notices).

This is a local, reproducible validation archive of the allmeta publication-bias page at **3dcc679**. R reference: **R 4.6.0, metafor 5.2-1, meta 8.5-0, metadat 1.6-0** (R serializes package versions with dots). Five methods contribute **2,107 passing checks of 2,113**: Egger, Begg, trim-and-fill, Peters and Harbord. Selection is **experimental, not validated** and excluded from these totals. Thompson–Sharp was not compared.

## Rebuild the paper outputs

With Python, matplotlib and Pillow already available, run from this directory:

```text
python analysis/make_outputs.py
```

The script reads only `results/` plus the independent assertions in `expected/paper_values.json`. It recomputes both final and pre-fix comparisons from raw app/R values, checks equality with the archived ledgers, creates tables and PNG/TIFF figures, records every measured paper claim in `numbers.json`, and exits nonzero on an assertion mismatch. No network or package installation is performed. `outputs/reproduction_report.md` contains each assertion's expected/reproduced value. Images have 300 dpi, nominal 170 mm width and text at least 8 pt. Selection is omitted from the agreement figure.

## Corpus and comparison contract

The installed metadat catalogue enumerated 114 datasets: 75 used and 39 excluded, yielding 152 configurations, 114 binary. The explicit mappings use supplied effects/variances, squared supplied SEs, or supported paired binary counts with at least three finite positive-variance rows. This is coverage under the archived mapping rule, not a claim that every possible transformation was attempted. Binary log odds ratios use `escalc(OR, add=0.5, to="only0", drop00=FALSE)`; Peters/Harbord use raw counts. Kearon's corrected false-positive count is `nn-tn`. Row indices and column mappings are preserved in the corpus and installed source documentation. Dataset names are source labels, not newly inferred study identifiers.

Numeric difference is `abs(app-R)/max(1,abs(R))`, except p-values use absolute difference. Closed-form tolerance is 1e-9; trim-and-fill est/se/tau2 use 1e-6. k0 uses 1e-9 and side uses exact equality. Both programs must refuse for a refusal check to pass; an unavailable reference never passes. Refusal rows are separate from numeric rows.

Egger passes every quantity on 151/151 numerically comparable configurations (max 2.6e-11); Begg 151/152; trim-and-fill 150/150 on all five quantities (max 2.7e-15); Peters and Harbord 112/112 each. These denominators exclude refusal checks. The six failures are Begg tau/p for McCurdy (SE round trip changes exact ties), three Baker Placebo:Salmeterol R parent-REML refusals while the app returns direct closed-form results, and an unavailable McCurdy trim-and-fill reference after a 120-second bounded attempt. The raw reference error says “exceeded 120 seconds or failed”; prior run narrative attributes it to timeout. The archive preserves that distinction instead of inferring more from an incomplete log. The independent McCurdy trim-and-fill attempt did finish, about 519 seconds after its script was written (file times), beyond the 120-second limit; `results/mccurdy-trimfill-late.json` records it. It agrees with the app (k0 122, side left, largest relative difference 4.4e-16) but is not counted, so the check remains a failure.

There are 25 configurations below the page's k=5 minimum; they ran through the engine and are not successful page analyses. Selection mu passes only 30/137 before and 35/137 after; those figures are retained as experimental evidence only. The historical trim-and-fill discrepancy reached 5.7e-5. Curated datasets are numerical stress tests, not new clinical findings. Plotting/export behavior and the whole allmeta hub are outside validation scope; navigation to unarchived sibling apps is not included.

## Contents and rerunning the engines

- `app/`: supplied runtime files copied byte-for-byte; `results/app-sha256.json` records SHA-256 values. Optional shared assets are included to retain runtime dependencies.
- `bench/`: original scripts actually used, portable launcher and frozen-corpus R orchestration. See [bench instructions](bench/README.md) for R → Chrome → compare commands.
- `data/`: corpus and exclusions. Identical copies in `results/` make output generation self-contained.
- `results/`: immutable final run artifacts, original app/comparison, source documentation, tie diagnostic and separately rerun Hackshaw REML output. The earlier `RESULTS2.md` describes patched2; the publication comparator is explicitly `comparison-merged-3dcc679.json`.
- `expected/`: paper claims independently transcribed from the supplied task/manuscript; never used to supply computed findings.
- `outputs/`: tables, figures, size metadata, full per-check ledger, number provenance and reproduction report.

The separate Hackshaw R run yields the unadjusted REML OR and CI in `results/hackshaw-reml.json`; these are not the app's unadjusted pooling. Adjusted OR/CI are exp(trimfill estimate ± normal 97.5% quantile × SE). Full precision is retained, with paper rounding checked separately. Numbered citations/list markers and bibliographic numbers are not statistical assertions; the manuscript is published separately.

## Static versus dynamic disclosure

| Component | Type | Evidence / transformation |
|---|---|---|
| Versions, commit, tolerances, 0.5 correction, minima, 120-second cap | Static protocol metadata | Archived R headers, runner, app and reference scripts; results/protocol.json |
| Paper targets | Static assertions | Supplied paper and task; expected/paper_values.json |
| Counts, differences, failures, tables and plotted points | Dynamic from archived measurements | Recomputed from raw app/reference JSON, cross-checked against ledgers |
| Hackshaw unadjusted example | Dynamic separate R run | bench/hackshaw.R → results/hackshaw-reml.json |
| Layout, labels, figure floor and colours | Static presentation | Template-derived; no fabricated research values |

No Git repository was initialized, and no push, deployment or certification is claimed. DOI 10.5281/zenodo.23288388 identifies allmeta v1.2.1 as supplied, not this archive; it was not checked online under the offline constraint.
