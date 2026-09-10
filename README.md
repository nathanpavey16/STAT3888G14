# STAT3888G14

## Reproduce

Install R and Pandoc (included with RStudio), then:

```r
install.packages(c("rmarkdown", "data.table", "dplyr", "survey", "ggplot2", "knitr"))
```

Open Rmd in RStudio and click Knit. Inputs resolve to ../data/raw from reports/. Exports go to results/; HTML files remain beside their Rmd sources.

## Current reports

- [Q2: Vitamin D, nutrient proxy and obesity](reports/q2_vitamin_d_obesity_diabetes_report.html)
- [Q3: Distress, nutrient proxy and obesity](reports/q3_distress_nutrition_obesity_diabetes_report.html)