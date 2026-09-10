# Day-1 selected-nutrient energy share: a simple, unvalidated UPF-related proxy.
# This is NOT the percentage of total food energy coming from UPF.
# Run from the repository root: Rscript scripts/build_q2_upf_fat_sugar_proxy.R

construct_q2_fat_sugar_proxy <- function(person) {
  required <- c("ABSPID", "ENERGYF1", "SATPER1", "PEADDSD1")
  stopifnot(all(required %in% names(person)),
            !anyNA(person$ABSPID), !anyDuplicated(person$ABSPID))
  x <- as.data.frame(person)[, required, drop = FALSE]
  stopifnot(all(vapply(x[required[-1]], is.numeric, logical(1))))
  valid_energy <- is.finite(x$ENERGYF1) & x$ENERGYF1 > 0
  valid_sat <- is.finite(x$SATPER1) & x$SATPER1 >= 0 & x$SATPER1 <= 100
  valid_sugar <- is.finite(x$PEADDSD1) & x$PEADDSD1 >= 0 & x$PEADDSD1 <= 100
  combined <- x$SATPER1 + x$PEADDSD1
  valid_sum <- is.finite(combined) & combined >= 0 & combined <= 100
  valid <- valid_energy & valid_sat & valid_sugar & valid_sum

  # SATPER1 already contains trans fat. Do NOT add TRANPER1 again.
  # PEADDSD1 is added sugar, not total sugar or free sugar.
  x$sat_trans_added_sugar_energy_pct <- ifelse(valid, combined, NA_real_)
  x$upf_nutrient_proxy_pct <- x$sat_trans_added_sugar_energy_pct
  x$upf_nutrient_proxy_pct10 <- x$upf_nutrient_proxy_pct / 10
  x$recall_day <- 1L
  x$proxy_status <- ifelse(!valid_energy, "Missing, non-finite or non-positive energy",
    ifelse(!valid_sat, "Invalid or missing saturated/trans-fat percentage",
    ifelse(!valid_sugar, "Invalid or missing added-sugar percentage",
    ifelse(!valid_sum, "Combined percentage outside 0-100", "Available"))))
  stopifnot(nrow(x) == nrow(person), identical(x$ABSPID, person$ABSPID),
            identical(x$upf_nutrient_proxy_pct, x$sat_trans_added_sugar_energy_pct),
            all(!is.na(x$upf_nutrient_proxy_pct) == (x$proxy_status == "Available")))
  x
}

test_q2_fat_sugar_proxy <- function() {
  synthetic <- data.frame(
    ABSPID = paste0("test", 1:10),
    ENERGYF1 = c(8000, 8000, 8000, 0, 8000, 8000, 8000, 8000, NA, Inf),
    SATPER1 = c(15, 100, 0, 0, NA, 80, -1, 15, 15, 15),
    PEADDSD1 = c(10, 0, 0, 0, 10, 30, 10, Inf, 10, 10),
    TRANPER1 = 1, PEFRESD1 = 20)
  z <- construct_q2_fat_sugar_proxy(synthetic)
  stopifnot(identical(z$upf_nutrient_proxy_pct,
                      c(25, 100, 0, rep(NA_real_, 7))),
            z$upf_nutrient_proxy_pct10[1] == 2.5,
            identical(z$ABSPID, synthetic$ABSPID))
  duplicate <- synthetic[c(1, 1), ]
  stopifnot(inherits(try(construct_q2_fat_sugar_proxy(duplicate), silent = TRUE),
                     "try-error"))
  invisible(TRUE)
}

