library(HistData)
library(showtext)
library(tidyverse)

# 1. 데이터 불러오기
data(Nightingale)

# 2. 데이터 크기(행과 열의 수) 확인
cat("=== 행과 열의 수 ===\n")
cat("행 수:", nrow(Nightingale), "/ 열 수:", ncol(Nightingale), "\n\n")

# 3. 열 이름과 자료형 확인
cat("=== 열 이름과 자료형 ===\n")
str(Nightingale)
cat("\n")

# 4. 처음 6행 값 확인
cat("=== 처음 6행의 값 ===\n")
print(head(Nightingale, 6))
cat("\n")

# 5. 사망률 계산 검증 (1854년 4월 데이터 기준)
# 공식: 연간 1,000명당 사망률 = 12 * 1000 * (사망자 수) / (평균 병력), 소수점 첫째 자리 반올림
sample_row <- Nightingale[1, ]
cat("=== 1854년 4월 사망률 계산 직접 검증 ===\n")
cat("날짜 (Date):", as.character(sample_row$Date), "\n")
cat("평균 병력 (Army):", sample_row$Army, "명\n")

# 질병(Disease)
calc_disease <- round(12 * 1000 * sample_row$Disease / sample_row$Army, 1)
cat("질병 사망자 수:", sample_row$Disease, "명 | 기록된 Disease.rate:", sample_row$Disease.rate,
    "| 직접 계산(12*1000*1/8571):", calc_disease, "\n")

# 부상(Wounds)
calc_wounds <- round(12 * 1000 * sample_row$Wounds / sample_row$Army, 1)
cat("부상 사망자 수:", sample_row$Wounds, "명 | 기록된 Wounds.rate:", sample_row$Wounds.rate,
    "| 직접 계산(12*1000*0/8571):", calc_wounds, "\n")

# 기타(Other)
calc_other <- round(12 * 1000 * sample_row$Other / sample_row$Army, 1)
cat("기타 사망자 수:", sample_row$Other, "명 | 기록된 Other.rate:", sample_row$Other.rate,
    "| 직접 계산(12*1000*5/8571):", calc_other, "\n\n")

# ==============================================================================
# 1단계: 그림에 쓸 자료 준비 (긴 모양 변환 및 한글 글꼴 설정)
# ==============================================================================
# 한글 글꼴 설정 (Noto Sans KR)
font_add_google("Noto Sans KR", "Noto Sans KR")
showtext_auto()
showtext_opts(dpi = 300)

# 저장 폴더 생성
dir.create("dataset/working", recursive = TRUE, showWarnings = FALSE)
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

# 데이터 가공 전후 행 수 출력
cat("=== 1단계: 자료 가공 전후 행 수 ===\n")
cat("가공 전 행 수:", nrow(Nightingale), "\n")

# 날짜와 세 사망 원인의 사망률 열 선택 후 긴 모양으로 변환
rose_data <- Nightingale %>%
  select(Date, Disease.rate, Wounds.rate, Other.rate) %>%
  pivot_longer(
    cols = c(Disease.rate, Wounds.rate, Other.rate),
    names_to = "사망 원인",
    values_to = "사망률"
  ) %>%
  mutate(
    Date = as.Date(Date),
    `사망 원인` = factor(`사망 원인`,
      levels = c("Disease.rate", "Wounds.rate", "Other.rate"),
      labels = c("질병", "부상", "기타")
    )
  )

cat("가공 후 행 수:", nrow(rose_data), "\n\n")

# 정리한 자료 저장
write.csv(rose_data, "dataset/working/11_rose_data.csv", row.names = FALSE)

cat("가공된 자료 처음 몇 줄:\n")
print(head(rose_data, 6))
cat("\n")

# ==============================================================================
# 2단계: 월별 세 사망 원인 사망률 막대그래프
# ==============================================================================
p_bar <- ggplot(rose_data, aes(x = factor(Date), y = `사망률`, fill = `사망 원인`)) +
  geom_col() +
  theme(
    text = element_text(family = "Noto Sans KR"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave(
  filename = "output/figures/11_rose_1_bar.png",
  plot = p_bar,
  width = 8,
  height = 5,
  dpi = 300
)

# ==============================================================================
# 3단계: 극좌표계 변환 (원 둘레로 감기)
# ==============================================================================
# 원 둘레 라벨 겹침 방지를 위해 수평 배치 및 연도/월 2줄 표시 적용
p_polar <- p_bar +
  coord_polar() +
  scale_x_discrete(labels = function(x) {
    paste0(substr(x, 1, 4), "\n", as.integer(substr(x, 6, 7)), "월")
  }) +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5, size = 8)
  )

ggsave(
  filename = "output/figures/11_rose_2_polar.png",
  plot = p_polar,
  width = 7.5,
  height = 7.5,
  dpi = 300
)

# ==============================================================================
# 5단계: 중심에서 시작하는 쐐기 겹쳐 그리기 및 넓이 비례 변환
# ==============================================================================
cat("=== 5단계: 큰 쐐기가 가리지 않도록 정렬 ===\n")
cat("정렬 전 행 수:", nrow(rose_data), "\n")
rose_ordered <- rose_data %>%
  arrange(Date, desc(`사망률`))
cat("정렬 후 행 수:", nrow(rose_ordered), "\n\n")

