library(tidyverse)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)


dir.create("data/clean", recursive = TRUE, showWarnings = FALSE)
dir.create("figures",    showWarnings = FALSE)
dir.create("outputs",    showWarnings = FALSE)

kaggle_path   <- "data/raw/screen_time.csv"
mendeley_path <- "data/raw/dataset_depressao_infantil_public.csv"

# ---- 1. Kaggle: load raw and clean -------------------------------------------
# Raw file is read as received and never edited.
kaggle_raw <- read_csv(kaggle_path)
colnames(kaggle_raw)

# Rename to simple column names (the raw ones contain spaces and brackets).
kaggle_all <- kaggle_raw |>
  rename(age = Age, gender = Gender, screen_type = `Screen Time Type`,
         day_type = `Day Type`, avg_hours = `Average Screen Time (hours)`,
         sample_size = `Sample Size`)

# Keep only "Total" rows: Educational + Recreational already add up to Total
# (checked: differences are at most 0.01 h), so keeping all three types
# would double count screen time.
kaggle_clean <- kaggle_all |> filter(screen_type == "Total")

# The raw file has no NA values, so no rows are dropped for missing data.
sum(is.na(kaggle_raw))

write_csv(kaggle_clean, "data/clean/kaggle_screen_time_total.csv")

# ---- 2. Mendeley: load raw and clean -----------------------------------------
mendeley_raw <- read_csv(mendeley_path)
colnames(mendeley_raw)

# Convert minutes to hours so it matches Kaggle. Keep the few extra columns
# needed for the supporting analyses (social media use, household).
# Rows with missing screen time cannot answer the question, so they are dropped.
# Rows are NOT dropped for missing values in other columns.
mendeley_clean <- mendeley_raw |>
  select(study_id, age_years, screen_time_minutes_per_day,
         social_media_use_binary, household_arrangement) |>
  mutate(screen_hours = screen_time_minutes_per_day / 60) |>
  filter(!is.na(screen_hours))

# Document exactly what the cleaning removed
nrow(mendeley_raw) # number of rows before cleaning
sum(is.na(mendeley_raw$screen_time_minutes_per_day)) # missing screen time
nrow(mendeley_clean) # number of rows after cleaning

write_csv(mendeley_clean, "data/clean/mendeley_screen_time.csv")

# The README says the sample is aged 7-14, but 6 children are aged 15-16.
# They stay in the cleaned file but are excluded from analysis and plots.
mendeley_14 <- mendeley_clean |> filter(age_years >= 7, age_years <= 14)
nrow(mendeley_clean) - nrow(mendeley_14) # number excluded

# ---- 3. Kaggle: additional summaries -----------------------------------------
# Mean total screen time by age and day type, weighted by sample size
# Multiply each average by its sample size, add them, then divide by total sample size.
kaggle_age <- kaggle_clean |>
  group_by(age, day_type) |>
  summarise(mean_hours = sum(avg_hours * sample_size) / sum(sample_size))

# Weekend minus weekday gap by age
# Square brackets select the values for each day type, like the class population example.
weekend_gap <- kaggle_age |>
  group_by(age) |>
  summarise(Weekend = mean_hours[day_type == "Weekend"],
            Weekday = mean_hours[day_type == "Weekday"]) |>
  mutate(gap_hours = Weekend - Weekday)
weekend_gap

# Educational vs recreational screen time by age (excludes Total)
edu_rec <- kaggle_all |>
  filter(screen_type != "Total") |>
  group_by(age, screen_type) |>
  summarise(mean_hours = sum(avg_hours * sample_size) / sum(sample_size)) |>
  group_by(age) |>
  summarise(Educational = mean_hours[screen_type == "Educational"],
            Recreational = mean_hours[screen_type == "Recreational"]) |>
  mutate(recreational_share = Recreational / (Educational + Recreational))
edu_rec

# Gender differences by age
by_gender <- kaggle_clean |>
  group_by(age, gender) |>
  summarise(mean_hours = sum(avg_hours * sample_size) / sum(sample_size))

write_csv(weekend_gap, "outputs/kaggle_weekend_gap_by_age.csv")
write_csv(edu_rec,     "outputs/kaggle_educational_vs_recreational.csv")
write_csv(by_gender,   "outputs/kaggle_screen_time_by_gender.csv")

