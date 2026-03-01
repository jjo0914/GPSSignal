# GPS Signal
고정된 수신기 위치의 GPS L1 C/A 신호를 생성하는 MATLAB 코드입니다<br>

원하는 날짜와 시간대의 GPS RINEX V3 파일을 https://cddis.nasa.gov/archive/gnss/ 에서 다운로드 한 후
메인 스크립트내의 변수들을 원하는 값들로 수정합니다<br>

대표변수<br>
sampleRate: GPS신호를 생성할 샘플링 주파수<br>
maximumsat: 신호에 반영할 최대 위성 수<br>
waveDuration: 신호가 시뮬레이션하는 총 시간(s)<br>
rinexFileName: 다운로드한 RINEX파일 이름<br>
rxlla:신호가 시뮬레이션 하는 수신기 위치<br>

# GNSS-SDR 검증 
GNSS-SDR 소프트웨어를 사용하여 생성한 Baseband GPS 신호를 검증했습니다
2026년 2월 25일에 올라온 RINEX파일을 사용했고 수신기 위치는 도쿄 (35.682074,139.767112,8)로 설정했습니다.






SDRGPSSignalV4.m: 메인 스크립트
HelplerGNSSChannel.m: MATLAB에서 제공하는 예제파일입니다 연산을 줄이기 위해 수정했습니다
Helper
