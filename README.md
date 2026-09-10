# STAT3888G14

## Reproduce

Install R and Pandoc (included with RStudio), then:

```r
install.packages(c("rmarkdown", "data.table", "dplyr", "survey", "ggplot2", "knitr"))
```

Open Rmd in RStudio and click Knit. Inputs resolve to ../data/raw from reports/. Exports go to results/; HTML files remain beside their Rmd sources.