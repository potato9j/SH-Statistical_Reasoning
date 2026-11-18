# 과제 1. 넓은 형식을 긴 형식으로
# 과제 1~8은 01 → 08 순서로 같은 R 세션에서 실행한다(앞 파일이 만든 객체를 이어서 쓴다).

library(tidyverse)
library(showtext)   # 그림의 한글 글꼴: 03 이후 모든 그림이 쓰므로 여기서 한 번 등록한다
font_add_google("Noto Sans KR", "noto")
showtext_auto()
showtext_opts(dpi = 150)
# 모든 그림 공통 스타일: 흰 배경, 연한 가로 격자만, 굵은 왼쪽 제목, 회색 축 글자, 하단 작은 * 설명
theme_set(theme_minimal(base_size = 12, base_family = "noto") +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_line(colour = "#E6E6E6", linewidth = 0.4),
        axis.text = element_text(colour = "#6E6E6E"),
        axis.title = element_blank(),   # 축 제목 대신 눈금에 단위를 붙인다
        plot.title = element_text(face = "bold", size = 15, margin = margin(b = 12)),
        plot.title.position = "plot",
        plot.caption = element_text(colour = "#8C8C8C", size = 8.5, hjust = 0, margin = margin(t = 10)),
        plot.caption.position = "plot",
        legend.position = "top", legend.justification = "left",
        legend.title = element_blank(), legend.text = element_text(colour = "#4D4D4D"),
        plot.margin = margin(16, 16, 12, 16)))
accent <- "#10A37F"   # 강조 색
muted <- "#C8C8C8"    # 비교 대상 색
hour_axis <- scale_x_continuous(breaks = 5:24, labels = c("~6", 6:23, "24~"))   # 시간대 x축(5 = 06시이전, 24 = 24시이후)

# 작업 폴더를 midterm_exam으로 맞춘다(code 폴더·midterm_exam·상위 ReadTheWorld 어디서 실행해도 같다, PC 경로를 적지 않음)
if (basename(getwd()) == "code") setwd("..")
if (dir.exists("midterm_exam")) setwd("midterm_exam")

subway <- read_csv("../dataset/working/subway_clean.csv")
nrow(subway)        # 바꾸기 전: 199,290

subway_long <- subway %>%
  pivot_longer(`06시이전`:`24시이후`, names_to = "시간대", values_to = "인원")
nrow(subway_long)   # 바꾼 뒤: 3,985,800

# 확인 1: 시간대 열이 20개이므로 20배여야 한다
nrow(subway_long) / nrow(subway)

# 확인 2: 바꾸기 전후 인원 총합이 같아야 한다
sum(select(subway, `06시이전`:`24시이후`)) == sum(subway_long$인원)
