# -------------------------------------------- #
# Data preparation for generating iceberg plot #
# -------------------------------------------- #

## Library
library(tidyverse)

## Reproducibility
set.seed(239) 
sessionInfo()

## Data expectations
# data should be wide format, i.e. one row per person. 
# this means that each person appears exactly once
# 1. type and duration of 'prior therapy' info is stored as columns
# 2. type and duration of 'current therapy' info is stored as columns
# 3. other attributes needed, such as response to therapies, 
#    genomic alterations, etc. are in other columns

# if data is stored in long format, it should be pivoted prior to using 
# the function prepare_iceberg_locations(), i.e.
wide_data <- long_data %>%
  pivot_wider(id_cols = "person_id",
    names_from = "therapy_type",
    values_from = c("duration", "response"))
# a pivoting case is included in proposed workflow, see example.R 


## Main function
#' @description to prepare data for iceberg plot visualisation by calculating the x-axis 
#' locations according to the methodology in Lythgoe et al.
#' @param data is a df containing person-level data
#' @param person_id column name for person identifiers
#' @param time_a column name for time before starting current therapy (= *prior* therapy duration)
#' @return a df with added x_location values for each person
#' 
prepare_iceberg_locations <- function(data, patient_id, time_a) {
  # check inputs
  if (!all(c(patient_id, time_a) %in% colnames(data))) {
    stop("person ID or prior therapy duration column not found")
  }
  
  # calculate median position
  n_persons <- nrow(data)
  median_location <- if_else(n_persons %% 2 == 0,
                             n_persons / 2,
                             ceiling(n_persons / 2))
  
  # flag the person with max time_a (therapy duration)
  result <- data %>%
    mutate(is_max = .data[[time_a]] == max(.data[[time_a]]))
  
  # get person with max and remaining persons
  max_patient <- result %>% filter(is_max)
  remaining <- result %>% 
    filter(!is_max) %>%
    arrange(desc(.data[[time_a]])) %>%
    # add sequential numbering
    mutate(seq_num = row_number())
  
  # calculate alternating positions
  remaining <- remaining %>%
    # even numbers go 'right' of plot, odd numbers go 'left'
    mutate(side = if_else(seq_num %% 2 == 1, "left", "right"),
           offset = ceiling(seq_num / 2),
           x_location = if_else(side == "left",
                                median_location - offset,
                                median_location + offset))
  
  # combine max person with remaining persons
  result <- bind_rows(max_patient %>% mutate(x_location = median_location),
                      remaining) %>%
    select(-c(is_max, seq_num, side, offset)) %>%
    arrange(x_location)
  
  return(result)
}

