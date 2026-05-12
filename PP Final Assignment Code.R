# Packages
library(tidyverse)
library(haven)
library(lmtest)
library(sandwich)
library(interactions)
library(dplyr)
library(rempsyc)    # for nice_table()
library(flextable)  # rempsyc returns flextable objects
library(scales)  

# Load data
dat <- read_sav("Dataset_NIJ_GRANT_2014-R2-CX-0003_DV-IV_3-29-17.sav")

# Variable Names in original dataset
colnames(dat)
names(dat)
View(dat)

# Variables used in final project
vars <- c("state","mde1217","suspend","expel","jarviol","jarprop",
          "pblack","chpov","purban")

# Create state-averaged dataset for ALL 8 variables used in your project
state_avg <- dat %>%
  select(
    state,
    mde1217,
    suspend,
    expel,
    jarviol,
    jarprop,
    pblack,
    chpov,
    purban
  ) %>%
  # treat negative values (SPSS missing codes) as NA
  mutate(
    mde1217 = ifelse(mde1217 < 0, NA, mde1217),
    suspend = ifelse(suspend < 0, NA, suspend),
    expel   = ifelse(expel   < 0, NA, expel),
    jarviol = ifelse(jarviol < 0, NA, jarviol),
    jarprop = ifelse(jarprop < 0, NA, jarprop),
    pblack  = ifelse(pblack  < 0, NA, pblack),
    chpov   = ifelse(chpov   < 0, NA, chpov),
    purban  = ifelse(purban  < 0, NA, purban)
  ) %>%
  group_by(state) %>%
  summarise(
    mde1217 = mean(mde1217, na.rm = TRUE),
    suspend = mean(suspend, na.rm = TRUE),
    expel   = mean(expel,   na.rm = TRUE),
    jarviol = mean(jarviol, na.rm = TRUE),
    jarprop = mean(jarprop, na.rm = TRUE),
    pblack  = mean(pblack,  na.rm = TRUE),
    chpov   = mean(chpov,   na.rm = TRUE),
    purban  = mean(purban,  na.rm = TRUE),
    .groups = "drop"
  )

# Check result
names(state_avg)
nrow(state_avg)
head(state_avg)
summary(state_avg)

# Run Descriptive Statistics for Research Quesiton Variables
descriptives_wide <- state_avg %>%
  summarise(
    across(
      .cols = c(mde1217, suspend, expel, jarviol, jarprop, pblack, chpov, purban),
      .fns = list(
        n   = ~ sum(!is.na(.)),
        M   = ~ mean(., na.rm = TRUE),
        SD  = ~ sd(., na.rm = TRUE),
        Min = ~ min(., na.rm = TRUE),
        Max = ~ max(., na.rm = TRUE)
      ),
      .names = "{.col}_{.fn}"
    )
  )

# View descriptives_wide
descriptives_wide

# Clean Descriptive Stats
descriptives_clean <- descriptives_wide %>%
  pivot_longer(
    cols = everything(),
    names_to = c("var_name", "stat"),
    names_sep = "_",
    values_to = "value"
  ) %>%
  pivot_wider(
    names_from = stat,
    values_from = value
  ) %>%
  mutate(
    Variable = dplyr::recode(
      var_name,
      "mde1217" = "Adolescent major depressive episodes (12–17), %",
      "suspend" = "Suspensions per 1,000 students",
      "expel"   = "Expulsions per 1,000 students",
      "jarviol" = "Juvenile-to-adult arrest ratio (weighted): violent index crimes",
      "jarprop" = "Juvenile-to-adult arrest ratio (weighted): property index crimes",
      "pblack"  = "Black population, %",
      "chpov"   = "Child poverty count",
      "purban"  = "Urban population, %"
    ),
    across(c(M, SD, Min, Max), ~ round(., 2))
  ) %>%
  select(Variable, n, M, SD, Min, Max)

# View descriptives_clean
descriptives_clean

