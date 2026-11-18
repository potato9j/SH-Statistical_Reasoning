# install.packages("tidyverse")
library(tidyverse)

ggplot(
  data = cars,
  mapping = aes(
    x = speed,
    y = dist
  )
) +
  geom_point(stat = "identity", position = "identity") +
  scale_x_continuous() +
  scale_y_continuous() +
  coord_cartesian() +
  facet_null() +
  labs(x = "speed", y = "dist") +
  theme_grey()
