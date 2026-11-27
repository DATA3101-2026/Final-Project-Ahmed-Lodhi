# Children's Daily Screen Time and Its Relationship with Age

**Course:** DATA 3101 — Final Project
**Author:** [Ahmed Mohy Ud Din Khan Lodhi]  
**Date:** [2026-11-25]

## 1. Research question and overview

Does children's average daily screen time increase with age?

This project explores how daily screen time differs between children of different ages. It compares two datasets, one from Kaggle and one from Mendeley Data. It also explores weekday and weekend use, educational and recreational use, gender, social media use and household arrangements where those variables are available.
The main reason for choosing this project was to understand children's screen time and how it reflects based on their age and also some factors beside it as well.


## 2. Repository structure

The following layout is expected by the R script. Generated files appear when the script runs successfully.

```text
README.md
AI-LOG.md
DATA_DICTIONARY.md
R/
  Screen Time Research Project.R
data/
  raw/
    screen_time.csv
    dataset_depressao_infantil_public.csv
  clean/
    kaggle_screen_time_total.csv
    mendeley_screen_time.csv
figures/
  screen_time_histogram.png
  screen_time_by_age.png
outputs/
  kaggle_weekend_gap_by_age.csv
  kaggle_educational_vs_recreational.csv
  kaggle_screen_time_by_gender.csv
  mendeley_screen_time_by_age.csv
  mendeley_screen_time_by_age_group.csv
  mendeley_social_media_summary.csv
  mendeley_household_summary.csv
  session_info.txt
```

The raw data folder holds the unchanged data without any changes and the clean folder holds the clean data removing all the missing values from our data and the output folder includes all the data that we have received from our R script and the figure folder contains two plots that explains our data visually. 
The AI lOG includes the help used for this project outside the class information.

## 3. Software and packages

Use R 4.1 or newer, which supports the native pipe (`|>`), and a recent version of tidyverse. RStudio is recommended. Install tidyverse once if it is not already installed:

```r
install.packages("tidyverse")
```

The script loads tidyverse, including readr for CSV files, dplyr for processing and ggplot2 for graphs. The script saves version information in `outputs/session_info.txt`.

## 4. Data acquisition

If the raw files are already included in the repository, no download is needed. Otherwise:

1. Open the Kaggle source linked in section 13 and download its CSV (sign in if required). Extract the file if it is in a ZIP archive. Place it in `data/raw/` under the name `screen_time.csv` without altering its contents.
2. Open version 2 of the Mendeley source linked in section 13. Download `dataset_depressao_infantil_public.csv` and place it in `data/raw/` with its original name.

## 5. Data cleaning and processing

### Kaggle

- Rename the columns to make them easier to use in R.
- Check for missing values using `sum(is.na(kaggle_raw))`. The current script checks but does not automatically remove missing Kaggle values.
- Keep only Total screen-time rows in the cleaned dataset to avoid counting educational and recreational time again alongside their total. The educational and recreational rows are retained in a separate in-memory table for that specific comparison.
- Save the cleaned total-screen-time data to `data/clean/kaggle_screen_time_total.csv`.

### Mendeley

- Select the study identifier, age, screen time, social media use and household arrangement. Other variables are not needed for this research question.
- Divide screen time in minutes by 60 to create `screen_hours`, so both sources use hours per day.
- Remove rows missing screen time. Keep missing values in other variables in the cleaned file, excluding them only from analyses that need those variables.
- Save the cleaned data in `data/clean/mendeley_screen_time.csv`.
- Restrict analysis and plots to ages 7–14, matching the age range described by the source. The wider cleaned file is retained. The original script notes some records outside this range; verify the exact number using the script before reporting it.

## 6. Data analysis

Kaggle provides group averages and sample sizes. The script calculates a weighted average by multiplying each group average by its sample size, adding those products and dividing by the total sample size. This gives larger groups proportionally more weight. It calculates averages by age and day type, weekend minus weekday differences, educational and recreational averages and recreational share, and averages by age and gender. The gender and activity summaries pool available day-type records; they are not necessarily seven-day calendar-weighted estimates.

Mendeley provides individual records. The script calculates average daily screen time and the percentage reporting more than two hours per day, by age and for ages 7–11 versus 12–14. The two-hour threshold is a descriptive cutoff for total screen time, not a diagnosis or a test of compliance with recreational-screen-time guidelines. It also compares average screen time by social media use and household arrangement.

The script uses Spearman correlation to examine whether older children tend to report higher or lower screen time. It measures a rank-based association, not causation. The social media comparison is descriptive.

## 7. Data visualization

### Histogram

`figures/screen_time_histogram.png` shows the distribution of daily screen time among Mendeley children aged 7–14 with available screen-time data. Each bin is one hour wide. The horizontal axis measures hours per day and the vertical axis counts children.

