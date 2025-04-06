# ---------------------- #
# Iceberg plot functions #
# ---------------------- #

## Library
library(tidyverse)

## Reproducibility
set.seed(239) 
sessionInfo()


#' @description
#' generate the iceberg plot
#' 
#' @param data df with iceberg ordering (from prepare_iceberg_data)
#' @param patient_id col name for ids
#' @param current_pfs col name for current treatment PFS (or OS, etc.)
#' @param prior_pfs col name for prior treatment PFS (or OS, etc.)
#' @param current_response col name for response categories (optional)
#' @param title plot title (default "current vs prior treatment")
#' @param subtitle plot subtitle (default NULL)
#' @param ylab label for y axis (default "PFS (months)")
#' @param colours vector of colours for treatments (default green to red colours)
#' @param response_colours vector of colours for response categories
#' @param text_size base text size
#' 
#' @return a beautiful iceberg ggplot2 :)
#' 
iceberg_plot <- function(data, patient_id, current_pfs, prior_pfs,
                                current_response = NULL,
                                title = "current vs prior treatment",
                                subtitle = NULL,
                                ylab = "PFS (months)",
                                colours = c("current" = "#003366", "prior" = "#6699CC"),
                                response_colours = c(
                                  "CR" = "#006400", 
                                  "PR" = "#32CD32",
                                  "SD" = "#FFD700", 
                                  "PD" = "#B22222"),
                                text_size = 11) {
  
  # check ggplot2 is installed
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' needed for this function to work. Please install it.")
  }
  
  # generate current vs prior data cuts
  current_data <- data.frame(
    patient_id = data[[patient_id]],
    pfs = data[[current_pfs]],
    treatment = "current")
  
  prior_data <- data.frame(
    patient_id = data[[patient_id]],
    # pfs negative for below 'waterline'
    pfs = -data[[prior_pfs]],
    treatment = "[rior")
  
  # combine data
  plot_data <- rbind(current_data, prior_data)
  names(plot_data)[1] <- patient_id
  
  # generate iceberg plot
  plot <- ggplot2::ggplot(plot_data, 
                          ggplot2::aes(x = .data[[patient_id]], y = pfs, fill = treatment)) +
    ggplot2::geom_col(position = "identity", width = 0.7) +
    ggplot2::geom_hline(yintercept = 0, colour = "#003366", linewidth = 1.2) +
    ggplot2::scale_fill_manual(values = colours) +
    iceberg_theme(base_size = text_size) +
    ggplot2::labs(title = title,
                  subtitle = subtitle,
                  y = ylab,
                  x = NULL)
  
  # add response colouring if part of the function call
  if (!is.null(current_response) && current_response %in% colnames(data)) {
    # Create annotation data
    annotated_data <- data.frame(patient_id = data[[patient_id]], 
                                 response = data[[current_response]])
    names(annotated_data)[1] <- patient_id
    
    # add response colours to iceberg
    plot <- plot +
      ggplot2::geom_point(data = annotated_data,
                          ggplot2::aes(x = .data[[patient_id]],
                                       # y needs to be at the 'waterline'
                                       y = 0, colour = response), size = 3) +
      ggplot2::scale_colour_manual(values = response_colours, 
                                   name = "Response")
  }
  
  return(plot)
}


#' @description
#' iceberg theme for consistent styling
#' 
#' @param base_size base font size
#' @param base_family base font family
#' 
#' @return ggplot2 theme
#' 
iceberg_theme <- function(base_size = 11, base_family = "") {
  # chekc ggplot2 is installed 
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("package 'ggplot2' needed for this function to work -- please install before using this function")
  }
  
  # iceberg theme
  theme <- ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      # x axis grid lines
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor.x = ggplot2::element_blank(),
      
      # light y axis grid lines
      panel.grid.major.y = ggplot2::element_line(colour = "#DDDDDD", linewidth = 0.5),
      panel.grid.minor.y = ggplot2::element_blank(),
      
      # improve text readsbility
      axis.text.y = ggplot2::element_text(size = base_size * 0.9, colour = "black"),
      axis.text.x = ggplot2::element_text(size = base_size * 0.9, colour = "black", 
                                          angle = 45, hjust = 1),
      
      # make title and subtitle bigger
      plot.title = ggplot2::element_text(size = base_size * 1.5, 
                                         face = "bold", 
                                         hjust = 0.5,
                                         margin = ggplot2::margin(b = 10)),
      plot.subtitle = ggplot2::element_text(size = base_size * 1.2,
                                            hjust = 0.5,
                                            margin = ggplot2::margin(b = 15)),
      
      # legend go at bottom
      legend.position = "bottom",
      legend.justification = "center",
      legend.box.just = "center",
      legend.margin = ggplot2::margin(t = 10),
      
      # plot margins increased
      plot.margin = ggplot2::margin(15, 15, 15, 15))
  
  return(theme)
}


