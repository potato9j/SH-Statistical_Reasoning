# 과제 4. 비 온 평일과 안 온 평일을 시간대별로 비교하기
# 필요: 02_datetime.R 의 subway_long(시 열)

# 기상 자료: 빈 강수량은 비가 오지 않은 날로 보고 0으로 채운다(4장 4.5)
weather <- read_csv("../dataset/raw/seoul-temp-raining-2025.csv",
                    locale = locale(encoding = "EUC-KR")) %>%
  transmute(날짜 = as_date(일시),
            강수량 = replace_na(`일강수량(mm)`, 0),
            비 = 강수량 > 0)
nrow(weather)   # 365

nrow(subway_long)                                   # 조인 전: 3,985,800
subway_long <- left_join(subway_long, weather, by = "날짜")
nrow(subway_long)                                   # 조인 후: 그대로여야 한다
sum(is.na(subway_long$비))                          # 못 붙은 행: 0이어야 한다

# 평일 승차만, 날짜 × 시별 서울 전체 합 → 비 × 시별 평균
rain_hourly <- subway_long %>%
  filter(구분 == "승차", !wday(날짜) %in% c(1, 7)) %>%
  group_by(날짜, 시, 비) %>%
  summarise(승차 = sum(인원), .groups = "drop") %>%
  group_by(시, 비) %>%
  summarise(일수 = n(), 평균승차 = mean(승차), .groups = "drop")
count(rain_hourly, 비, 일수)   # 평일 중 비 온 날 / 안 온 날 일수

rain_effect <- rain_hourly %>%
  select(-일수) %>%
  pivot_wider(names_from = 비, values_from = 평균승차, names_prefix = "비_") %>%
  mutate(차이율 = (비_TRUE / 비_FALSE - 1) * 100)
print(rain_effect, n = 20)

slice_min(rain_effect, 차이율, n = 3)   # 감소율이 가장 큰 시간대
slice_max(rain_effect, 차이율, n = 3)   # 감소율이 가장 작은 시간대

# 결과: 평일 비 온 날 76일, 안 온 날 185일. 모든 시간대에서 4.7~8.3% 줄었다.
#   감소율이 가장 큰 시간대: 24시이후(-8.3%), 21시(-6.2%), 23시(-6.0%) — 늦은 밤.
#   감소율이 가장 작은 시간대: 06시(-4.7%), 18시(-5.0%), 11시(-5.0%).
#   낮(09~15시)은 -5.0~-5.6%로 출퇴근 시간대(-5.0~-5.5%)와 거의 같다.

ggplot(rain_effect, aes(x = 시, y = 차이율)) +
  geom_col(fill = accent, width = 0.7) +
  hour_axis +
  scale_y_continuous(labels = ~ paste0(.x, "%")) +
  labs(title = "비 온 평일의 승차 증감률",
       x = NULL, y = NULL,
       caption = "* 비 온 평일 평균 ÷ 안 온 평일 평균 − 1. 평일 76일(비) / 185일(맑음), 요일 기준.")
ggsave("output/figures/04_rain_effect.png", width = 9, height = 4.5, dpi = 150)
