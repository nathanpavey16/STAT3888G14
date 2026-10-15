# STAT3888G14

## Reproduce

Install R and Pandoc (included with RStudio), then:

```r
install.packages(c("rmarkdown", "data.table", "dplyr", "survey", "mgcv",
                  "ranger", "ggplot2", "knitr"))
```

Open the Rmd in RStudio and click Knit, or run `Rscript render_reports.R q2`
from the repository root. Inputs resolve to `../data/raw` from `reports/`;
knitted HTML files remain beside their Rmd sources.

The consolidated Q2 Rmd includes all analysis code and does not require helper
scripts or cached results. Its two raw inputs are `AHSnpa11bp.csv` and
`AHSnpa11bb.csv`. Optional aggregate exports are disabled by default; set
`export_results: true` in its YAML parameters to write them to
`results/q2_gam_rf_outputs/`.

## Current reports

- Vitamin D, nutrient proxy and obesity: [HTML](reports/q2_gam_rf_obesity_report.html) · [Rmd source](reports/q2_gam_rf_obesity_report.Rmd)
- [Q3: Distress, nutrient proxy and obesity](reports/q3_distress_nutrition_obesity_diabetes_report.html)
