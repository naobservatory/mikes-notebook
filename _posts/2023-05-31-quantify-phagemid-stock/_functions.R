
read_qpcr_results <- function(file) {
  results <- file %>%
    readxl::read_excel(
      sheet = "Results",
      skip = 42,
      na = c("NA", "N/A", "Undetermined"),
    ) %>%
    janitor::clean_names() %>%
    mutate(
      across(target_name, as.factor),
      across(ct, as.numeric),
      across(c(well, baseline_start, baseline_end), as.integer),
    )

  results
  }

#' @start integer indicating the row number where the amplification data header starts
#' @results logical indicating whether to join the amplification data with the results data
read_qpcr_amplification <- function(file, start, results = TRUE) {
  amp <- file %>%
    readxl::read_excel(
      sheet = 'Amplification Data',
      skip = start - 1,
      col_types = c('numeric', 'text', 'numeric', 'text', 'numeric', 'numeric')
    ) %>%
    janitor::clean_names() %>%
    mutate(across(cycle, as.integer))

  if (results) {
    results <- read_qpcr_results(file)
    amp <- amp %>% 
      left_join(results, by = c('well', 'well_position', 'target_name'))
  }

  amp
}