# ---- 4. Mendeley: additional summaries ---------------------------------------
# Mean screen time and share of children over 2 hours/day, by age
mendeley_age <- mendeley_14 |>
  group_by(age = age_years) |>
  summarise(n = n(), mean_hours = mean(screen_hours),
            pct_over_2h = sum(screen_hours > 2) / n() * 100)
mendeley_age

# Same, in two age groups (7-11 and 12-14)
younger <- mendeley_14 |>
  filter(age_years <= 11) |>
  mutate(age_group = "7-11")

older <- mendeley_14 |>
  filter(age_years >= 12) |>
  mutate(age_group = "12-14")

mendeley_group <- bind_rows(younger, older) |>
  group_by(age_group) |>
  summarise(n = n(), mean_hours = mean(screen_hours),
            pct_over_2h = sum(screen_hours > 2) / n() * 100)
mendeley_group

# Is screen time related to age? Spearman is used because screen time is
# self-reported in rounded values and is not normally distributed.
age_test <- cor.test(mendeley_14$age_years, mendeley_14$screen_hours,
                     method = "spearman", exact = FALSE)
print(age_test) # optional statistical test beyond the supplied class examples

# Social media use vs screen time (3 children have no social media answer
# and are left out of this comparison only)
social <- mendeley_14 |>
  filter(!is.na(social_media_use_binary))

social_yes <- social |>
  filter(social_media_use_binary == 1) |>
  mutate(social_media = "Uses social media")

social_no <- social |>
  filter(social_media_use_binary != 1) |>
  mutate(social_media = "Does not use social media")

social <- bind_rows(social_yes, social_no)

social_summary <- social |>
  group_by(social_media) |>
  summarise(n = n(), mean_age = mean(age_years),
            mean_hours = mean(screen_hours))
social_summary

# Household arrangement vs screen time
household_summary <- mendeley_14 |>
  filter(!is.na(household_arrangement)) |>
  group_by(household_arrangement) |>
  summarise(n = n(), mean_hours = mean(screen_hours))
household_summary

write_csv(mendeley_age,       "outputs/mendeley_screen_time_by_age.csv")
write_csv(mendeley_group,     "outputs/mendeley_screen_time_by_age_group.csv")
write_csv(social_summary,     "outputs/mendeley_social_media_summary.csv")
write_csv(household_summary,  "outputs/mendeley_household_summary.csv")

# ---- 5. Plot 1: histogram (Mendeley, individual children) --------------------
p_hist <- ggplot(mendeley_14, aes(x = screen_hours)) +
  geom_histogram(binwidth = 1, fill = "steelblue", colour = "white") +
  scale_x_continuous(breaks = seq(0, 16, 2)) +
  labs(title = "Daily screen time of Brazilian schoolchildren aged 7-14",
       subtitle = "Self-reported screen time",
       x = "Daily screen time (hours)", y = "Number of children",
       caption = "Source: Mendeley Data, Schaidhauer (2026), CC BY 4.0") +
  theme_minimal()
p_hist
ggsave("figures/screen_time_histogram.png", p_hist,
       width = 8, height = 5, dpi = 300)

# ---- 6. Plot 2: line plot comparing both sources by age ----------------------
line_data <- bind_rows(
  kaggle_age |>
    filter(day_type == "Weekday") |>
    mutate(series = "Kaggle, weekday") |>
    select(age, mean_hours, series),
  kaggle_age |>
    filter(day_type == "Weekend") |>
    mutate(series = "Kaggle, weekend") |>
    select(age, mean_hours, series),
  mendeley_age |>
    mutate(series = "Mendeley (Brazil, individual reports)") |>
    select(age, mean_hours, series)
)

p_line <- ggplot(line_data, aes(x = age, y = mean_hours, colour = series)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_x_continuous(breaks = 5:15) +
  scale_y_continuous(limits = c(0, NA)) +   # start at 0 so the slope is not exaggerated
  labs(title = "Average daily screen time by age in both datasets",
       x = "Age (years)", y = "Average daily screen time (hours)",
       colour = "Source",
       caption = "Sources: Kaggle (ak0212); Mendeley Data (Schaidhauer, 2026)") +
  theme_minimal()
p_line
ggsave("figures/screen_time_by_age.png", p_line,
       width = 8, height = 5, dpi = 300)

# ---- 7. Record the R and package versions used ------------------------------
# Extra reproducibility step, not shown in the class examples.
writeLines(capture.output(sessionInfo()), "outputs/session_info.txt")

