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
iceberg_data <- function(data, patient_id, current_pfs, prior_pfs) {
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
#' convert data from long to wide format for icerberg plot
#' 
#' @param data df in long format where each patient has two rows (prior and current therapy)
#' @param patient_id col name containing patient ids 
#' @param therapy_type col name indicating therapy type with values "prior" and "current" 
#' @param duration col name containing therapy duration/PFS - will be renamed if rename_output = TRUE
#' @param response col name for response categories (optional) - will be renamed if rename_output = TRUE
#' @param rename_output when TRUE, renames duration and response columns to match iceberg plot expectations (default TRUE)
#' @param verbose when TRUE, prints messages about detected varying columns (default TRUE)
#' 
#' @return df in wide format with one row per patient, with:
#'   - all patient-level attributes (columns that do not vary by therapy)
#'   - all therapy-varying columns pivoted with "_prior" and "_current" suffixes
#'   - prior_pfs and sdt_pfs (if rename_output = TRUE)
#'   - prior_response and current_response (if response provided and rename_output = TRUE)
#' 
long_to_wide <- function(data, patient_id, therapy_type, duration, response = NULL,
                         rename_output = TRUE, verbose = TRUE) {
  # check for required packages
  if (!requireNamespace("tidyverse", quietly = TRUE)) {
    stop("package 'tidyverse' needed for this function to work -- please install before running this function")
  }
  
  # find which columns vary within id (between prior/current)
  varying_cols <- data %>%
    group_by(!!sym(patient_id)) %>%
    summarise(across(everything(), ~n_distinct(.x) > 1)) %>%
    select(-!!sym(patient_id)) %>%
    summarise(across(everything(), any)) %>%
    pivot_longer(everything()) %>%
    filter(value) %>%
    pull(name)
  
  # remove therapy_type from varying cols (ie itis the pivot column)
  varying_cols <- setdiff(varying_cols, therapy_type)
  
  if (verbose && length(varying_cols) > 0) {
    message("Detected columns that vary by therapy type: ", 
            paste(varying_cols, collapse = ", "))
  }
  
  # identify true ID columns (those not varying within id)
  all_cols <- colnames(data)
  id_cols <- setdiff(all_cols, c(varying_cols, therapy_type))
  
  # ensure patient_id is in id_cols
  if (!patient_id %in% id_cols) {
    id_cols <- c(patient_id, id_cols)
  }
  
  # perform the pivot with ALL varying columns so that dont end up with multiple rows per id
  wide_data <- data %>%
    pivot_wider(id_cols = all_of(id_cols),
                names_from = all_of(therapy_type),
                values_from = all_of(varying_cols), 
                names_sep = "_")
  
  # should have only one row per id
  n_patients <- n_distinct(data[[patient_id]])
  n_rows <- nrow(wide_data)
  
  if (n_rows != n_patients) {
    stop(paste("pivoting failed: expected", n_patients, "rows but got", n_rows,
               "\nthis might happen if patients have multiple 'prior' or 'current' records"))
  }
  
  # rename key columns if requested
  if (rename_output) {
    rename_vec <- c()
    if (paste0(duration, "_prior") %in% names(wide_data)) {
      rename_vec["prior_pfs"] = paste0(duration, "_prior")
      rename_vec["sdt_pfs"] = paste0(duration, "_current")
    }
    if (!is.null(response) && paste0(response, "_prior") %in% names(wide_data)) {
      rename_vec["prior_response"] = paste0(response, "_prior")
      rename_vec["current_response"] = paste0(response, "_current")
    }
    if (length(rename_vec) > 0) {
      wide_data <- wide_data %>%
        rename(!!!rename_vec)
    }
  }
  
  return(wide_data)
}


## Von Hoff - latest version may 2025
# need to add description
calculate_von_hoff <- function(data, current_response, prior_response, threshold = 1.3) {
  # validate inputs
  if (!all(c(current_response, prior_response) %in% colnames(data))) {
    stop("one or more specified columns not found in data")
  }
  
  # calculate ratio
  result <- data
  result$von_hoff_ratio <- result[[current_response]] / result[[prior_response]]
  
  # NA if prior_response is 0 
  result$von_hoff_ratio[result[[prior_response]] == 0] <- NA
  
  # exceptional response (NA if ratio is NA)
  result$exceptional_response <- !is.na(result$von_hoff_ratio) & 
    result$von_hoff_ratio >= threshold
  
  return(result)
}



