# 과제 8. 제출 전 점검: 01~07을 새 R 세션에서 처음부터 순서대로 실행한다(오류 없이 끝나야 한다).
# 실행: code 폴더·midterm_exam·상위 ReadTheWorld 중 어디서든 Rscript.exe 로 실행하거나 R 콘솔에서 source()
# 01이 작업 폴더를 바꾸므로 code 폴더의 절대경로를 먼저 구해 둔다
code_dir <- normalizePath(if (basename(getwd()) == "code") "." else if (dir.exists("code")) "code" else "midterm_exam/code")
for (f in sprintf("%02d_%s.R", 1:7, c("long_format", "datetime", "weekday_profile", "rain_by_hour",
                                       "daytime_judgment", "holidays", "limits"))) {
  source(file.path(code_dir, f), echo = TRUE, max.deparse.length = Inf)
}
