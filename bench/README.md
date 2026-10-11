# Benchmark provenance and rerun

`original/` preserves the actual historical scripts byte-for-byte, except that the local R library path is replaced by the placeholder `<R_LIBS_USER>` (set it to a library holding the package versions in the README). `run-app.cjs` differs from the original only in Playwright module resolution (`PLAYWRIGHT_MODULE` or the installed `playwright` package). No numerical engine is extracted or replaced. `compare.py` is the original comparator unchanged.

Historical reference construction used reference.R, supplement.R, bounded reference-one.R workers, the Kearon correction, and the independent large-case McCurdy attempt. Their merge/bounded scripts are retained for provenance; they are not a one-command portable pipeline. `rerun_reference.py` instead runs the same reference-one.R calculations on the archived final corpus and retries McCurdy methods independently with the original 120-second cap. R package versions must match the README. Timeout availability can change with hardware; a new run is not expected to preserve a timeout bit for bit.

Use an existing R installation with metafor/meta/metadat and dependencies, an existing Node/Playwright installation and Chrome. No installer or download is invoked. Set R_LIBS_USER and, if required, PLAYWRIGHT_MODULE to your already installed modules. From the repository root:

```text
python bench/rerun_reference.py --output rerun
node bench/run-app.cjs app rerun/app.json
python bench/compare_rerun.py
Rscript bench/hackshaw.R rerun/hackshaw-reml.json
```

The app runner expects corpus.json in its working directory; `compare_rerun.py` and the portable runner handle this by using the archived data corpus (see runner patch notes below). Full corpus execution can be slow because of experimental selection. R errors/unavailable methods are retained, not replaced with archived answers. Original reference-one.R computes egger_rma too; that is outside the five-method totals, as in the original comparison.

Portable runner patch notes: dependency resolution and corpus path are the only edits to the copied original runner. Its Chrome/CDP breakpoint exposes the page's own functions. `compare_rerun.py` calls the unchanged original comparator from rerun/ so reference.json resolves there. Rebuilding the publication uses archived results, not rerun/.

The archive task reran only Hackshaw's separate REML example, not the full R corpus or browser corpus. Historical source results and test limitations remain in results/RESULTS2.md. The abandoned selection attempt is excluded.
