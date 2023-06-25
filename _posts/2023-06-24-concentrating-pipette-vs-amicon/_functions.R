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
  file %>%
    readr::read_csv(
      comment = '#',
      col_types = 'iclccccccncccnnnlnlii',
    ) %>%
    clean_common() %>%
    mutate(
      # cq_status = cq,
      cq = ifelse(cq == 'Undetermined', NA, cq) %>% as.numeric,
      cq_status = ifelse(is.na(cq), 'Undetermined', 'Determined'),
    )
  }

read_qpcr_amplification_csv <- function(file) {
  file %>%
    readr::read_csv(
      comment = '#',
      col_types = 'icicnncl',
    ) %>%
    clean_common()
  }

