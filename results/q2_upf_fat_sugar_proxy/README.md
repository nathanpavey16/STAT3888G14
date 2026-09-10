# Simple saturated/trans-fat and added-sugar proxy

The team's requested simple nutrient-based measure is:

```r
upf_nutrient_proxy_pct = SATPER1 + PEADDSD1
upf_nutrient_proxy_pct10 = upf_nutrient_proxy_pct / 10
```

It is the percentage of reported day-1 dietary energy supplied by saturated/trans
fats and added sugars, used as an **unvalidated UPF-related nutrient proxy**.
It is not the percentage of food, by weight or energy, classified as UPF. For
example, 15% from saturated/trans fats plus 10% from added sugars produces 25:
25% of energy from these nutrients, **not evidence that 25% of energy came from UPF**.

## Source and construction

Source: `data/raw/AHSnpa11bp.csv`, one row per person (`ABSPID`). The variable list is
`data/dictionaries/AHSnpaBasicCURFdataItemList.xlsx`, sheet `Risk factors - Nutrition`.

| Field | Meaning | Dictionary cells |
|---|---|---|
| `SATPER1` | Day-1 energy percentage from saturated fat and trans fatty acids | A183:C184 |
| `PEADDSD1` | Day-1 energy percentage from added sugars (FSANZ definition) | A219:C220 |
| `ENERGYF1` | Reported day-1 food energy, used to check the denominator is positive | See variable list |

Both components use the same dietary-energy denominator. Trans fat is already
included in `SATPER1`; do not add `TRANPER1`. Free sugar overlaps with added sugar;
do not also add `PEFRESD1`. Sodium has no energy and cannot be added to these
percentages. No basal metabolic rate adjustment is needed. The sum is a
researcher-chosen measure, not a validated equation predicting true UPF intake.

All source participants and their original values are retained. A missing,
non-finite or non-positive energy denominator, a missing/invalid component outside
0-100, or a combined percentage outside 0-100 produces a missing proxy and a
recorded reason. No imputation, clipping, row removal or raw-data changes occur.
`sat_trans_added_sugar_energy_pct` is an identical alias with a literal name.

## Files and use

From the repository root:

```r
source("scripts/build_q2_upf_fat_sugar_proxy.R")
proxy <- build_q2_fat_sugar_proxy()
# Or load the existing output:
proxy <- readRDS("data/derived/q2_upf_fat_sugar_proxy.rds")

# Join to a person-level Q2 table that also has a unique ABSPID:
# q2 <- dplyr::left_join(q2, proxy[c("ABSPID", "upf_nutrient_proxy_pct",
#   "upf_nutrient_proxy_pct10")], by = "ABSPID", relationship = "one-to-one")
```

Matching RDS and CSV outputs are in `data/derived/` and are Git-ignored. This folder
contains unweighted descriptive summaries, availability counts and construction
checks. `pct10` permits reporting associations per 10-percentage-point increase
in this nutrient share, not per 10% relative increase or per 10 points of true UPF.

The adult summary uses ages 18-64; males and females with `FEMLSBC` in 1,3,4,5,6
are retained. It is not a complete-case vitamin D/obesity analysis sample.

## Interpretation for the report

Suggested wording: "We used the combined percentage of energy from saturated/trans
fats and added sugars as an exploratory UPF-related nutrient proxy. This measure
does not directly classify foods by processing level or estimate total UPF energy
share."

Non-UPF foods can supply these nutrients, and UPF also supplies energy from other
nutrients. The proxy can misclassify diets in either direction; a single day's
intake does not represent usual intake. Observed associations should therefore
be described as associations with this nutrient profile, not UPF-specific effects.

The dedicated Q2 report now uses this construction function directly. Superseded
food-description and high-fat discretionary-food proxies were moved out of the
working repository; see the project cleanup notes for recovery details.