build_q2_fat_sugar_proxy <- function(root = ".") {
  if (!requireNamespace("data.table", quietly = TRUE)) stop("Install data.table first.")
  test_q2_fat_sugar_proxy()
  root <- normalizePath(root, mustWork = TRUE)
  source_path <- file.path(root, "data/raw/AHSnpa11bp.csv")
  checksum_before <- unname(tools::md5sum(source_path))
  required <- c("ABSPID", "ENERGYF1", "SATPER1", "PEADDSD1", "AGEC", "SEX", "FEMLSBC")
  person <- data.table::fread(source_path, select = required, data.table = FALSE)
  x <- construct_q2_fat_sugar_proxy(person)
  available <- !is.na(x$upf_nutrient_proxy_pct)
  stopifnot(all(x$upf_nutrient_proxy_pct[available] ==
                  person$SATPER1[available] + person$PEADDSD1[available]))

  attr(x, "proxy_definition") <- list(
    formula = "SATPER1 + PEADDSD1",
    interpretation = paste("Percentage of reported day-1 dietary energy from",
      "saturated/trans fats plus added sugars; an unvalidated UPF-related proxy.",
      "NOT an estimate calibrated to total UPF energy share."),
    units = "Percentage points on a 0-100 scale; pct10 is divided by 10.",
    recall = "Day 1 only; not usual long-term consumption.",
    denominator = "Reported dietary energy, not basal metabolic rate.",
    cleaning = paste("Retain every person and source values. Derive NA if energy is",
      "missing/non-finite/non-positive, either percentage is missing/non-finite/outside",
      "0-100, or their sum exceeds 100. No clipping or imputation."),
    dictionary = paste("AHSnpaBasicCURFdataItemList.xlsx, Risk factors - Nutrition:",
      "SATPER1 A183:C184; PEADDSD1 A219:C220."),
    source = "data/raw/AHSnpa11bp.csv",
    source_md5 = checksum_before,
    version = "1.0")

  derived <- file.path(root, "data/derived")
  results <- file.path(root, "results/q2_upf_fat_sugar_proxy")
  dir.create(derived, recursive = TRUE, showWarnings = FALSE)
  dir.create(results, recursive = TRUE, showWarnings = FALSE)
  rds_path <- file.path(derived, "q2_upf_fat_sugar_proxy.rds")
  csv_path <- file.path(derived, "q2_upf_fat_sugar_proxy.csv")
  saveRDS(x, rds_path)
  data.table::fwrite(x, csv_path, na = "NA")
  stopifnot(identical(x, readRDS(rds_path)))
  csv_check <- data.table::fread(csv_path, data.table = FALSE, na.strings = "NA")
  stopifnot(identical(names(x), names(csv_check)), nrow(x) == nrow(csv_check),
            identical(as.character(x$ABSPID), as.character(csv_check$ABSPID)),
            isTRUE(all.equal(x$upf_nutrient_proxy_pct, csv_check$upf_nutrient_proxy_pct,
                             check.attributes = FALSE, tolerance = 1e-12)))

  # These are unweighted descriptive summaries, not population estimates.
  adult_nonpregnant <- person$AGEC %in% 18:64 &
    (person$SEX %in% 1 | (person$SEX %in% 2 & person$FEMLSBC %in% c(1, 3:6)))
  summarize <- function(keep, label) {
    value <- x$upf_nutrient_proxy_pct[keep]
    valid <- value[!is.na(value)]
    q <- if (length(valid)) as.numeric(quantile(valid, c(0, .25, .5, .75, 1))) else rep(NA_real_, 5)
    data.frame(group = label, n_retained = length(value), n_available = length(valid),
      n_missing = sum(is.na(value)), mean_pct = if(length(valid)) mean(valid) else NA_real_,
      sd_pct = if(length(valid) > 1) sd(valid) else NA_real_,
      min_pct = q[1], q1_pct = q[2], median_pct = q[3], q3_pct = q[4], max_pct = q[5])
  }
  summary <- rbind(summarize(rep(TRUE, nrow(x)), "All source participants"),
                   summarize(adult_nonpregnant, "Non-pregnant adults aged 18-64"))
  data.table::fwrite(summary, file.path(results, "distribution_summary.csv"))
  availability <- as.data.frame(table(x$proxy_status), stringsAsFactors = FALSE)
  names(availability) <- c("proxy_status", "n")
  data.table::fwrite(availability, file.path(results, "availability.csv"))
  checksum_after <- unname(tools::md5sum(source_path))
  stopifnot(!is.na(checksum_before), identical(checksum_before, checksum_after))
  audit <- data.frame(check = c("source_rows", "output_rows", "duplicate_output_ids",
    "id_order_preserved", "available_proxy", "missing_proxy", "zero_energy_source_rows",
    "positive_energy_but_invalid_proxy", "source_md5_before", "source_md5_after",
    "synthetic_tests", "rds_round_trip", "csv_round_trip"), value = as.character(c(
      nrow(person), nrow(x), sum(duplicated(x$ABSPID)), identical(x$ABSPID, person$ABSPID),
      sum(available), sum(!available), sum(person$ENERGYF1 == 0, na.rm = TRUE),
      sum(is.finite(person$ENERGYF1) & person$ENERGYF1 > 0 & !available),
      checksum_before, checksum_after, "PASS", "PASS", "PASS")))
  data.table::fwrite(audit, file.path(results, "construction_checks.csv"))
  print(summary, row.names = FALSE)
  message("Saved ", nrow(x), " participants; ", sum(available), " valid proxy values.")
  message("This builder does not render reports or modify raw data.")
  invisible(x)
}

if (sys.nframe() == 0L) build_q2_fat_sugar_proxy()
