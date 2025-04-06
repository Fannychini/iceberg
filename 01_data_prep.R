# -------------------------------------------- #
# Data preparation for generating iceberg plot #
# -------------------------------------------- #

## Library
library(tidyverse)

## Reproducibility
set.seed(239) 
sessionInfo()

## Main function ----
#' @description 
#' prepare data for iceberg plot visualisation by calculating the x-axis 
#' locations according to the methodology in Lythgoe et al.
#' 
#' @param data df in *wide* format with one row per id
#' @param patient_id col name for ids
#' @param current_pfs col name for current treatment PFS (or OS, etc.)
#' @param prior_pfs col name for prior treatment PFS (or OS, etc.)
#' 
#' @return a df with added x_location values for each person
#
prepare_iceberg_data <- function(data, patient_id, current_pfs, prior_pfs) {
  # Check input data
  required_cols <- c(patient_id, current_pfs, prior_pfs)
  if (!all(required_cols %in% colnames(data))) {
    stop("missing required columns in data")
  }
  
  # clean df with needed cols
  plot_data <- data.frame(patient_id = data[[patient_id]],
                          current_pfs = data[[current_pfs]],
                          prior_pfs = data[[prior_pfs]])
  
  # get original row numbers to track ids
  plot_data$original_row <- 1:nrow(plot_data)
  
  # step 1 sort id by decreasing prior PFS value = ids with higher values come first
  plot_data <- plot_data[order(plot_data$prior_pfs, decreasing = TRUE), ]
  
  # step 2 create array for x-locations
  n_patients <- nrow(plot_data)
  median_position <- ceiling(n_patients / 2)
  
  # step 3 generate x axis locations
  plot_data$x_location <- rep(NA, n_patients)
  
  # step 4 place id with max prior PFS in the center
  # 1st row is max after sorting
  plot_data$x_location[1] <- median_position 
  
  # step 5 place remaining ids alternating left and right from center
  left_pos <- median_position - 1
  right_pos <- median_position + 1
  
  for (i in 2:n_patients) {
    if ((i %% 2) == 0) {
      # even to the left
      plot_data$x_location[i] <- left_pos
      left_pos <- left_pos - 1
    } else {
      # odd to the right
      plot_data$x_location[i] <- right_pos
      right_pos <- right_pos + 1
    }
  }
  
  # step 6 sort by x axis location
  plot_data <- plot_data[order(plot_data$x_location), ]
  
  # step 7 create factor for id to preserve order
  plot_data$patient_id <- factor(plot_data$patient_id, levels = plot_data$patient_id)
  
  # step 8 nerge back with original data to keep all columns
  # create mapping from original rows to x axis locations
  row_map <- data.frame(original_row = plot_data$original_row,
                        x_location = plot_data$x_location,
                        patient_order = plot_data$patient_id)
  
  # add x axis location to original data
  result <- data
  result$x_location <- NA
  
  for (i in 1:nrow(row_map)) {
    orig_row <- row_map$original_row[i]
    result$x_location[orig_row] <- row_map$x_location[i]
  }
  
  # order result by x axis location
  result <- result[order(result$x_location), ]
  
  # factor id with levels in the correct order
  result[[patient_id]] <- factor(result[[patient_id]], levels = result[[patient_id]])
  
  return(result)
}


# finish write up
#' @description 
#' convert data from long to wide format 
#' 
#' @param data df in long format where each id has multiple rows
#' @param patient_id col name containing ids
#' @param therapy_type col name indicating whether therapy is current or not ("prior", "current")
#' @param duration col name containing therapy duration/PFS
#' @param response column for response categories (optional)
#' 
#' @return df in wide format with one row per id
#' 
long_to_wide <- function(data, patient_id, therapy_type, duration, response = NULL) {
  # Check for required packages
  if (!requireNamespace("tidyverse", quietly = TRUE)) {
    stop("package 'tidyverse' needed for this function to work -- please install before running this function")
  }
  
  # prep value columns to pivot
  value_cols <- duration
  if (!is.null(response)) {
    value_cols <- c(value_cols, response)
  }
  
  # get all other columns (id attributes)
  all_cols <- colnames(data)
  value_and_key_cols <- c(patient_id, therapy_type, value_cols)
  id_cols <- all_cols[!all_cols %in% value_and_key_cols]
  
  # add patient_id to id_cols if not already there
  id_cols <- unique(c(patient_id, id_cols))
  
  # go for pivot
  !TODO
  
  return(wide_data)
}