p_area <- ggplot(rose_ordered, aes(x = factor(Date), y = `사망률`, fill = `사망 원인`)) +
  geom_col(position = "identity", width = 1) +
  scale_y_sqrt() +
  coord_polar() +
  scale_x_discrete(labels = function(x) {
    paste0(substr(x, 1, 4), "\n", as.integer(substr(x, 6, 7)), "월")
  }) +
  theme(
    text = element_text(family = "Noto Sans KR"),
    axis.text.x = element_text(angle = 0, hjust = 0.5, size = 8)
  )

ggsave(
  filename = "output/figures/11_rose_3_area.png",
  plot = p_area,
  width = 7.5,
  height = 7.5,
  dpi = 300
)

# ==============================================================================
# 6단계: 두 해로 나눠 나란히 놓기 (패싯 분할)
# ==============================================================================
cat("=== 6단계: 기간 분할 및 12개월 레벨 설정 ===\n")
cat("가공 전 행 수:", nrow(rose_ordered), "\n")

month_order <- paste0(c(4:12, 1:3), "월")
rose_faceted <- rose_ordered %>%
  mutate(
    Month_kor = factor(paste0(as.integer(format(Date, "%m")), "월"), levels = month_order),
    Period = factor(
      ifelse(Date < as.Date("1855-04-01"), "1854년 4월 ~ 1855년 3월", "1855년 4월 ~ 1856년 3월"),
      levels = c("1854년 4월 ~ 1855년 3월", "1855년 4월 ~ 1856년 3월")
    )
  )

cat("가공 후 행 수:", nrow(rose_faceted), "\n\n")

p_facet <- ggplot(rose_faceted, aes(x = Month_kor, y = `사망률`, fill = `사망 원인`)) +
  geom_col(position = "identity", width = 1) +
  scale_y_sqrt() +
  coord_polar(start = 3 * pi / 2) +
  facet_wrap(~ Period) +
  theme(text = element_text(family = "Noto Sans KR"))

ggsave(
  filename = "output/figures/11_rose_4_facet.png",
  plot = p_facet,
  width = 10,
  height = 5,
  dpi = 300
)

# ==============================================================================
# 7단계: 두 원의 자리 바꾸기 (원본처럼 최근 해를 왼쪽, 이전 해를 오른쪽에 배치)
# ==============================================================================
cat("=== 7단계: 패싯 배치 교체를 위한 levels 순서 변경 ===\n")
cat("변경 전 행 수:", nrow(rose_faceted), "\n")

rose_swap <- rose_faceted %>%
  mutate(
    Period = factor(
      Period,
      levels = c("1855년 4월 ~ 1856년 3월", "1854년 4월 ~ 1855년 3월")
    )
  )

cat("변경 후 행 수:", nrow(rose_swap), "\n\n")

p_swap <- ggplot(rose_swap, aes(x = Month_kor, y = `사망률`, fill = `사망 원인`)) +
  geom_col(position = "identity", width = 1) +
  scale_y_sqrt() +
  coord_polar(start = 3 * pi / 2) +
  facet_wrap(~ Period) +
  theme(text = element_text(family = "Noto Sans KR"))

ggsave(
  filename = "output/figures/11_rose_5_swap.png",
  plot = p_swap,
  width = 10,
  height = 5,
  dpi = 300
)

# ==============================================================================
# 8단계: 최종 다듬기 (색상, 테두리, 제목/부제/출처, 테마 설정)
# ==============================================================================
# 150 dpi 저장 규격에 맞춰 showtext 렌더링 해상도를 150 DPI로 전환
showtext_opts(dpi = 150)

p_final <- ggplot(rose_swap, aes(x = Month_kor, y = `사망률`, fill = `사망 원인`)) +
  geom_col(position = "identity", width = 1, color = "gray20", linewidth = 0.25) +
  scale_y_sqrt() +
  coord_polar(start = 3 * pi / 2) +
  facet_wrap(~ Period) +
  scale_fill_manual(
    values = c(
      "질병" = "#85AEC7",
      "부상" = "#E59086",
      "기타" = "#525252"
    )
  ) +
  labs(
    title = "동방 주둔 영국군의 사망 원인",
    subtitle = "각 쐐기의 넓이는 1,000명당 연간 환산 사망률에 비례함",
    caption = "자료: Florence Nightingale (1858) / HistData 패키지",
    fill = "사망 원인",
    x = NULL,
    y = NULL
  ) +
  theme_minimal(base_family = "Noto Sans KR") +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    axis.title = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    axis.text.x = element_text(size = 8, color = "gray15"),
    strip.text = element_text(face = "bold", size = 11, margin = margin(b = 6)),
    legend.position = "bottom",
    legend.title = element_text(face = "bold", size = 9),
    legend.text = element_text(size = 9),
    legend.margin = margin(t = -5, b = 2),
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5, margin = margin(t = 5, b = 4)),
    plot.subtitle = element_text(size = 9.5, hjust = 0.5, color = "gray30", margin = margin(b = 8)),
    plot.caption = element_text(size = 7.5, color = "gray45", margin = margin(t = 6, r = 8)),
    panel.spacing = unit(1.2, "lines"),
    plot.margin = margin(t = 10, r = 12, b = 10, l = 12)
  )

ggsave(
  filename = "output/figures/11_rose_6_final.png",
  plot = p_final,
  width = 8,
  height = 5,
  dpi = 150
)
