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

### Manually ----
manual_pivoted <- long_data %>%
  # include all patient-specific attributes needed in id_cols
  pivot_wider(id_cols = c("patient_id", "age", "sex", "genomic_alteration", "cancer_type"),
    names_from = "therapy_type",
    values_from = c("duration", "response")) %>%
  # rename cols to match expected format
  rename(prior_pfs = duration_prior,
    sdt_pfs = duration_current,
    prior_response = response_prior,
    current_response = response_current)

### Using provided fct long_to_wide() ----
fct_pivoted <- long_to_wide(long_data, 
                             patient_id = "patient_id", 
                             therapy_type = "therapy_type", 
                             duration = "duration", 
                             response = "response")
  

## Prepare x-axis location using iceberg_data() ----
data_prep <- iceberg_data(data = fct_pivoted, 
                          patient_id = 'patient_id',
                          current_pfs = "sdt_pfs",
                          prior_pfs = "prior_pfs")

# check
print(data_prep)
length(unique(data_prep$x_location)) == length(unique(data_prep$patient_id))


## Basic iceberg plot using iceberg_plot() ----
plot <- iceberg_plot(data_prep,
                     patient_id = "patient_id",
                     current_pfs = "sdt_pfs",
                     prior_pfs = "prior_pfs")
print(plot)


## Icebergify plot using iceberg_theme() and iceberg_style() ----
my_iceberg <- iceberg_plot(data = data_prep,
                             patient_id = "patient_id",
                             current_pfs = "sdt_pfs", 
                             prior_pfs = "prior_pfs") + 
  iceberg_theme() + 
  iceberg_style() + 
  labs(title = "Current vs previous treatment",
       x = "person id",
       y = "PFS (months)")

print(my_iceberg)


# other example use modifying some parameters in theme and style
iceberg_plot(data = data_prep,
             patient_id = "patient_id",
             current_pfs = "sdt_pfs", 
             prior_pfs = "prior_pfs") + 
  iceberg_theme(base_size = 12) + 
  iceberg_style(waterline_colour = "black") 


## Calculate Von Hoff ratio ----
data_prep <- calculate_von_hoff(data_prep, 
                                current_response = "sdt_pfs",
                                prior_response = "prior_pfs")

## Von Hoff on iceberg ----
my_iceberg <- visualise_von_hoff(my_iceberg, 
                                 data_prep, 
                                 patient_id = "patient_id")

print(my_iceberg)
