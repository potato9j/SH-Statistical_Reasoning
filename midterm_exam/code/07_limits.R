# 과제 7. 한계 적기
# 필요: 06_holidays.R 의 hourly_day(날짜 × 시 승차 + 비·쉬는날)
# 한계 후보를 자료로 확인할 수 있는 만큼 확인한다(쉬는날 기준 = 일하는 날만).

work_daily <- hourly_day %>%
  filter(!쉬는날) %>%
  group_by(날짜, 비, 강수량) %>%
  summarise(하루 = sum(승차),
            낮 = sum(승차[시 %in% 9:15]),
            출퇴근 = sum(승차[시 %in% c(7, 8, 17, 18)]),
            .groups = "drop") %>%
  mutate(월 = month(날짜))
nrow(work_daily)   # 일하는 날 244일

effect <- function(d) {
  d %>%
    group_by(비) %>%
    summarise(across(c(하루, 낮, 출퇴근), mean)) %>%
    summarise(across(c(하루, 낮, 출퇴근), ~ (.x[비] / .x[!비] - 1) * 100))
}

# (1) 계절: 비 온 날이 달마다 고르지 않다 → 같은 달 안에서만 비교해도 같은가
count(work_daily, 월, 비) %>% pivot_wider(names_from = 비, values_from = n, names_prefix = "비_")
effect(work_daily)                                   # 그냥 비교
work_daily %>%                                       # 달마다 비교한 뒤 일수로 가중 평균
  group_by(월) %>%
  filter(any(비), any(!비)) %>%
  summarise(일수 = n(), effect(pick(everything()))) %>%
  summarise(across(c(하루, 낮, 출퇴근), ~ weighted.mean(.x, 일수)))

# (2) 우연: 낮과 출퇴근 감소율의 차이(약 1%p)가 우연으로 생길 수 있는 크기인가 → 날짜를 다시 뽑아(부트스트랩) 95% 구간
set.seed(2025)
boot <- map_dfr(1:1000, ~ work_daily %>%
                  group_by(비) %>%
                  slice_sample(prop = 1, replace = TRUE) %>%
                  ungroup() %>%
                  effect())
boot %>%
  mutate(낮_빼기_출퇴근 = 낮 - 출퇴근) %>%
  summarise(across(everything(), ~ list(round(quantile(.x, c(0.025, 0.975)), 2)))) %>%
  unnest(everything())

# (3) 강수량은 하루 합계: 비 온 날 중 1mm 미만(거의 안 온 날)이 얼마나 되나
work_daily %>% filter(비) %>% summarise(비온날 = n(), `1mm 미만` = sum(강수량 < 1))

# ==== 한계(핵심 위주) ====
# [치명적] 우연과 구별되지 않는 차이: 일하는 날 244일 중 비 온 날 69일뿐이다. 부트스트랩 95% 구간에서
#   하루 감소율은 -4.4~-1.1%로 0을 넘지 않지만, "낮 - 출퇴근" 차이(-1.1%p)는 -2.9~+1.1%p로 0을 포함한다.
#   과제 6의 "낮이 출퇴근보다 더 줄었다"는 이 자료만으로는 우연과 구별할 수 없다.
# [핵심] 계절과 비의 구분: 비 온 일하는 날의 수는 2월 3일·11월 2일에서 8월 9일까지 달마다 다르다.
#   같은 달 안에서만 비교해 가중 평균하면 하루 -2.18%, 낮 -2.88%, 출퇴근 -1.39%로 크기는 줄지만 방향은 같다.
# [핵심] 강수량은 하루 합계: 비 온 69일 중 14일(20%)은 1mm 미만이고, 밤에만 온 비도 "비 온 날"이다.
#   비가 실제로 내린 시간대를 모르므로, 시간대별 감소율은 "그 시각에 비가 왔을 때"의 효과가 아니다.
