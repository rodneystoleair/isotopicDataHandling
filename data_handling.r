library(tidyverse)
library(readxl)
library(janitor)
source('R/functions.R')

obj_name = readline('Write your object (core, section) name: ')

# EA: read and bind all CSVs in data/EA, skip temp files and skip files that fail to parse

ea_data_raw <- list.files(paste0("data/EA/", obj_name),
                          pattern = "\\.csv$",
                          full.names = TRUE) %>%
  discard( ~ startsWith(basename(.x), "~$")) %>%             # drop Excel temp files
  map_dfr(read_ea_file)

ea_data = ea_data_raw |> 
  select(Name, `N  [%]`, `C  [%]`, `C/N  ratio`) |> 
  filter(!Name %in% c("Blank", "IAEA-600", "Methionine", 'IAEA600')) |> 
  na.omit()

# IRMS: take the first xlsx (after excluding temp files) and read it
irms_data_raw <- list.files(paste0("data/IRMS/", obj_name),
                          pattern = "\\.xlsx$",
                          full.names = TRUE) |> 
  read_irms_file()

irms_colnames3 = colnames(irms_data_raw)[!grepl("\\.{3}", colnames(irms_data_raw))]
irms_colnames4 = which(apply(irms_data_raw, 1, function(x) any(grepl("Peak.Id", x))))

names = as.character(irms_data_raw[irms_colnames4, ])
names = names[!names == "NA"] |> 
  na.omit() |> 
  as.character()

irms_colnames = c(irms_colnames3, names)

irms_data = irms_data_raw
colnames(irms_data) = irms_colnames

# IRMS data cleaning and left join by sample IDs
irms_data = irms_data %>%  # Skip 2 NA rows
  filter(`Peak Id` == "S1", 
         !Name %in% c("Blank", "IAEA-600", "Methionine", "IAEA600")) |> 
  group_by(Id, Name) %>%
  summarise(
    `d15N (Air)` = first(na.omit(`δ¹⁵N (Air)`)),    # Take first non-NA δ15N value
    `d13C (VPDB)` = first(na.omit(`δ¹³C (VPDB)`)),  # Take first non-NA δ13C value
    .groups = "drop"
  ) %>%
  select(Name, `d15N (Air)`, `d13C (VPDB)`) |> 
  mutate(across(contains('d'), as.numeric)) |> 
  mutate(across(everything(), ~replace_na(.x, 0)))

# final EA and IRMS data frame with depths
depth_question = readline("Do you have core depths? Y/N ")
if (depth_question == 'Y') {
  ages = read_xlsx(paste0('data/agedepth/', obj_name, '_ages.xlsx'))
  
  isotope_data = ea_data |> 
    left_join(irms_data, by = 'Name') |> 
    separate(Name, into = c('core_name', 'n'), sep = '-') |> 
    left_join(ages, by = 'n') |> 
    select(-core_name, -n) |> 
    relocate(depth) |> 
    mutate(across(everything(), as.numeric))
  
  writexl::write_xlsx(isotope_data,
                      paste0('output/', obj_name, '_isotopes.xlsx'))
} else {
  isotope_data = ea_data |> 
    left_join(irms_data, by = 'Name') |> 
    mutate(across(everything(), as.numeric))
  
  writexl::write_xlsx(isotope_data,
                      paste0('output/', obj_name, '_isotopes.xlsx'))
}
