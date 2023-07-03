# cleaning operation applied to results and amplification csv files
clean_common <- function(x) {
  x %>%
    janitor::clean_names() %>%
    separate(well_position, into = c('row', 'column'), sep = 1, remove = FALSE) %>%
    mutate(
      # for column, coerce to integer first to remove leading zeros
      across(column, ~as.integer(.x) %>% ordered(levels = 1:12)),
      across(row, ~ordered(.x, levels = LETTERS[1:8])),
    )
}

read_qpcr_results_csv <- function(file) {
  # Plain results files (no standard curve calibration) have fewer columns.
  # We'll get the col types spec for just the present columns by seeing which
  # columns are present, and selecting just those files from `cts_results_all`
  cns <- file %>%
    read_csv(
      comment = '#',
      n_max = 0,
      show_col_types = FALSE,
      progress = FALSE
    ) %>%
    names

  cts <- cts_results_all
  cts$cols <- cts$cols[intersect(names(cts$cols), cns)]

  file %>%
    readr::read_csv(
      comment = '#',
      col_types = cts,
    ) %>%
    clean_common() %>%
    mutate(
      cq = ifelse(cq == 'Undetermined', NA, cq) %>% as.numeric,
      cq_status = ifelse(is.na(cq), 'Undetermined', 'Determined'),
    )
  }

read_qpcr_amplification_csv <- function(file) {
  file %>%
    readr::read_csv(
      comment = '#',
      col_types = cts_amp,
    ) %>%
    clean_common()
  }


# Column type specs -----------

# Column types for the 'Results' CSV file
cts_results <- cols(
  Well = 'i',
  `Well Position` = 'c',
  Sample = 'c',
  Target = 'c',
  Task = 'c',
  Reporter = 'c',
  Quencher = 'c',
  `Amp Status` = 'c',
  # Cq is either a number or 'Undetermined', so read in as a character
  Cq = 'c',
  `Cq Mean` = 'n',
  `Cq Confidence` = 'n',
  `Cq SD` = 'n',
  `Auto Threshold` = 'l',
  Threshold = 'n',
  `Auto Baseline` = 'l',
  `Baseline Start` = 'i',
  `Baseline End` = 'i',
  Omit = 'l'
)

# Additional columns in the 'Standard Curve Result' CSV file
cts_results_sc <- cols(
  Quantity = 'n',
  Dye = 'c',
  `Quantity Mean` = 'n',
  `Quantity SD` = 'n',
# Tm1
# Tm2
# Tm3
# Tm4
  `Y-Intercept` = 'n',
  R2 = 'n',
  Slope = 'n',
  Efficiency = 'n',
  `Standard Deviation` = 'n',
  `Standard Error` = 'n',
)

# Combine the above to get columns in the 'Standard Curve Result' CSV file
cts_results_all <- cols()
cts_results_all$cols <- c(cts_results$cols, cts_results_sc$cols)


# Column types for the amplification curves
cts_amp <- cols(
  Well = 'i',
  `Well Position` = 'c',
  `Cycle Number` = 'i',
  Target = 'c',
  Rn = 'n',
  dRn = 'n',
  Sample = 'c',
  Omit = 'l'
)
