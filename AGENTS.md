# 이 프로젝트의 규칙
- dataset/raw 의 파일은 읽기만 한다. 수정하거나 지우지 않는다.
- 정리한 데이터는 dataset/working 에, 그림은 output 에 저장한다.
- Python은 uv 가상환경(.venv, Python 3.12)을 쓴다.
  패키지는 uv add 로만 설치하고 pip install 은 쓰지 않는다.
- R은 tidyverse, Python은 pandas와 matplotlib만 쓴다.
- 코드를 고칠 때는 무엇을 왜 바꿨는지 한 줄로 설명한다.
- 데이터를 바꾸는 작업 전후에는 행 수를 출력해서 보여준다.

<br>

# 시각화를 위한 규칙

이 폴더에서는 R과 ggplot2로 그림을 그린다.

## 환경
- 시각화는 ggplot2 을 사용하고, 한글 글꼴은 showtext 의 font_add_google() 로 Noto Sans KR 을 등록하고 사용한다. 다른 패키지가 필요하면 먼저 이유를 말하고 내 허락을 받은 뒤 install.packages() 로 설치한다.
- R 스크립트는 scripts/ 폴더에 06_cars.R 처럼 번호를 붙여 만들고, 작업 폴더 맨 위에서 터미널로 Rscript 를 써서 실행한다(Windows PowerShell 에서는 Rscript.exe).
- 여러 스크립트가 함께 불러 쓰는 파일(바탕 그림, 공통 테마)은 프롬프트가 정한 이름 그대로 둔다(예: scripts/07_base_plot.R, scripts/theme_project.R).
- 모든 결과물은 작업 폴더 맨 위의 output/ 폴더에 저장한다. 그림은 ggsave() 로 output/figures/ 폴더에 PNG로 저장한다. 폴더가 없으면 만든다.
- 내 자료의 원본은 dataset/raw/ 에 두고 고치지 않는다. 다듬은 자료는 dataset/working/ 에 저장한다.

## 진행 방식
- 내가 시킨 것만 바꾼다. 시키지 않은 구성요소(테마, 색, 축 범위 등)는 기본값이나 지금 상태 그대로 둔다.
- 스크립트를 고치면 바뀐 줄을 보여 주고, 다시 실행해 그림을 저장한다.
- 새로 쓴 함수마다 그 함수가 그림의 어느 구성요소(data, aes, geom, stat, position, scale, coord, facet, guide, labs, theme)를 바꾸는지 한 줄로 설명한다.
- 확실하지 않은 함수나 인수는 지어내지 말고 확실하지 않다고 말한다.

<br>

## 다음 사항은 사용자의 요청이 있을 경우에만 따른다.
- A. 현재까지 작업을 누적하여 일자별+작업별로 `handsoff.md` 파일을 통해 관리한다.
- B. 각 작업 단계별로 사용자의 승인여부를 확인한다. 승인이 있을 경우에만 다음 단계 작업을 실시한다.
- C. 사용자가 지시한 작업을 이행하기 전에, 어떤 방식으로 작업을 할 것인지 구체적으로 설명 후, 사용사의 컨펌을 받은 후 작업 실시한다.