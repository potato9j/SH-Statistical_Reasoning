# 패키지 로드 및 설치 확인
if (!requireNamespace("showtext", quietly = TRUE)) {
  install.packages("showtext", repos = "https://cloud.r-project.org")
}
library(showtext)
library(tidyverse)

# 1. Google Fonts 등록 및 showtext 설정
font_add_google("Noto Sans KR", "Noto Sans KR")
showtext_auto()
showtext_opts(dpi = 300)

# 2. 출력 폴더 생성
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

# 3. 데이터 가공 전후 행 수 출력
cat("데이터 처리 전 행 수:", nrow(mtcars), "\n")

mtcars_plot <- mtcars %>%
  rownames_to_column(var = "car_name") %>%
  mutate(
    cyl = factor(cyl, levels = c(4, 6, 8), labels = c("4기통", "6기통", "8기통"))
  )

cat("데이터 처리 후 행 수:", nrow(mtcars_plot), "\n")

# 4. 시각화 생성
p <- ggplot(mtcars_plot, aes(x = wt, y = mpg)) +
  geom_point(aes(color = cyl), size = 3, alpha = 0.85) +
  geom_text(
    aes(label = car_name, color = cyl),
    family = "Noto Sans KR",
    size = 2.5,
    vjust = -0.7,
    show.legend = FALSE
  ) +
  scale_color_brewer(palette = "Set1") +
  scale_x_continuous(expand = expansion(mult = c(0.08, 0.08))) +
  scale_y_continuous(expand = expansion(mult = c(0.05, 0.12))) +
  labs(
    title = "차량 무게에 따른 연비 산점도",
    subtitle = "기통수가 많고 무게가 무거울수록 연비가 낮아지는 경향을 보임",
    x = "차량 무게 (1,000 lbs)",
    y = "연비 (MPG)",
    color = "기통수"
  ) +
  theme_minimal(base_size = 12, base_family = "Noto Sans KR") +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "gray30", margin = margin(b = 10)),
    legend.position = "right"
  )

# 5. 그림 저장
ggsave(
  filename = "output/figures/10_hangul.png",
  plot = p,
  width = 7,
  height = 4.5,
  dpi = 300
)
