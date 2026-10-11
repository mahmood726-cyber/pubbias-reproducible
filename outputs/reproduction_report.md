# Reproduction report

All calculations read results/ only; expected values are assertions, never inputs to findings.

| Claim | Expected | Reproduced | Verdict |
|---|---|---|---|
| datasets_enumerated | 114 | 114 | PASS |
| datasets_used | 75 | 75 | PASS |
| datasets_excluded | 39 | 39 | PASS |
| configurations | 152 | 152 | PASS |
| binary_configurations | 114 | 114 | PASS |
| below_page_minimum | 25 | 25 | PASS |
| checks | 2113 | 2113 | PASS |
| passed | 2107 | 2107 | PASS |
| failures | 6 | 6 | PASS |
| numeric_failures | 2 | 2 | PASS |
| failed_refusals | 4 | 4 | PASS |
| unmatched_R_refusals | 3 | 3 | PASS |
| unavailable_references | 1 | 1 | PASS |
| validated_methods | 5 | 5 | PASS |
| egger_lm_configurations | 151 | 151 | PASS |
| egger_lm_passed | 151 | 151 | PASS |
| begg_configurations | 152 | 152 | PASS |
| begg_passed | 151 | 151 | PASS |
| trimfill_configurations | 150 | 150 | PASS |
| trimfill_passed | 150 | 150 | PASS |
| peters_configurations | 112 | 112 | PASS |
| peters_passed | 112 | 112 | PASS |
| harbord_configurations | 112 | 112 | PASS |
| harbord_passed | 112 | 112 | PASS |
| selection_mu_before_passed | 30 | 30 | PASS |
| selection_mu_before_checks | 137 | 137 | PASS |
| selection_mu_after_passed | 35 | 35 | PASS |
| selection_mu_after_checks | 137 | 137 | PASS |
| hackshaw_k | 37 | 37 | PASS |
| hackshaw_trimfill_k0 | 7 | 7 | PASS |
| hackshaw_trimfill_side | left | left | PASS |
| egger_lm_max | 2.6e-11 | 2.6e-11 | PASS |
| trimfill_max | 2.7e-15 | 2.7e-15 | PASS |
| trimfill_prefix_max | 5.7e-05 | 5.7e-05 | PASS |
| hackshaw_egger_lm_statistic | 2.38 | 2.38 | PASS |
| hackshaw_egger_lm_p | 0.023 | 0.023 | PASS |
| hackshaw_begg_tau | 0.144 | 0.144 | PASS |
| hackshaw_begg_p | 0.216 | 0.216 | PASS |
| hackshaw_adjusted_OR | 1.19 | 1.19 | PASS |
| hackshaw_adjusted_lower | 1.08 | 1.08 | PASS |
| hackshaw_adjusted_upper | 1.31 | 1.31 | PASS |
| hackshaw_unadjusted_OR | 1.244694 | 1.244694 | PASS |
| hackshaw_unadjusted_lower | 1.12984 | 1.12984 | PASS |
| hackshaw_unadjusted_upper | 1.371224 | 1.371224 | PASS |
| hackshaw_unadjusted_OR_display | 1.24 | 1.24 | PASS |
| hackshaw_max | 1e-11 | 1.1781513264974564e-12 | PASS |
| begg_roundtrip_max | 1e-09 | 1.3766765505351941e-14 | PASS |
| version_R | R version 4.6.0 (2026-04-24 ucrt) | R version 4.6.0 (2026-04-24 ucrt) | PASS |
| version_metafor | 5.2.1 | 5.2.1 | PASS |
| version_meta | 8.5.0 | 8.5.0 | PASS |
| version_metadat | 1.6.0 | 1.6.0 | PASS |
| allmeta_commit | 3dcc679 | 3dcc679 | PASS |
| closed_form_tolerance | 1e-09 | 1e-09 | PASS |
| iterative_tolerance | 1e-06 | 1e-06 | PASS |
| continuity_correction | 0.5 | 0.5 | PASS |
| corpus_minimum_k | 3 | 3 | PASS |
| page_minimum_k | 5 | 5 | PASS |
| reference_timeout_seconds | 120 | 120 | PASS |
| CI_percent | 95 | 95 | PASS |
| selection_step | 0.025 | 0.025 | PASS |
| trimfill_estimator | L0 | L0 | PASS |

Selection is EXCLUDED from both tables and the agreement figure; experimental, not validated. Thompson–Sharp was not compared. Refusal differences are not numeric and are blank in Table 1. Figures use 300 dpi, 170 mm nominal width, and text of at least 8 pt. Exact zeros and sub-1e-16 differences are plotted at −16. One scalar difference exists per configuration and quantity, so it is also that quantity's largest difference. The four nonnumeric failures are in Table 2.

The archive verifies numerical paper claims, versions and protocol constants. List numbering, citation markers, reference bibliographic years/page numbers, and PR identifiers are not experimental findings. Source documentation of the run is retained for inspection; the manuscript is published separately. No network, full R corpus rerun, or full browser rerun is implied by this reproduction.


PASS: 61/61 paper-value assertions; 2107/2113 non-selection checks pass; 6 exceptions.