# Add variable codes and a range column
table1_data <- descriptives_clean %>%
  mutate(
    Code = c(
      "mde1217",
      "suspend",
      "expel",
      "jarviol",
      "jarprop",
      "pblack",
      "chpov",
      "purban"
    ),
    
    # round values to 2 decimals before building range
    Min2 = round(Min, 2),
    Max2 = round(Max, 2),
    
    # format large values with commas
    Min2 = ifelse(Min2 > 999, scales::comma(Min2), formatC(Min2, format = "f", digits = 2)),
    Max2 = ifelse(Max2 > 999, scales::comma(Max2), formatC(Max2, format = "f", digits = 2)),
    
    Range = paste0("[", Min2, ", ", Max2, "]")
  ) %>%
  select(Code, Description = Variable, Range)

# Create APA-Style Table 1 with rempsyc
table1 <- nice_table(
  data   = table1_data,
  spacing = 2,  # double-spaced rows (APA)
  title  = c(
    "Table 1",
    "Variables Used in the Present Study"
  ),
  note   = c(
    "Ranges reflect observed minimum and maximum values ",
    "across U.S. states in the aggregated dataset."
  )
)

# Fix alignment to match APA (stub left, others centered)
table1 <- table1 %>%
  align(align = "left",   j = "Code") %>%
  align(align = "center", j = c("Description", "Range"))

# Print Table
table1

# Prepare descriptives for APA table
descriptives_for_table <- descriptives_clean %>%
  mutate(
    N = n,
    
    # Format means and SD
    M   = round(M, 2),
    SD  = round(SD, 2),
    
    # Round min/max
    Min = round(Min, 2),
    Max = round(Max, 2),
    
    # Add comma formatting only to large values,
    # otherwise force 2 decimal places
    Min = ifelse(
      Min > 999,
      scales::comma(Min),
      formatC(Min, format = "f", digits = 2)
    ),
    Max = ifelse(
      Max > 999,
      scales::comma(Max),
      formatC(Max, format = "f", digits = 2)
    )
  ) %>%
  select(Variable, N, M, SD, Min, Max)

# Create Table 2 (APA 7 Style)
table2 <- nice_table(
  data  = descriptives_for_table,
  spacing = 2,
  title = c("Table 2", "Descriptive Statistics for State-Level Study Variables"),
  note  = "N = number of states with non-missing data. M = mean; SD = standard deviation; Min = minimum; Max = maximum. Juvenile justice outcomes are juvenile-to-adult arrest ratios (weighted by juvenile-to-adult population share)."
)

# Align columns per APA: stub left, others centered
table2 <- table2 %>%
  align(align = "left",   j = "Variable") %>%
  align(align = "center", j = c("N", "M", "SD", "Min", "Max"))

# Adjust table width
table2 <- table2 %>% width(j = "Variable", width = 3.5)

# View Table 2
table2

# Keep only what you need and convert -9 to NA
dat_clean <- dat %>%
  select(
    state, year,
    mde1217,
    suspend, expel,
    jarviol, jarprop,
    pblack, chpov, purban
  ) %>%
  mutate(across(where(is.numeric), ~ na_if(., -9))) %>%
  mutate(
    state_f = factor(state),
    year_f  = factor(year)
  )

#######################
# Research Question 1 #
#######################
# RQ1A: Depression → discipline (state-year panel with fixed effects)
rq1a_suspend_dat <- dat_clean %>%
  filter(!is.na(mde1217), !is.na(suspend)) %>%   # ensures 2004–2014 + complete
  droplevels()

m_rq1a_suspend <- lm(
  suspend ~ mde1217 + state_f + year_f,
  data = rq1a_suspend_dat
)

coeftest(
  m_rq1a_suspend,
  vcov = vcovCL(m_rq1a_suspend, cluster = ~ state_f, type = "HC1")
)

