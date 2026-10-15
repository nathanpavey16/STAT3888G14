# Run from the repository root. Optional arguments: q2 and/or q3.
required <- c("rmarkdown","data.table","dplyr","survey","mgcv","ranger","ggplot2","knitr")
missing <- setdiff(required,rownames(installed.packages()))
if(length(missing)) stop("Install these R packages first: ",paste(missing,collapse=", "))
if(packageVersion("dplyr") < "1.1.0") stop("dplyr >= 1.1.0 is required.")
if(!rmarkdown::pandoc_available()) stop("Install RStudio or Pandoc before rendering.")

reports <- c(q2="reports/q2_gam_rf_obesity_report.Rmd",
             q3="reports/q3_distress_nutrition_obesity_diabetes_report.Rmd")
requested <- commandArgs(trailingOnly=TRUE)
if(!length(requested)) requested <- names(reports)
if(any(!requested %in% names(reports))) stop("Valid report arguments: q2, q3.")
for(report in unname(reports[unique(requested)])) {
  if(!file.exists(report)) stop("Run from the repository root; missing: ",report)
  rmarkdown::render(report,envir=new.env(parent=globalenv()),quiet=TRUE)
  message("Rendered: ",sub("\\.Rmd$",".html",report))
}
