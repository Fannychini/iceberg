# ------------------------------------------------ #
# Example workflow code for making an iceberg plot #
# ------------------------------------------------ #

## Library
library(tidyverse)

## Reproducibility
set.seed(239) 
sessionInfo()

## Source
source('01_data_prep.R')
source('02_iceberg_plot.R')

## Data expectations !! 
#
# !!!!!!
# data should be wide format, i.e. one row per person. 
# if data is stored in long format, it should be pivoted prior to using iceberg_data()
# wide_data <- long_data %>%
#   pivot_wider(id_cols = "person_id",
#     names_from = "therapy_type",
#     values_from = c("duration", "response"))
#
# a pivoting case is included in proposed this workflow
# a function for pivoting is also provided in 01_data_prep.R but you may need to modify it depending on your data input
# !!!!!!

## Data (generated)
long_data <- readRDS(file = 'data/long_data.RDS')
wide_data <- readRDS(file = 'data/wide_data.RDS')


## Pivot if needed ----
data_pivoted <- long_data %>%
  # include all patient-specific attributes needed in id_cols
  pivot_wider(id_cols = c("patient_id", "age", "sex", "genomic_alteration", "cancer_type"),
    names_from = "therapy_type",
    values_from = c("duration", "response")) %>%
  # rename cols to match expected format
  rename(prior_pfs = duration_prior,
    sdt_pfs = duration_current,
    prior_response = response_prior,
    current_response = response_current)

# check
print(data_pivoted)
rm(data_pivoted) # using `data` df loaded above


## Use **iceberg_data** to generate x axis location on plot ----
data_prep <- iceberg_data(data = wide_data, 
                          patient_id = 'patient_id',
                          current_pfs = "sdt_pfs",
                          prior_pfs = "prior_pfs")

# check
print(data_prep)
length(unique(data_prep$x_location)) == length(unique(data_prep$patient_id))


## Use **iceberg_plot** to generate basic iceberg plot ----
plot <- iceberg_plot(data_prep,
                     patient_id = "patient_id",
                     current_pfs = "sdt_pfs",
                     prior_pfs = "prior_pfs")
print(plot)


## Use **iceberg_theme** and **iceberg_style** to icebergify your plot ----
iceberg_plot <- iceberg_plot(data = data_prep,
                             patient_id = "patient_id",
                             current_pfs = "sdt_pfs", 
                             prior_pfs = "prior_pfs") + 
  iceberg_theme(base_size = 12) + 
  iceberg_style() + 
  # can change waterline_colour for ex:
  # iceberg_style(waterline_colour = "black") +
  labs(title = "Current vs prior treatment",
       x = "person id",
       y = "PFS (months)")


print(iceberg_plot)
