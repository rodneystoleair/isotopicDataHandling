library(tidyverse)
library(tidypaleo)

isotope_plot = isotope_data |> 
  pivot_longer(
    cols = colnames(select(isotope_data, -depth)),
    names_to = "var",
    values_to = "value"
  )

plot <- ggplot2::ggplot(
  isotope_plot,
  aes(
    x = value,
    y = depth,
    color = var
  )
) +
  geom_lineh(size = 0.4) +
  scale_y_reverse() +
  facet_geochem_gridh(vars(var)) +
  theme_paleo() +
  theme(legend.position = "bottom") +
  rotated_axis_labels(45)

plot