# 2) Expulsion outcome
rq1a_expel_dat <- dat_clean %>%
  filter(!is.na(mde1217), !is.na(expel)) %>%
  droplevels()

m_rq1a_expel <- lm(
  expel ~ mde1217 + state_f + year_f,
  data = rq1a_expel_dat
)

coeftest(
  m_rq1a_expel,
  vcov = vcovCL(m_rq1a_expel, cluster = ~ state_f, type = "HC1")
)

# RQ1B: Marginalization → discipline (cross-sectional, year 2000)
# 3) Suspension in 2000
rq1b_dat <- dat_clean %>%
  filter(year == 2000, !is.na(suspend), !is.na(pblack), !is.na(chpov))

m_rq1b_suspend <- lm(
  suspend ~ pblack + chpov,
  data = rq1b_dat
)

coeftest(
  m_rq1b_suspend,
  vcov = vcovHC(m_rq1b_suspend, type = "HC1")
)

# 4) Expulsion in 2000
rq1b_dat_expel <- dat_clean %>%
  filter(year == 2000, !is.na(expel), !is.na(pblack), !is.na(chpov))

m_rq1b_expel <- lm(
  expel ~ pblack + chpov,
  data = rq1b_dat_expel
)

coeftest(
  m_rq1b_expel,
  vcov = vcovHC(m_rq1b_expel, type = "HC1")
)

# Optional: Print R-squared/model fit
## coeftest() gives robust SEs/p-values, but not model fit stats
summary(m_rq1b_suspend)$r.squared
summary(m_rq1b_expel)$r.squared

#######################
# Research Question 2 #
#######################
# Build ONE RQ2 dataset #
# RQ2 analysis dataset (panel with complete cases)
rq2_dat <- dat_clean %>%
  filter(!is.na(suspend), !is.na(jarviol), !is.na(jarprop)) %>%
  mutate(
    state_f = droplevels(factor(state)),
    year_f  = droplevels(factor(year))
  )

# Sanity check
rq2_dat %>% summarise(
  n_rows = n(),
  n_states = n_distinct(state_f),
  n_years = n_distinct(year_f),
  year_min = min(as.numeric(as.character(year_f))),
  year_max = max(as.numeric(as.character(year_f)))
)

# RQ2 models (state + year FE, clustered by state) #
# Suspension -> Violent arrests
m_rq2_viol <- lm(jarviol ~ suspend + state_f + year_f, data = rq2_dat)

coeftest(
  m_rq2_viol,
  vcov = vcovCL(m_rq2_viol, cluster = ~ state_f, type = "HC1")
)

# Suspension -> Property arrests
m_rq2_prop <- lm(jarprop ~ suspend + state_f + year_f, data = rq2_dat)

coeftest(
  m_rq2_prop,
  vcov = vcovCL(m_rq2_prop, cluster = ~ state_f, type = "HC1")
)

# Optional robustness: use expulsion instead of suspension
rq2_expel_dat <- dat_clean %>%
  filter(!is.na(expel), !is.na(jarviol), !is.na(jarprop)) %>%
  mutate(
    state_f = droplevels(factor(state)),
    year_f  = droplevels(factor(year))
  )

m_rq2_viol_expel <- lm(jarviol ~ expel + state_f + year_f, data = rq2_expel_dat)
coeftest(
  m_rq2_viol_expel,
  vcov = vcovCL(m_rq2_viol_expel, cluster = ~ state_f, type = "HC1")
)

m_rq2_prop_expel <- lm(jarprop ~ expel + state_f + year_f, data = rq2_expel_dat)
coeftest(
  m_rq2_prop_expel,
  vcov = vcovCL(m_rq2_prop_expel, cluster = ~ state_f, type = "HC1")
)

# Confirm years in RQ2 Dataset
table(rq2_dat$year)

# Confirm Which States Were Dropped From RQ2 Dataset
sort(unique(rq2_dat$state)) |> length()
sort(unique(rq2_dat$state))[1:10]  # quick peek
setdiff(sort(unique(dat_clean$state)), sort(unique(rq2_dat$state)))

