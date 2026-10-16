# Q2 analysis – Week 9 & Week 10

**Vitamin D, UPF proxy, diabetes and obesity**

## Files

| File | Description |
|------|-------------|
| `Q2_VitD_UPF_Obesity_Week9_10.Rmd` | Full R Markdown analysis (open in RStudio and Knit) |
| `Q2_VitD_UPF_Obesity_Week9_10.html` | Knitted report with all results and figures |

## How to run

1. Put `AHSnpa11bp.csv` (person level) and `AHSnpa11bb.csv` (biomedical level) in the same folder as the `.Rmd`.
2. In RStudio: **Session → Set Working Directory → To Source File Location**, then click **Knit**.
3. Missing packages install automatically. All tables are also saved as CSV in `q2_outputs/`.

## Data and sample

- NNPAS 2011–12, adults aged 18–64, pregnant women excluded.
- **Obesity** = measured BMI ≥ 30
- **UPF proxy** = `SATPER1` + `PEADDSD1` (per 10% energy)
- **Vitamin D** = `VDLCMRGT`
- **Diabetes** = `DIABPRVE` (HbA1c)
- Vitamin D models: n = 2,617 (98 with diabetes); UPF-only model: n = 6,246.
- Survey-weighted logistic regression with the 60 ABS jackknife replicate weights.

## Week 9 – Models and significance (one section per person)

| Person | Model |
|--------|-------|
| Person 1 | Obesity ~ Vitamin D (crude and adjusted for age and sex) |
| Person 2 | Obesity ~ UPF (crude and adjusted) |
| Person 3 | Obesity ~ Vitamin D + UPF (crude and adjusted) |
| Person 4 | Vitamin D × Diabetes interaction (full model from the brief) |

Plus: AIC / likelihood-ratio model comparison, diagnostics, and sensitivity analyses (prevalence ratios, extra confounders, waist-based obesity).

### Key results (adjusted ORs)

| Exposure | OR (95% CI) | p-value |
|----------|-------------|---------|
| Moderate/severe vitamin D deficiency | 2.46 (1.23–4.95) | 0.012 |
| UPF proxy per +10% energy | 1.20 (1.12–1.30) | < 0.001 |

- Both remain significant when modelled together.
- Vitamin D × diabetes interaction: **not significant** (weighted p = 0.245; unweighted LRT p = 0.053), with low power because only 98 participants have diabetes.

## Week 10 – Prediction testing

- 70/30 train/test split and 5 × 10-fold cross-validation.
- **Metrics:** AUC, Brier score, sensitivity/specificity, calibration.
- **Methods:** logistic regression compared with LDA, a classification tree, kNN and K-means.
- Full model CV AUC = **0.636** vs **0.597** for age + sex only: modest discrimination, good calibration.
- K-means clusters differ in obesity rate but predict poorly (AUC 0.52).

## Notes for the report

- Vitamin D is coded deficient vs adequate in the interaction model because cells are small.
- K-means uses continuous variables only (age, two diet measures, energy).
- The "auto-filled" interpretation paragraphs update automatically if the models change; each person's section also has "Discussion prompts" to expand in the write-up.
