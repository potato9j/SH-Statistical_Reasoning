# 과제 3. 평일의 하루는 어떤 모양인가
# 필요: 02_datetime.R 의 subway_long(시 열)

# 승차만 골라 날짜 × 시별로 전 역을 더한다(서울 전체). 요일만으로 평일/주말을 나눈다(공휴일은 과제 6).
hourly <- subway_long %>%
  filter(구분 == "승차") %>%
  group_by(날짜, 시) %>%
  summarise(승차 = sum(인원), .groups = "drop") %>%
  mutate(요일구분 = if_else(wday(날짜) %in% c(1, 7), "주말", "평일"))
nrow(hourly)   # 365일 × 20 = 7,300

profile <- hourly %>%
  group_by(요일구분, 시) %>%
  summarise(평균승차 = mean(승차), .groups = "drop_last") %>%
  mutate(비율 = 평균승차 / sum(평균승차) * 100) %>%   # 하루 합 대비 %
  ungroup()
filter(profile, 요일구분 == "평일") %>% print(n = 20)
filter(profile, 요일구분 == "주말") %>% slice_max(평균승차, n = 3)   # 주말 상위 3개 시

# 결과(평일): 봉우리는 둘이다. 08시(08-09시간대) 46.2만 명으로 하루의 9.4%, 18시(18-19시간대) 56.9만 명으로 11.6%.
#   출근 07~08시와 퇴근 17~18시 네 시간대만 더해도 하루의 38.1%다.
# 결과(주말): 출퇴근 봉우리가 없고 16시(8.4%)를 꼭대기로 낮 내내 완만하다. 11~14시는 오히려 주말이 평일보다 많다.

dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

ggplot(profile, aes(x = 시, y = 평균승차 / 1e4, colour = 요일구분)) +
  geom_line(linewidth = 1.1) +
  hour_axis +
  scale_y_continuous(labels = ~ paste0(.x, "만")) +
  scale_colour_manual(values = c(평일 = accent, 주말 = muted), breaks = c("평일", "주말")) +
  labs(title = "시간대별 평균 승차 인원",
       x = NULL, y = NULL,
       caption = "* 서울 1~8호선 승차, 2025년 일 평균. 가로축은 시각(~6은 06시 이전, 24~는 24시 이후).")
ggsave("output/figures/03_hourly_profile.png", width = 9, height = 4.5, dpi = 150)
