# 과제 2. 시간대에서 시각을 꺼내 날짜시각형으로
# 필요: 01_long_format.R 의 subway_long

# 06시이전은 첫차가 다니는 05시대이므로 5, 24시이후는 자정 넘은 막차이므로 24로 두어 시간 순서를 지킨다.
subway_long <- subway_long %>%
  mutate(시 = as.integer(str_extract(시간대, "^\\d+")),
         시 = if_else(시간대 == "06시이전", 5L, 시),
         일시 = as_datetime(날짜) + hours(시))
nrow(subway_long)   # 그대로 3,985,800

distinct(subway_long, 시간대, 시) %>% print(n = 20)   # 20개 시간대 → 시 대응
sum(is.na(subway_long$일시))                         # 0이어야 한다
filter(subway_long, 시간대 %in% c("06시이전", "24시이후")) %>% select(날짜, 시간대, 일시) %>% head(2)