# Quick way to diagnose exactly which state is missing in which year
rq2_dat %>%
  count(year, state) %>%
  count(year)   # Examine number of states represented per year

# Most direct “who’s missing per year?” check
all_states <- sort(unique(rq2_dat$state))

rq2_dat %>%
  group_by(year) %>%
  summarise(
    missing_states = list(setdiff(all_states, sort(unique(state)))),
    n_states = n_distinct(state)
  )

rq2_dat %>%
  group_by(year) %>%
  summarise(
    missing_state = setdiff(all_states, unique(state)),
    n_states = n_distinct(state)
  )

#######################
# Research Question 3 #
#######################
# Cross-sectional (2010): use HC robust SEs instead of clustering
# RQ3 dataset (complete cases for variables used)
rq3_dat <- dat_clean %>%
  filter(
    year == 2010,
    !is.na(mde1217),
    !is.na(jarviol),
    !is.na(pblack),
    !is.na(chpov),
    !is.na(purban)
  )

# Sanity Check
rq3_dat %>% summarise(
  n_states = n_distinct(state),
  n_years  = n_distinct(year)
)
table(rq3_dat$year)

# Mean-center moderators
rq3_dat <- rq3_dat %>%
  mutate(
    pblack_c = pblack - mean(pblack, na.rm = TRUE),
    chpov_c  = chpov  - mean(chpov,  na.rm = TRUE),
    purban_c = purban - mean(purban, na.rm = TRUE)
  )

# RQ3a: Depression × Poverty → Violent arrests
m_rq3_pov_viol <- lm(
  jarviol ~ mde1217 * chpov_c,
  data = rq3_dat
)

coeftest(
  m_rq3_pov_viol,
  vcov = vcovHC(m_rq3_pov_viol, type = "HC1")
)

# RQ3b: Depression × Race → Violent arrests
m_rq3_race_viol <- lm(
  jarviol ~ mde1217 * pblack_c,
  data = rq3_dat
)

coeftest(
  m_rq3_race_viol,
  vcov = vcovHC(m_rq3_race_viol, type = "HC1")
)

# RQ3c: Depression × Urbanicity → Violent arrests
m_rq3_urban_viol <- lm(
  jarviol ~ mde1217 * purban_c,
  data = rq3_dat
)

coeftest(
  m_rq3_urban_viol,
  vcov = vcovHC(m_rq3_urban_viol, type = "HC1")
)

# Optional: replicate with property arrests (strong but optional)
lm(jarprop ~ mde1217 * chpov_c, data = rq3_dat)
lm(jarprop ~ mde1217 * pblack_c, data = rq3_dat)
lm(jarprop ~ mde1217 * purban_c, data = rq3_dat)

# Plot 1 for RQ3
interact_plot(
  m_rq3_urban_viol,
  pred = mde1217,
  modx = purban_c,
  plot.points = TRUE,
  interval = TRUE,
  int.width = 0.95,
  x.label = "Adolescent Major Depressive Episodes (%)",
  y.label = "Juvenile-to-Adult Violent Arrest Ratio",
  legend.main = "Urbanicity"
)

# Plot 2 Significant year effects RQ2
rq2_dat %>%
  group_by(year) %>%
  summarise(mean_jarviol = mean(jarviol, na.rm = TRUE)) %>%
  ggplot(aes(x = year, y = mean_jarviol)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  labs(
    x = "Year",
    y = "Mean Juvenile-to-Adult Violent Arrest Ratio",
    title = "Trends in Juvenile-to-Adult Violent Arrest Ratios Over Time"
  ) +
  theme_minimal()

# Save Plots
ggsave("rq3_urbanicity_interaction.png", width = 8, height = 6)

ggsave("rq2_violent_arrest_trends.png", width = 8, height = 6)
