library(tidyverse)

# 폴더가 없으면 생성
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

# 산점도 생성
ggplot(cars, aes(x = speed, y = dist)) +
  geom_jitter() +
  geom_smooth(method = "lm") +
  scale_x_continuous(breaks = c(5, 10, 15, 20, 25)) +
  coord_cartesian(ylim = c(0, NA)) +
  labs(
    title = "Speed and stopping distance",
    x = "Speed (mph)",
    y = "Stopping distance (ft)"
  ) +
  theme_minimal(base_size = 14)

# 그림 저장 (7×4.5인치, 300 dpi)
ggsave(
  filename = "output/figures/01_cars_final.png",
  width = 7,
  height = 4.5,
  dpi = 300
)


