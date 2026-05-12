# Programming-for-Psyc-Final-Project-Final-Draft

# Data Analysis Explanation
Data Analysis Plan: In this data analysis, I am examining whether increased levels of major depressive episodes are correlated to higher rates of school suspension and expulsion, whether exclusionary school discipline is associated with over-representation in arrests, and whether there is a relationship between adolescent mental-health prevalence and juvenile arrests that differs across racial, socioeconomic, and geographic contexts. This analysis will utilize 8 variables from the State-Level Data on Juvenile Delinquency and Violence, Mental-Health and Psychotropic-Medication Related Issues, and School Accountability, United States, 1990-2014 (ICPSR 36775) dataset (Tcherni-Buzzeo, 2019). These variables include adolescent major depressive episodes ages 12-17 (mde1217), suspensions per 1,000 students enrolled at the state-level (suspend), expulsions per 1,000 students enrolled at the state-level (expel), violent-crime arrests under age 18 (jarviol), property-crime arrests under age 18 (jarprop), percentage of Black population (pblack), childhood poverty rates (chpov), and urban population percentage (purban). By investigating this unique combination of variables, this study aims to paint a clearer picture of how schools may serve as a critical crossroads in pathways connecting psychological distress to disproportionate punitive punishment.

# Research Questions
(1) Do states with more adolescent major depressive episodes also report higher rates of school suspensions and expulsions? 

(2) Are higher rates of exclusionary school discipline associated with over-representation in arrests relative to adults at the state level? 

(3) Does the relationship between adolescent mental-health prevalence and juvenile arrests relative to adults differ across contexts of racial, socioeconomic, and geographic marginalization?

# Analyses Run
For RQ1A, state-fixed-effects regression models were estimated to assess the association between adolescent depression prevalence and school discipline outcomes, while controlling for unobserved, time-invariant state characteristics. Cluster-robust standard errors at the state level were used to account for within-state dependence across years. Fixed effects models were selected to isolate within-state associations over time while accounting for stable differences between states that could confound cross-sectional comparisons.

For RQ1B, cross-sectional linear regression models were estimated using 2000 data. Because observations were independent across states and heteroskedasticity was plausible, heteroskedasticity-consistent (HC1) robust standard errors were reported.

To examine whether exclusionary school discipline was associated with juvenile-to-adult arrest ratios, panel regression models with state and year fixed effects were estimated. Robust standard errors, clustered at the state level, were used. Additional robustness checks substituted expulsions for suspensions as the focal predictor.

For RQ3, since the analysis used only 2010 data, fixed effects and clustering were not used. Instead, OLS models with HC1 robust errors were run. Moderation tests used interaction terms between adolescent depression and each contextual variable (poverty, race, urbanicity).

# Key Findings
The state fixed-effects models showed no statistically significant link between adolescent major depressive episode prevalence and suspension (p = .713) or expulsion (p = .884) rates. The state fixed-effects models showed no statistically significant link between adolescent major depressive episode prevalence and suspension (p = .713) or expulsion (p = .884) rates. Within-state changes in adolescent depression prevalence between 2006 and 2011 were not significantly associated with within-state changes in suspension or expulsion rates.

There was no significant association between suspension rates and juvenile-to-adult arrest ratios for violent (p = .227) or property (p = .353) index crimes. Substituting expulsion rates for suspension rates did not change the findings (p > .05). Year-fixed effects showed a significant decline in juvenile-to-adult ratios between 2000 and 2011, suggesting that the reduction in juvenile justice involvement is independent of school discipline practices (Figure 1). 

Figure 1: Time trend of arrest ratios
<img width="1586" height="1245" alt="image" src="https://github.com/user-attachments/assets/9e357bf1-d88e-4209-a284-8b849ad60691" />

Cross-sectional analyses using 2000 data indicated that states with larger proportions of Black residents had significantly higher suspension rates, even after accounting for childhood poverty. Childhood poverty was not significantly associated with suspension rates, and neither predictor significantly predicted expulsion rates. These findings reflect between-state cross-sectional differences rather than within-state longitudinal change. The fixed-effects models relied on only three waves of state-level data, limiting the within-state temporal variation available for estimation and reducing statistical power to detect associations.

The cross-sectional moderation analyses revealed a significant interaction between adolescent depression prevalence and urbanicity when predicting juvenile-to-adult violent arrest ratios (Figure 2). This suggests that the negative association between adolescent depression prevalence and violent juvenile arrest ratios was stronger in more urban states. As urbanicity increases, the relationship between adolescent depression prevalence and violent juvenile arrest ratios becomes more negative. This association was weaker or absent altogether in less urban states. This pattern may reflect differences in mental health service access, diversion opportunities, or juvenile justice practices across urban and rural states. Neither childhood poverty nor the percentage of Black residents had a significant interaction with adolescent depression prevalence and urbanicity when predicting juvenile-to-adult violent arrest ratios.

Figure 2: Interaction between adolescent depression prevalence and urbanicity predicting
juvenile-to-adult violent arrest ratios
<img width="1586" height="1245" alt="image" src="https://github.com/user-attachments/assets/82680205-294a-4c5b-aa29-35dc38ba8bfb" />


# Required Packages
tidyverse,
haven,
lmtest,
sandwich,
interactions,
dplyr,
rempsyc,   
flextable, 
scales

# Dependencies
To run this code, you need R version 4.0 or higher.

# File Conversion
The original file is in the .sav format. Trying to open the data set in R directly will result in an error. To use the data set in R, you must use the function read.sav() to import the data.

# How to Run
Open the .R script file titled "PP Final Data Analysis Project.R". Lines 1 through 10 import necessary R packages. Lines 12 through 13 load the data set. Lines 15 through 210 isolate the variables required for the analyses, clean up the descriptive statistics, and create a variables table and descriptive statistics tables. Lines 212 through 225 clean the data set to prepare to run analyses. Lines 227 through 292 run analyses to evaluate research question 1. Lines 294 through 380 run analyses to evaluate research question 2. Lines 382 through 448 run analyses to evaluate research question 3. Lines 450 to 480 create and save visual plots.

# Table 1: Variables Used in Data Analysis
<img width="1584" height="1242" alt="image" src="https://github.com/user-attachments/assets/a2d69fb1-4af2-4316-b31c-bc2e4d6c4309" />

# Table 2: Descriptive Statistics for State-Level Study Variables
<img width="1584" height="1242" alt="image" src="https://github.com/user-attachments/assets/11ec52f9-4bf4-40b6-a635-6c9a790335a1" />

# Reference
Tcherni-Buzzeo, M. (2019). State-level data on juvenile delinquency and violence, mental-health and psychotropic-medication related issues, and school accountability, United States,
1990-2014 (ICPSR 36775, Version V1) [Data set]. Inter-university Consortium for
Political and Social Research. https://doi.org/10.3886/ICPSR36775.v1
