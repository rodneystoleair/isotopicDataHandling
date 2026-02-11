clean_dir_files <- function(path) {
  # gather xlsx and csv files (full paths)
  files <- list.files(path, pattern = ".*\\.xlsx$", full.names = TRUE) %>%
    append(list.files(path, pattern = ".*\\.csv$", full.names = TRUE))
  
  if (length(files) == 0) {
    stop(glue::glue("No files found in {path}."))
  }
  
  # remove Excel temporary files that start with "~$" in the basename
  tmp_mask <- startsWith(basename(files), "~$")
  if (any(tmp_mask)) {
    files <- files[!tmp_mask]
    message(glue::glue("Excel temporary files found and excluded in {path}"))
  } else {
    message(glue::glue("No Excel temporary files found in {path}"))
  }
  
  files
}

read_ea_file <- function(path) {
  readr::read_lines(path, locale = locale(encoding = "UTF-16")) %>%
    discard(~ grepl("^sep=", .x, ignore.case = TRUE)) %>%   # remove sep= line
    paste(collapse = "\n") %>%
    readr::read_tsv(col_types = cols(.default = "c")) %>%   # parse as tab-separated
    mutate(source_file = basename(path))
}

read_irms_file <- function(path) {
  read_excel(path, 
             sheet = "Batch Report", skip = 2, # Skip 2 NA rows only
             col_names = TRUE)
}
