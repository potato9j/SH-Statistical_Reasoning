library(tidyverse)

# 1. 출력 디렉터리 생성
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

# 2. 데이터 가공 전후 행 수 출력
cat("데이터 처리 전 행 수:", nrow(mtcars), "\n")

mtcars_clean <- mtcars %>%
  mutate(
    am = factor(am, levels = c(0, 1), labels = c("Automatic", "Manual")),
    cyl = factor(cyl)
  )

cat("데이터 처리 후 행 수:", nrow(mtcars_clean), "\n")

# 3. 산점도 및 추세선 시각화
p <- ggplot(mtcars_clean, aes(x = wt, y = mpg)) +
  geom_point(aes(color = cyl), size = 3.5, alpha = 0.85) +
  geom_smooth(method = "lm", se = FALSE, color = "gray40", linetype = "dashed", linewidth = 0.8) +
  facet_wrap(~ am) +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "Fuel Economy (MPG) by Weight, Cylinders, and Transmission",
    subtitle = "Manual cars have higher MPG overall, largely driven by lower curb weight",
    x = "Weight (1,000 lbs)",
    y = "Fuel Economy (MPG)",
    color = "Cylinders"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "gray30", margin = margin(b = 10)),
    strip.text = element_text(face = "bold", size = 12),
    legend.position = "bottom"
  )

# 4. 그림 저장
ggsave(
  filename = "output/figures/02_mtcars.png",
  plot = p,
  width = 8,
  height = 5,
  dpi = 300
)