### Comparative line graph

`figures/screen_time_by_age.png` compares average daily screen time by age across Kaggle weekday, Kaggle weekend and Mendeley daily estimates. The sources remain separate series rather than being joined at the individual level. The graph uses labelled axes, a source caption and a vertical axis starting at zero. Comparisons across sources are most meaningful for overlapping ages, and the Mendeley daily measure is not necessarily equivalent to either day-specific Kaggle measure.

## 8. How to reproduce the project

1. Clone or download the GitHub repository.
2. Open the project root (the folder containing README.md, R/ and data/) as your RStudio project or working directory. Check with `getwd()` if unsure.
3. Install tidyverse if necessary and obtain the raw CSV files as described above.
4. Restart R for a clean session.
5. Run this command from the project root, or open the script and use Source:

```r
source("R/Screen Time Research Project.R")
```

6. Check the console for errors and the printed data checks and Spearman result. The script creates output directories if needed and saves the cleaned CSVs, plots and summary tables automatically.
7. To test reproducibility, move the generated cleaned files into a temporary backup outside the output folder, restart R, and run the script again. Compare the regenerated files with the backups. Confirm that the plots and summary tables are regenerated too.

## 9. Findings

Complete this section after running the script and inspecting the actual outputs:

- Age and screen time: [The trend shows that screen tend to increase with age and it does also affect based on their household settings.]
- Spearman correlation: [This correlation mainly helps to understand if age has a main factor in changing screen times.]
- Educational/recreational comparison: [It shows that at young age it is mostly recreational whereas at an older age it mixes into educational and recreational screen time.]
- Social media, age groups and household comparisons: [Social media screen time increases by age because parents have parental lock until a certain age for their children based on their household settings.]


## 10. Limitations

The two sources have different units of observation: Kaggle contains grouped averages, while Mendeley contains individual records from Brazilian schoolchildren. Their sampling methods, populations, collection periods and definitions of screen time may differ. The origin and whether the Kaggle data are synthetic must be confirmed from the original source documentation before interpreting them as observations of real children.

The Mendeley study is cross-sectional; differences between ages do not demonstrate changes within the same children over time. Associations do not establish causation. Missing responses, self-report error and differences in group sizes may affect the findings. The analysis does not investigate depression or physical activity, even though those variables appear in the original Mendeley dataset. Results should not be generalized to all children.

## 11. Code references and AI assistance

The main data processing and visualization techniques follow the DATA 3101 class exercises and supplied R and ggplot2 cheat sheets. Additional references for functions used in the script:

- R directory creation: https://stat.ethz.ch/R-manual/R-devel/library/base/help/dir.create.html
- Spearman correlation: https://stat.ethz.ch/R-manual/R-devel/library/stats/html/cor.test.html
- Software version information: https://stat.ethz.ch/R-manual/R-devel/library/utils/html/sessionInfo.html
- Capturing console output: https://stat.ethz.ch/R-manual/R-devel/library/utils/html/capture.output.html

ChatGPT assisted with drafting and revising the R script, explaining functions and preparing this README. The separate `AI-LOG.md` should document the actual assistance, revisions and verification through the submission date. 

## 12. Ethics statement

This project reuses existing datasets for educational analysis and does not recruit participants. The Mendeley source reports that its data are de-identified and that its original study received ethical approval. Because the data concern children, no attempt should be made to identify participants or disclose individual health information. The analysis uses only variables needed for its research question and reports aggregate results. Original authors are credited, and any redistribution must follow the relevant dataset licence. Reusers should preserve attribution, respect participant privacy and avoid interpreting associations as causal findings.

## 13. Sources

**Kaggle:** ak0212. *Average Daily Screen Time for Children*. https://www.kaggle.com/datasets/ak0212/average-daily-screen-time-for-children . Contains group-level screen time summaries by age, gender, activity type and day type, with sample sizes used to weight averages. Licence and version/download date: [verify using the Kaggle page and your Part 2 licence analysis].

**Mendeley Data:** Schaidhauer, F. (2026). *Dataset: Screen time, social media use, physical activity and depressive symptoms (CDI) in Brazilian schoolchildren (n = 320)* (Version 2). Mendeley Data. https://doi.org/10.17632/h27yvy7986.2 . The source describes a cross-sectional study conducted in 2024–2025, with 320 children and a stated age range of 7–14. It provides individual daily screen-time measures, social media use and household information used here. Licence: CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/). Source page: https://data.mendeley.com/datasets/h27yvy7986/2 .

Both sources contain age and daily screen time, allowing comparison after converting units and calculating age-specific averages. They do not contain matching participant identifiers or identical day-type, activity-type and household measures, so they are compared as separate sources rather than merged as individual records.
