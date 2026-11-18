# 과제 6. 공휴일을 반영하면 달라지는가
# 필요: 03_weekday_profile.R 의 hourly(날짜 × 시 승차), 04_rain_by_hour.R 의 weather

# 출처: 공공데이터포털 공휴일 자료(data/OPENDATA_KOR_holidays_2025.csv, EUC-KR). 주말에 겹친 공휴일은 빠져 있다.
holidays <- read_csv("data/OPENDATA_KOR_holidays_2025.csv", locale = locale(encoding = "EUC-KR")) %>%
  filter(연도 == 2025) %>%
  pull(공휴일)
length(holidays)   # 17

day_type <- weather %>%
  mutate(주말 = wday(날짜) %in% c(1, 7),
         휴일 = 날짜 %in% holidays,   # 날짜형끼리 비교
         쉬는날 = 주말 | 휴일)
nrow(day_type)                         # 365
sum(day_type$휴일)                     # 휴일이 참인 날: 17
sum(day_type$휴일 & !day_type$주말)    # 그중 원래 평일로 분류된 날: 17(주말 공휴일은 목록에 없음)
filter(day_type, 휴일, 비)             # 공휴일에 비가 온 날

# 요일 기준(주말만 뺀 평일)과 쉬는날 기준(주말·공휴일을 뺀 일하는 날)을 나란히 계산
nrow(hourly)                                        # 7,300
hourly_day <- left_join(hourly, day_type, by = "날짜")
nrow(hourly_day)                                    # 그대로 7,300
sum(is.na(hourly_day$비))                           # 0

both <- bind_rows(요일 = filter(hourly_day, !주말),
                  쉬는날 = filter(hourly_day, !쉬는날),
                  .id = "기준")
count(both, 기준, 비) %>% mutate(일수 = n / 20)     # 기준별 비 온 날 / 안 온 날 일수

# (1) 6장 세 번째 시도 + 과제 5의 범위별 차이율
both %>%
  group_by(기준, 날짜, 비) %>%
  summarise(하루 = sum(승차),
            일과_09_15 = sum(승차[시 %in% 9:15]),
            일과_10_14 = sum(승차[시 %in% 10:14]),
            출퇴근 = sum(승차[시 %in% c(7, 8, 17, 18)]),
            .groups = "drop") %>%
  group_by(기준, 비) %>%
  summarise(across(하루:출퇴근, mean), .groups = "drop_last") %>%
  summarise(across(하루:출퇴근, ~ (.x[비] / .x[!비] - 1) * 100))

# (2) 과제 4의 시간대별 감소율 비교표
rain_compare <- both %>%
  group_by(기준, 시, 비) %>%
  summarise(평균승차 = mean(승차), .groups = "drop_last") %>%
  summarise(차이율 = (평균승차[비] / 평균승차[!비] - 1) * 100, .groups = "drop")
rain_compare %>%
  pivot_wider(names_from = 기준, values_from = 차이율) %>%
  mutate(변화 = 쉬는날 - 요일) %>%
  print(n = 20)

rain_compare %>%
  mutate(기준 = if_else(기준 == "요일", "공휴일 반영 전", "공휴일 반영 후")) %>%
  ggplot(aes(x = 시, y = 차이율, fill = 기준)) +
  geom_col(position = position_dodge(width = 0.75), width = 0.7) +
  hour_axis +
  scale_y_continuous(labels = ~ paste0(.x, "%")) +
  scale_fill_manual(values = c(`공휴일 반영 전` = muted, `공휴일 반영 후` = accent)) +
  labs(title = "공휴일 반영 전후 승차 증감률",
       x = NULL, y = NULL,
       caption = "* 비 온 평일 평균 ÷ 안 온 평일 평균 − 1. 반영 후는 주말과 공휴일 17일을 뺀 일하는 날 기준.")
ggsave("output/figures/06_rain_effect_holiday.png", width = 9, height = 4.5, dpi = 150)

# 결과
# - 휴일 17일, 모두 원래 평일로 분류된 날. 그중 비 온 날 7일(1/27·1/28·1/29·3/3·10/3·10/6·10/7).
# - 평일 일수: 요일 기준 비 76일 / 안 옴 185일 → 쉬는날 기준 69일 / 175일.
# - 6장 세 번째 시도(하루): -5.43% → -2.61%. 감소율이 절반 아래로 줄어 결론의 크기가 바뀐다.
# - 과제 4 감소율: 모든 시간대에서 1.9~3.5%p 작아졌다. 가장 큰 곳은 여전히 24시이후(-4.8%),
#   가장 작은 곳은 06시(-1.6%), 18시(-1.7%), 08시(-1.8%)로 출퇴근 시간대다.
# - 과제 5 다시 판단: 쉬는날 기준으로는 낮(09~15시 -3.1%, 10~14시 -3.2%)이 출퇴근(-2.0%)보다 더 줄고,
#   하루 합계(-2.6%)는 그 사이다. 요일 기준에서는 보이지 않던 차이가 나타나 주장을 일부 뒷받침한다.
# - 이유: 비 온 공휴일 7일은 승차가 적은 쉬는 날인데 "비 온 평일"에 섞여 비 온 날 평균을 끌어내렸다(쉬는 날이 비 온 쪽에 더 많이 섞임: 7/76 vs 10/185).
#   공휴일에는 특히 출퇴근 승차가 크게 비므로 출퇴근 감소율이 더 부풀려졌고(빼자 07·08·17·18시는 2.9~3.5%p 축소, 11~15시는 1.9~2.1%p),
#   그래서 요일 기준에서는 출퇴근과 낮이 비슷해 보였다. 공휴일을 빼자 비의 효과가 작아지고 시간대 차이가 드러났다.
