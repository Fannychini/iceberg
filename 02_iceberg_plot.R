# ---------------------- #
# Iceberg plot functions #
# ---------------------- #

## Library
library(tidyverse)

## Reproducibility
set.seed(239) 
sessionInfo()


#' @description
#' generate basic iceberg plot structure
#' 
#' @param data df with iceberg ordering (from `iceberg_data()`)
#' @param patient_id col name for ids
#' @param current_pfs col name for current treatment PFS
#' @param prior_pfs col name for prior treatment PFS
#' @param current_response col name for response categories (optional)
#' 
#' @return an iceberg ggplot2 object (apply `iceberg_theme()` to style it)
#' 
iceberg_plot <- function(data, patient_id, 
                         current_pfs, prior_pfs,
                         current_response = NULL) {
  
  # check ggplot2 is installed
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("you need 'ggplot2' installed for this function to work")
  }
  
  # initialise current vs prior data
  current_data <- data.frame(patient_id = data[[patient_id]],
                             pfs = data[[current_pfs]],
                             treatment = "current")
  
  prior_data <- data.frame(patient_id = data[[patient_id]],
                           # PFS negative for below waterline
                           pfs = -data[[prior_pfs]],
                           treatment = "prior")
  
  # combine data
  plot_data <- rbind(current_data, prior_data)
  names(plot_data)[1] <- patient_id
  
  # create basic iceberg plot structure
  plot <- ggplot2::ggplot(plot_data, 
                          ggplot2::aes(x = .data[[patient_id]], y = pfs, fill = treatment)) +
    ggplot2::geom_col(position = "identity")
  
  # add response colouring if requested
  if (!is.null(current_response) && current_response %in% colnames(data)) {
    # init annotation data
    annotated_data <- data.frame(patient_id = data[[patient_id]], 
                                 response = data[[current_response]])
    names(annotated_data)[1] <- patient_id
    
    # add response points
    plot <- plot +
      ggplot2::geom_point(data = annotated_data,
                          ggplot2::aes(x = .data[[patient_id]],
                                       y = 0, 
                                       colour = response))
  }
  
  return(plot)
}


#' @description
#'custom theme for iceberg plots
#' 
#' @param base_size base font size
#' @param base_family based font family
#' @param grid_colour colour for grid lines
#' @param background_colour background colour
#' 
#' @return a ggplot2 theme object
#' 
iceberg_theme <- function(base_size = 11, 
                          base_family = "",
                          grid_colour = "#DDDDDD",
                          background_colour = "white") {
  
  # check ggplot2 is installed 
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("you need 'ggplot2' installed for this function to work")
  }
  
  # create theme elements 
  theme <- ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      # remove x axis grid lines
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor.x = ggplot2::element_blank(),
      
      # brighter y axis grid lines
      panel.grid.major.y = ggplot2::element_line(colour = grid_colour, linewidth = 0.5),
      panel.grid.minor.y = ggplot2::element_blank(),
      
      # background plot
      panel.background = ggplot2::element_rect(fill = background_colour, colour = NA),
      
      # text readability
      axis.text.y = ggplot2::element_text(size = base_size * 0.9, colour = "black"),
      axis.text.x = ggplot2::element_text(size = base_size * 0.5, colour = "black", 
                                          angle = 45, hjust = 1),
      
      # title and subtitle more prominent
      plot.title = ggplot2::element_text(size = base_size * 1.5, 
                                         face = "bold", 
                                         hjust = 0.5,
                                         margin = ggplot2::margin(b = 10)),
      plot.subtitle = ggplot2::element_text(size = base_size * 1.2,
                                            hjust = 0.5,
                                            margin = ggplot2::margin(b = 15)),
      
      # legend styling
      legend.position = "bottom",
      legend.justification = "center",
      legend.box.just = "center",
      legend.margin = ggplot2::margin(t = 10),
      legend.title = ggplot2::element_text(size = base_size * 0.9),
      legend.text = ggplot2::element_text(size = base_size * 0.8),
      
      # plot margins (increased)
      plot.margin = ggplot2::margin(15, 15, 15, 15)
    )
  
  return(theme)
}



#' @description
#' icebergify your iceberg plot (aka add standard styling elements)
#' 
#' @param plot a ggplot object you want to icebergify
#' @param waterline_colour colour of waterline
#' @param waterline_size width of waterline
#' @param treatment_colours colours for current and prior treatments
#' @param response_colours colours for response categories
#' 
#' @return a beautiful iceberg plot :)
#' 
iceberg_style <- function(waterline_colour = "#4575b4",
                          waterline_size = 1.2,
                          treatment_colours = c("current" = "#91bfdb", "prior" = "#003366"),
                          response_colours = c(
                            "CR" = "#006400", 
                            "PR" = "#32CD32",
                            "SD" = "#FFD700", 
                            "PD" = "#B22222")) {
  
  iceberg_S3(
    waterline_colour = waterline_colour,
    waterline_size = waterline_size,
    treatment_colours = treatment_colours,
    response_colours = response_colours)
}

# seems like I need a method for the ggplot_add generic
#' @export
ggplot_add.iceberg_style <- function(object, plot, object_name) {
  # get the parameters from the style object
  waterline_colour <- object$waterline_colour
  waterline_size <- object$waterline_size
  treatment_colours <- object$treatment_colours
  response_colours <- object$response_colours
  
  # add waterline
  plot <- plot + 
    ggplot2::geom_hline(yintercept = 0, colour = waterline_colour, linewidth = waterline_size)
  
  # add colour scales
  plot <- plot +
    ggplot2::scale_fill_manual(values = treatment_colours)
  
  # add response colour scale if plot has a colour aesthetic
  if ("colour" %in% names(plot$mapping)) {
    plot <- plot + 
      ggplot2::scale_colour_manual(values = response_colours, name = "Response")
  }
  
  return(plot)
}

# S3 class for iceberg styling function
iceberg_S3 <- function(waterline_colour = "#4575b4", 
                       waterline_size = 1.2,
                       treatment_colours = c("current" = "#91bfdb", "prior" = "#003366"),
                       response_colours = c(
                         "CR" = "#006400", 
                         "PR" = "#32CD32",
                         "SD" = "#FFD700", 
                         "PD" = "#B22222")) {
  structure(
    list(waterline_colour = waterline_colour,
         waterline_size = waterline_size,
         treatment_colours = treatment_colours,
         response_colours = response_colours),
    class = "iceberg_style")
}
