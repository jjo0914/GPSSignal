classdef HelperGPSNavigationConfig < comm.internal.ConfigBase
    %HelperGPSNavigationConfig GPS navigation data generation configuration
    %object
    %
    %   Note: This is a helper and its API and/or functionality may change
    %   in subsequent releases.
    %
    %   CFG = HelperGPSNavigationConfig creates a Global Positioning System
    %   (GPS) navigation data generation configuration object. The object
    %   contains the parameters required for generation of GPS navigation
    %   data bits. The parameters are described in detail in Appendix II
    %   and III of IS-GPS-200L [1].
    %  
    %   요약: 이 객체 안에는 GPS 내비게이션 데이터를 만드는 데 필요한 모든 파라미터가 들어 있음.

    %   CFG = HelperGPSNavigationConfig(Name,Value) creates a GPS
    %   navigation data object, CFG, with the specified property Name set
    %   to the specified Value. You can specify additional name-value pair
    %   arguments in any order as (Name1,Value1,...,NameN,ValueN).
    %
    %   HelperGPSNavigationConfig properties:
    %
    %   SignalType                        - Type of the navigation signal
    %   PRNID                             - Pseudo random noise index of
    %                                       satellite
    %   MessageTypes                      - CNAV data message types
    %   FrameIndices                      - LNAV data frame indices
    %   L1CSubframe3PageSequence          - Page sequence for subframe 3 in
    %                                       CNAV-2 data
    %   Preamble                          - Preamble of the navigation data
    %   TLMMessage                        - Telemetry message
    %   HOWTOW                            - Time of week in hand-over word
    %   L1CTOI                            - Time of interval value for L1C
    %   L1CITOW                           - Interval time of week for
    %                                       CNAV-2 data
    %   L1CHealth                         - Health of L1C signal
    %   AntiSpoofFlag                     - Anti spoof flag
    %   CodesOnL2                         - Ranging code on L2 band
    %   L2PDataFlag                       - Indication of presence of
    %                                       navigation data bits with
    %                                       P-code on L2 band
    %   L2CPhasing                        - Phase relationship indicator of
    %                                       L2C signal
    %   SVHealth                          - Satellite vehicle health
    %   SignalHealth                      - L1/L2/L5 signal health
    %                                       indicators
    %   IssueOfDataClock                  - Issue of data clock
    %   URAID                             - User range accuracy index
    %   WeekNumber                        - GPS week number
    %   GroupDelayDifferential            - Group delay differential
    %   SVClockCorrectionCoefficients     - Clock correction coefficients,
    %                                       af0, af1, af2
    %   ReferenceTimeOfClock              - Reference time of clock
    %   SemiMajorAxisLength               - Semi-major axis length of the
    %                                       satellite orbit
    %   ChangeRateInSemiMajorAxis         - Rate of change of semi-major
    %                                       axis length
    %   MeanMotionDifference              - Mean motion difference
    %   RateOfMeanMotionDifference        - Rate of change of mean motion
    %                                       difference
    %   FitIntervalFlag                   - Fit interval flag
    %   Eccentricity                      - Eccentricity of the satellite
    %                                       orbit
    %   MeanAnomaly                       - Mean anomaly at reference time
    %   ReferenceTimeOfEphemeris          - Reference time of ephemeris
    %   HarmonicCorrectionTerms           - Six harmonic correction terms
    %   IssueOfDataEphemeris              - Issue of data ephemeris
    %   IntegrityStatusFlag               - Integrity status flag
    %   ArgumentOfPerigee                 - Argument of perigee at
    %                                       reference time
    %   RateOfRightAscension              - Rate of right ascension
    %   LongitudeOfAscendingNode          - Longitude of ascending node
    %   Inclination                       - Inclination angle of the
    %                                       satellite orbit with respect to
    %                                       equator of Earth
    %   InclinationRate                   - Rate of change of inclination
    %                                       angle
    %   URAEDID                           - Elevation dependent user range
    %                                       accuracy index
    %   InterSignalCorrection             - Inter signal correction terms
    %   ISCL1CP                           - Inter signal correction for L1C
    %                                       pilot signal
    %   ISCL1CD                           - Inter signal correction for L1C
    %                                       data signal
    %   ReferenceTimeCEIPropagation       - Reference time of CEI
    %                                       propagation
    %   ReferenceWeekNumberCEIPropagation - Reference week number of CEI
    %                                       propagation
    %   URANEDID                          - Non-elevation dependent user
    %                                       range accuracy indices
    %   AlertFlag                         - Alert flag
    %   AgeOfDataOffset                   - Age of data offset
    %   NMCTAvailabilityIndicator         - NMCT availability indicator
    %   NMCTERD                           - NMCT ERD values
    %   AlmanacFileName                   - Almanac file name which has 
    %                                       almanac information in SEM
    %                                       format
    %   Ionosphere                        - Structure containing Ionosphere
    %                                       information
    %   EarthOrientation                  - Structure containing Earth's
    %                                       orientation information
    %   UTC                               - Structure containing UTC
    %                                       parameters
    %   DifferentialCorrection            - Structure containing
    %                                       differential correction
    %                                       parameters
    %   TimeOffset                        - Structure containing the
    %                                       parameters related to the time
    %                                       offset of GPS with respect to
    %                                       other GNSS systems
    %   TextMessage                       - Text message in LNAV data
    %   TextInMessageType36               - Text message in CNAV data
    %                                       message type 36
    %   TextInMessageType15               - Text message in CNAV data
    %                                       message type 15
    %   ISM                               - Integrity support message
    %
    %   References:
    %    [1]  IS-GPS-200, Rev: L. NAVSTAR GPS Space Segment/Navigation User
    %         Segment Interfaces. May 14, 2020; Code Ident: 66RP1.
    %
    %    [2] IS-GPS-800, Rev: J. NAVSTAR GPS Space Segment/User segment L1C
    %        Interfaces. Aug 22, 2022; Code Ident: 66RP1.

    %   Copyright 2021-2023 The MathWorks, Inc.

    properties
        %SignalType Data type of the navigation data
        %  Indicate the type of the signal as one of "CNAV" | "LNAV" |
        %  "CNAV2". The default is "CNAV".
        SignalType = "CNAV"
        %PRNID Pseudo random noise index of satellite
        %  Indicate the PRN ID of the satellite as an integer value from 1
        %  to 210. The default is 1.
        PRNID = 1 % 1 ~ 210
        %MessageTypes CNAV data message types
        %  Indicate the message types that needs to be transmitted in that
        %  order either as a column vector or a matrix with number of rows
        %  equal to 4. Navigation data generation happens by considering
        %  the message types as one column vector in column major form.
        %  This property is valid only when SignalType is "CNAV". The default
        %  is chosen such that transmission happens for 12 minutes and the
        %  default value obey the rules given in Section 30.3.4.1 of
        %  IS-GPS-200.

  %  요약: Message Types는 CNAV 데이터에서만 사용하는데 데이터생성시에 MessageTypes값들을 열벡터로 변환한다,.
  %        10: 위성 궤도 정보
  %        11: 위성 시계 보정 파라미터
  %        12: 간략화된 알마낙 (전체 위성 군의 대략적 위치 정보)
  %        30: 시계+궤도 정보 압축형 (보조적 데이터)
  %        32: 전리층 모델(전파의 시간지연 보정 수학모델 -> 서서히 위치스푸핑), UTC 시간 보정 데이터
  %        33: 지구 자전 정보 (GPS 시간과 지구 시간 보정용)
  %        37: 	사용자에게 송출하는 텍스트 메시지
  %        그니깐 총 15*4 개의 메시지타입을 저장하고 1메시지에 12초 60개메시지=12분 전송하겠다.(표준임)
  %        CNAV: Preamble + prnid+ MsgTypes + ....
        MessageTypes = [10 11 37 30; 10 11 32 33; 10 11 12 37; 10 11 12 30; ...
            10 11 12 33; 10 11 12 37; 10 11 12 30; 10 11 32 33; 10 11 37 37; ...
            10 11 32 30; 10 11 12 33; 10 11 12 37; 10 11 12 30; 10 11 12 33; ...
            10 11 12 37].'


        %FrameIndices LNAV data frame indices
        %  Indicate the frame indices that needs to be transmitted in that
        %  order as a vector. This property is valid only when SignalType is
        %  set to "LNAV. The default is an array of integers from 1 to 25.

       % 요약 : FrameIndices 는 LNAV 신호의 데이터 프레임 인덱스을의미= 몇개의 프레임을 생성할것인가?
       % 1프레임=1500bits(30초)  25프레임=12.5분
        FrameIndices = 1:25

        %L1CSubframe3PageSequence Page sequence for subframe 3 in CNAV-2
        %data
        %   Specify the page sequence of subframe 3 for CNAV-2 data. This
        %   property is valid only when SignalType is set to "CNAV2".

      %요약: 더정교한 CNAV2라는 메시지도있는데 CNAV2메시지(600bit)는 서브프레임이존재함
      % 3번째서브프레임(마지막 200비트) 에 넣을 메시지타입?(page sequence) 순서를 차례대로 지정함
      % 4: 	Almanac 데이터
      % 5: 오차 보정 데이터
      % 6: 위성 발신 텍스트 메시지
      % 7: 	SV Configuration
      % 1 2 3 8: 	시스템 관리용 데이터 또는 향후 확장을 위해 예약됨.
      % 즉, 총 49개의 CNAV2 메시지 전송할동한 subframe3 에 들어갈 페이지? 메시지 타입을 지정.

        L1CSubframe3PageSequence = [repmat(4,31,1); ... % Almanac
            7; ... % SV Configuration
            1; 2; 3; 8; ...
            repmat(5,10,1); ... % Differential correction parameters
            repmat(6,3,1)] % Text message


        %Preamble Preamble of the navigation data
        %  Indicate the preamble that needs to be transmitted in the
        %  navigation data. The default is 139. This property is active
        %  when SignalType is set to "LNAV".

        %요약 : LNAV일때만 활성화  Preamble은 할상 139=10001011 로 고정
        Preamble = 139

        %TLMMessage Telemetry message
        %  Indicate the telemetry message that needs to be transmitted in
        %  the LNAV data. This property is valid only when SignalType is set
        %  to "LNAV". The default is 0.

       %요약 : (동기화비트)GPS LNAV 데이터에서 각 서브프레임의 첫 번째 30비트는 TLM 메시지 0
        TLMMessage = 0
        
        %HOWTOW Time of week in hand-over word
        %  Indicate the MSB 17 bits of the time of week value as an
        %  integer. The default is 1.

        %요약 : LNAV에서 시간을 나타날때 각 서프프레임내의 2번째 30비트에 담겨있음
        % 1주기준(604,800초) 에서 얼마나 지났는지 17비트로 표현 000....00001=1 , *6 즉 6초지난거임(6초단위로 표현..)
        %  HOW(30비트)=TOW(17비트) + 알빠노? + parity bit(6 비트)
        HOWTOW = 1 % TOW 초기화.. (6초?..)


        %L1CTOI Time of interval value for CNAV-2 data
        %    Specify the time of interval for CNAV-2 data. This property is
        %    valid only when SignalType is set to "CNAV2". The default is
        %    0.

        %요약: CNAV-2 데이터에서 사용되는 Time Of Interval 값 
        % L1CTOI= 다음 CNAV-2 데이터블록간의 시간간격, 디폴트값0
        L1CTOI = 0

        %L1CITOW Interval time of week for CNAV-2 data
        %   Specify the internal time of week (ITOW) for CNAV-2 data. This
        %   represents the number of two hour epochs elapsed from the start
        %   of the week. This property is valid only when SignalType is set
        %   to "CNAV2". The default is 0.

        %요약: L1CITOW는 CNAV2 데이터에서 GPS 주간 시작점(일요일 00:00:00) 부터 지금까지 지난 2시간 구간(epoch)의 개수입니다
        % 만약 2면 4시간 지난거임
        L1CITOW = 0

        %L1CHealth Health of L1C signal
        %   Specify the health flag of the L1C signal. Zero means that the
        %   signal is healthy. This property is valid only when SignalType
        %   is set to "CNAV2". The default is 0.

        %요약: CNAV2 데이터에서
        % L1CHelath: 값이 0이면 사용가능 1이면 사용불가
        L1CHealth = 0 % 0 --> healthy


        %AntiSpoofFlag Anti spoof flag
        %  Indicate the anti spoof flag as a binary value. The default is
        %  0.

        %요약:안티스푸핑 기능 활성화/비활성화 Civil 신호(L1C/A)**에는 적용되지 않고, 군용 신호(L1P/Y, L2P/Y 등)에 사용됨.
        % 1이면 코드 암호화 (P코드 -> P(Y) 코드)
        AntiSpoofFlag = 0

        %CodesOnL2 Ranging code on L2 band
        %  Indicate the codes on L2 band as one of "P-code" | "C/A-code".
        %  The default is "P-code".
        % 요

        %요약 L2대역(1227.60 MHz)에서 어떤 코드를 송신할지 결정 P- OR C/A-CODE
        CodesOnL2 = "P-code"

        %L2PDataFlag Indication of presence of navigation data bits with
        %P-code on L2 band
        %  Indicate the presence of navigation data bits with P-code on L2
        %  band as a binary value. Value of 1 indicates navigation data Off
        %  on P-code of in-phase component of L2 channel. The default is 0.

        %요약: L2 대역 P코드에 내비게이션 데이터 비트 포함 여부
        %     0 or 1= L2 채널의 P코드 에서 내비게이션 데이터 비트 송출을 하지 않음  즉, P코드만 순수하게 송출하고 데이터 비트는 얹지 않음
        % 원래 P코드 XOR 네이게이션 데이터 
        %  왜? GPS L2 P코드는 군용 신호고   데이터는 제거 → Anti-Jam이나 군용 실험용
        L2PDataFlag = 0


        %L2CPhasing Phase relationship indicator of L2C signal
        %  Indicate the phase relationship on L2C signal as a binary value.
        %  Value of 0 indicates that the L2C signal is on phase quadrature.
        %  A value of 1 indicates that L2C signal is in-phase. The default
        %  is 0.

        %요약 :  L2C는 L2 주파수에서 송신되는 민간용 신호
        %     L2CPhasing 값이 0 = L2C신호가  위상직교 상태
        %                값이 1 = L2C신호가 동상 상태..
        L2CPhasing = 0

        %SVHealth Satellite vehicle health
        %  Indicate the satellite health as an integer value. This property
        %  is valid only when SignalType is set to "LNAV". The default is 0.

        %요약: LNAV메시지일때 위성 정상상태(0) 표시 비정상(1)
        SVHealth = 0


        %SignalHealth L1/L2/L5 signal health indicators.
        %  Indicate the signal health of L1/L2/L5 as a three element array
        %  of binary values. This property is valid only when SignalType is
        %  set to "CNAV". The default is a 3 element column vector of
        %  zeros.
        
        %요약 : CNAV메시지일때 위성 정상상태표시
        %   각각 L1/L2/L5 대역 
        SignalHealth = [0; 0; 0]
        
        
        %IssueOfDataClock Issue of data clock
        %  Indicate the issue of data clock as an integer value. In the
        %  encoded message, this value is going to be of 10 bits. This
        %  property is valid only when SignalType is set to "LNAV". The
        %  default is 0.

        %요약 : Issue of data clocK(IODC)는 일종의 버전을 기록하는건데
        %  값이 같으면 서로 같은 데이터라는거고 값이 다르면 다른 데이터라는걸 의미
        % 예를들면 시간을 보정하기 위한 계수들을 쓰는데 값이 다르면 기존 계수들을 폐기
        % 위성시계를 탑재하고 빵 쌋는데 상대성이론에의해 서로 인지하는 시간이 다르게 간다.. 그것을 보정     
        IssueOfDataClock = 0

        %URAID User range accuracy index
        %  Indicate the user range accuracy as an integer for LNAV data.
        %  This property is valid only when SignalType is set to "LNAV". The
        %  default is 0.
        
        %요약 : LNAV메시지일때만 작동하는 값으로
        % 0 : 위치정확도가 2.4m이하 이다
        % 15: 위치정확도가 614.4m 이상이다.
        URAID = 0

        %WeekNumber GPS week number
        %  Specify the GPS week number as an integer value. The default
        %  is 2149.

        %요약: GPS 주 번호는 GPS 시스템 기준시점(1980년 1월 6일 00:00:00 UTC)부터 현재까지 몇 주가 지났는지를 나타냅니다.
        % 2149 주 =2021년 1월 의미 하지만 10비트가최대라(1023이최대)
        % 101로씀..(이미 2번 로테이션돌고 나머지 101)
        WeekNumber = 2149

        %GroupDelayDifferential Group delay differential
        %  Indicate the group delay differential value in seconds. The
        %  default is 0.
       
        % L1 L2그룹간 시간지연이 필요한 이유
        % 많은 GPS 수신기(특히 저가형)는 L1 신호만 사용해서 위치 계산.
        % 이때 항법 메시지 속 시간 보정 파라미터(af0, af1, af2)는 L1/L2 공통 기준으로 계산된 값이에요.
        % 그레서 L1 L2그룹간 시간 지연값이 필요하다?
        GroupDelayDifferential = 0 % T_GD
        
        %SVClockCorrectionCoefficients Clock correction coefficients, af0,
        %af1, af2
        %  Indicate the satellite vehicle (SV) clock bias (af0), clock
        %  drift (af1) and clock drift rate (af2) in that order as an array
        %  of three elements. The default is a 3 element column vector with
        %  all zeros.

        % 요약: SVClockCorrectionCoeffi 는 위성시계보정계수이다. af0,af1,af2..
        % 수신기는 이계수들을 가지고 
        % t_sv=af0 + af1 ( t- toc) + af2 (t -toc)^2 이런식으로 시간오차를 보정,,
        SVClockCorrectionCoefficients = [0; 0; 0] % [af0; af1; af2]


        %ReferenceTimeOfClock Reference time of clock
        %  Indicate the reference time of clock in seconds. The default is
        %  0.
        
        % 요약: 위 계산에 사용될 t_oc 값  
        %  t_oc라는 시점 기준으로 시계 오차 보정 계수 a_f0, a_f1, a_f2를 사용하라는뜻.
        ReferenceTimeOfClock = 0 % t_oc


        %SemiMajorAxisLength Semi-major axis length of the satellite orbit
        %  Indicate the semi-major axis length of the satellite orbit as a
        %  scalar double value in meters. The default is 26560000.

        % 요약: SemiMajorAxisLength : gps위성 타원 궤도의 장반경
        % 단위는 미터 26560000 값은 GPS 위성의 실제 장반경 값
        SemiMajorAxisLength = 26560000


        %ChangeRateInSemiMajorAxis Rate of change of semi-major axis length
        %  Indicate the rate of change of semi-major axis length in meters
        %  per second. This property is valid only when SignalType is set to
        %  "CNAV". The default is 0.

        % 요약: 위성궤도가 중력? 등에 의해 궤도가 변혀되는 값을 나타냄
        % 단위 m/s
        % 이형태는 CNAV일때 유효하며 LNAV는 효과가 없다.
        ChangeRateInSemiMajorAxis = 0


        %MeanMotionDifference Mean motion difference
        %  Indicate the mean motion difference value as a scalar double.
        %  The default is 0.

        % 요약 MeanMotion은 위성이 궤도를 한바퀴도는 '평균 각속도' 를 나타낸다.
        % 단위 : rad/s
        %  MeanMotion은 root(지구중력상수/ 장반경 세제곱) 으로 계산된다고하네용
        %  이값은 CNAV & LNAV 전부사용
        MeanMotionDifference = 0


        %RateOfMeanMotionDifference Rate of change of mean motion
        %difference
        %  Indicate the rate of change of mean motion difference as a
        %  scalar double value. This property is valid only when SignalType
        %  is set to "CNAV". The default is 0.

        %  요약: CNAV에서만 사용하는 MeanMotiondifference의 변화율
        %  단위: rad^2/s
        %  더 정밀함을 위해 제공..
        RateOfMeanMotionDifference = 0


        %FitIntervalFlag Fit interval flag
        %  Indicate the fit interval flag as a binary value. This property
        %  is valid only when SignalType is set to "LNAV". The default is
        
        % 요약:FitIntervalFlag는 LNAV 메시지 전용이며.
        % 위성 Ephemeris가 얼마 동안 유효한지 나타냄.
        % 0: 4시간 동안 유효
        % 1: 4시간 그 이상 유효
        FitIntervalFlag = 0

        %Eccentricity Eccentricity of the satellite orbit
        %  Indicate the eccentricity of the ellipse in which satellite
        %  orbits as a scalar double value in the range of 0 to 1. The
        %  default is 0.02.
         
        % 요약: Ecentricitiy= 타원궤도가 원으로부터 얼마나 벗어나인가 나타내는 이심율
        % 1보다크면 포물선  (어케 계산하드라..?...)
        Eccentricity = 0.02

        %MeanAnomaly Mean anomaly at reference time
        %  Indicate the mean anomaly value as a scalar double value. The
        %  default is 0.

        % 요약 : MeanAnomaly= 현재 t_oe(	reference time of ephemeris)시간에서의  위성의 각도
        % 단위 rad 각도
        % 측정된 시간은 따로 t_oe기준으로 나타냄..
        MeanAnomaly = 0
        %ReferenceTimeOfEphemeris Reference time of ephemeris
        %  Indicate the reference time of ephemeris as a scalar double
        %  value. This value indicates the time within a week when the
        %  ephemeris data is updated in seconds. The default is 0.

        % 요약: t_oe는 TOW랑 다른거고 궤도파라미터가 기준하는시각
        % 매주 일요일 00:00:00 으로부터 몇초 지났는지? (1주=604800s)
        % 단위 : 초
        ReferenceTimeOfEphemeris = 0 % t_oe


        %HarmonicCorrectionTerms Six harmonic correction terms
        %  Indicate the six harmonic correction terms as a vector of 6
        %  elements. First element is the amplitude of the sine harmonic
        %  correction term to the angle of inclination (C_is). Second
        %  element is the amplitude of the cosine harmonic correction term
        %  to the angle of inclination (C_ic). The third element is the
        %  amplitude of the sine correction term to the orbit radius
        %  (C_rs). The fourth element is the Amplitude of the cosine
        %  correction term to the orbit radius (C_rc). The fifth element is
        %  the amplitude of the sine harmonic correction term to the
        %  argument of latitude (C_us). The sixth element is the amplitude
        %  of the cosine harmonic correction term to the argument of
        %  latitude (C_uc). The default is a column vector of six zeros.

        % 요약: HarmonicCorrectionTerms= 위성 궤도 계산에 사용되는 6개 항
        % Inclination angle: 지구 적도면과 위상궤도면 사이의 각도
        % Cis: Inclination angle 의 사인 보정항 
        % Cic: Inclination angle 의 코사인 보정항
        % Orbit radius: 지구와 위성사이의 거리
        % Crs: orbit radius의 사인 보정항 
        % Crc: orbit radius의 코사인 보정항
        % Argument of latidude: Ascending node(위성궤도면과 지구 적도면의 만나는 지점) 기준으로 위성까지의 각도
        % Cus: Argumnet of latitude 사인보정항
        % Cuc: Argumnet of latitude 코사인 보정항
        HarmonicCorrectionTerms = zeros(6,1) % [Cis; Cic; Crs; Crc; Cus; Cuc]


        %IssueOfDataEphemeris Issue of data ephemeris
        %  Indicate the issue of data ephemeris as a scalar integer value.
        %  This property is valid only when SignalType is set to "LNAV". The
        %  default is 0.

        % 요약: IODE=위성 궤도 데이터(Ephemeris)의 버전 식별자
        % LNAV일때만 유효 
        % 일반적으로 mod(t_oe,256) 값을 쓴다는데?
        IssueOfDataEphemeris = 0

        %IntegrityStatusFlag Integrity status flag
        %  Indicate the signal integrity status as a binary scalar value.
        %  The default is 0.

        %요약 : TLM 메시지에서 GPS 항법데이터 의 무결성을 나타내는 FLAG?
        % 0: 신호사용가능  1: 위치계산에 사용X
        IntegrityStatusFlag = 0


        %ArgumentOfPerigee Argument of perigee at reference time
        %  Indicate the argument of perigee of the satellite orbit as a
        %  scalar double value in the units of semi-circles. Argument of
        %  perigee is defined as the angle subtended by the direction of
        %  longitude of ascending node to the perigee. The default is
        %  -0.52.

        % 요약 : ArgumentOfPerigee 은 Ascendingnode에서 perigee까지의 각도
        % perigee는 위성궤도면에서 지구가 초점일때 짧은지름?을 의미
        % 단위 : 1=180 도 -1= -180도
        % -0.52= -93.6도
        ArgumentOfPerigee = -0.52

        %RateOfRightAscension Rate of right ascension
        %  Indicate the rate of change of right ascension as a scalar
        %  double value. The default is 0.

        % 요약: Ascendingnode위치를 나타내는 경도값(오메가 : 그리니치 자오선과 의 Ascending node사이의 각도)의 시간변화률
        % 위성궤도면이 사실은 살짝식 회전한다
        % 단위 :rad/s 
        RateOfRightAscension = 0

        %LongitudeOfAscendingNode Longitude of ascending node
        %  Indicate the longitude of ascending node as a scalar double
        %  value. The default is -0.84.

        % AscendingNode의 경도값 오메가 ( 그리니치 자오선로부터 Asceding node 사이의 각도)
        % -0.84 = -151.2 도
        LongitudeOfAscendingNode = -0.84 % -151.2 도

        %Inclination Inclination angle of the satellite orbit with respect
        %to equator of Earth
        %  Indicate the inclination angle as a scalar double value in the
        %  units of semi-circles. The default is 0.3.

        % 요약: Inclination angle= 위성 궤도면과 적도면사이가 이루는각도
        % 0.3= 54도
        Inclination = 0.3 % In semi-circles

        %InclinationRate Rate of change of inclination angle
        %  Indicate the rate of change of inclination angle as a scalar
        %  double in the units of semi-circles/second. The default is 0.

        %요약 : Inclination angle 의 시간변화율
        % 단위 semicircle/s
        % 1=180도?
        InclinationRate = 0

        %URAEDID Elevation dependent (ED) user range accuracy (URA) index
        %   Indicate the elevation dependent user range accuracy index as
        %   an integer. This property is valid only when SignalType is set to
        %   "CNAV". The default is 0.

        % 요약: CNAV메시지 일때만 유효!
        %  URA 라는 즉 위성 고도에따라 위성의 정확도가 를 지수로 표현한 숫자가 있는데
        %  URAEDID는 URA를 추가 보정하는값 ( 고도가 높을수록 오차적음)
        % LNAV에서는 URAID를 쓰고 CNAV에서는 URAEDID를쓴다.
        URAEDID = 0

        %InterSignalCorrection Inter signal correction terms
        %  Indicate the inter signal correction (ISC) terms as a vector of
        %  4 elements. First element represents ISC L1C/A. Second element
        %  represents ISC L2C. Third element represents ISC L5I5. Fourth
        %  element represents ISC L5Q5. This property is valid only when
        %  SignalType is set to "CNAV". The default is a column vector of 4
        %  zeros.

        % 요약 : CNAV에서만 등장하는 파라미터
        % 한 위성에서 4가지 GPS신호를 동시에 보내는데 L1C/A 와 L2C , L5I5 L5Q5
        % 각 그룹간의 도달하는시간이 다르긴하다고 함 그룹지연차리를 보정한다,
        InterSignalCorrection = zeros(4,1) % [L1C/A; L2C; L5I5; L5Q5]

        %ISCL1CP Inter signal correction for L1C pilot signal

        %요약 : L1C= L1 주파수 CNAV신호
        % L1C 신호는 P(파일럿)(PRN코드만송신) 채널 D(데이터) 채널로 분리되는데
        %  ISCL1CP는 L1C PILIOT 과 다른 주파수 L1 C/A L2 L5 신호사이의 그룹지연차이 보정
        ISCL1CP = 0
        %ISCL1CD Inter signal correction for L1C data signal
        %요약: 그럼 ISCL1CD는 ISCL1CP는 L1C DATA 와 다른 주파수 L1 C/A L2 L5 신호사이의 그룹지연차이 보정 
        ISCL1CD = 0

        %ReferenceTimeCEIPropagation Reference time of CEI propagation
        %  Indicate the reference time of CEI propagation as a scalar
        %  double value. This property is valid only when SignalType is set
        %  to "CNAV". The default value is 0.

        %요약 :  CNAV메시지에만 있는 CEI(Clock, Ephemeris, Integrity) 전파 참조 시각
        % 단위: 초 (0~604799(1주))
        % CNAV 메시지는 전송 시점과 실제 데이터 계산 시점이 다를 수 있음
        % 위성데이터를 보정할때 쓰는값이래 ( 경도변화율 이런거 있잖아)
        ReferenceTimeCEIPropagation = 0 % t_op

        %ReferenceWeekNumberCEIPropagation Reference week number of CEI
        %propagation
        %  Indicate the reference week number of clock, ephemeris, and
        %  integrity (CEI) parameters propagation. This property is valid
        %  only when SignalType is set to "CNAV". The default is 101.

        % 요약: CNAV전용 CEI(Clock, Ephemeris, Integrity) 파라미터가 유효한 참조 GPS 주 번호(Week Number)
        %  (LNAV은 WeekNumber만으로 충분??)
        % 101 주면,,, 1980년 1월 6일로 부터 1982년 12월13일?? 너무옛날아니노
        % 1024 주기를 돌았다면 101값은 2001년?.. 너무옛날인데..
        ReferenceWeekNumberCEIPropagation = 101 % WN_OP

        %URANEDID Non-elevation dependent user range accuracy indices
        %  Indicate the Non-elevation dependent user range accuracy indices
        %  as a vector of three elements. The default is a column vector of
        %  3 zeros.

        %요약 URAEDID랑 비슷한데 차이점은 URANEDID는 고도와 무관하다는점 (위성시스템과관련된?)
        % 오차계수는 총3개이며 상수항;1차항;2차항 으로계산
        URANEDID = [0; 0; 0] % [URA_NED0; URA_NED1; URA_NED2]

        %AlertFlag Alert flag
        %  Indicate the alert flag as a binary scalar value. The default is
        %  0.

        %요약: 경고플래그 0:정상 1:데이터신뢰X (위성시계관련해서)
        AlertFlag = 0

        %AgeOfDataOffset Age of data offset
        %  Indicate the age of data in seconds. The default is 0.

        %  요약: 데이터 가 얼마나 오래되었는지?
        %  그냥 시뮬레이터용 파라미터라는데 ??? 맞아?아닌가?
        AgeOfDataOffset = 0 % In seconds

        %NMCTAvailabilityIndicator NMCT availability indicator
        %  Indicate the presence of NMCT as a binary value. The default is
        %  0.
        
        %요약: NMCT라고 Navigation Message correction table이 있는데 (LNAV+CNAV둘다)
        % NMCT에는 시계보정 궤도수정 이오노스피어 보정(ionospheric correction)이 들어있다
        % 1 이면 NMCT DATA 가 포함된 메시지를생성하겠다
        % 0 이면 기본메시지를 생성하겠다
        NMCTAvailabilityIndicator = 0
        
        %NMCTERD NMCT ERD values
        %  Indicate the NMCT estimated rate deviation (ERD) values as an
        %  array of 30 elements. The default is a column vector of 30
        %  zeros.

        % 요약:Navigation Message correction table (NMCT) 에 ERD라는 값들이 있음
        % 각 위성을 이용한다면 거리 오차(m)가 얼마나될지 예상한 값들
        NMCTERD = zeros(30,1)
        
        %AlmanacFileName  Almanac file name which has almanac information
        %in SEM format
        %  Indicate the almanac file name as a string scalar or a character
        %  vector. The default is "gpsAlmanac.txt".

        % 요약 : 위성의 궤도정보를 포함하는 Almanac 파일이라고함
        % (정밀 Ephemeris보다 정확도는 낮지만, 데이터 양이 적어 빠르게 전송 가능)
        AlmanacFileName = "gpsAlmanac.txt"

        %Ionosphere Structure containing Ionosphere information
        %  Indicate the ionospheric parameters as a structure with fields
        %  "Alpha" and "Beta". The default of each field of the structure
        %  is a column vector of 4 zeros.

        % 요약: 전리층 보정 파리미터라는데
        %  전리층 보정용 Klobuchar 모델에  파라미터(Alpha, Beta) 가있다..
        % 두 알파 베타 계수를 이용해서  지연된 시간을 어쩌저찌 계산한다,,
        Ionosphere = struct('Alpha',zeros(4,1),'Beta',zeros(4,1))

        %EarthOrientation Structure containing Earth's orientation
        %information
        %  Indicate the Earth orientation parameters as structure with
        %  fields "ReferenceTimeEOP", "XAxisPolarMotionValue",
        %  "XAxisPolarMotionDrift", "YAxisPolarMotionValue",
        %  "YAxisPolarMotionDrift", "UT1_UTCDifference",
        %  "RateOfUT1_UTCDifference". The default value of each of these
        %  properties is 0.

        % 요약: EarthOrientation구조는 지구자전축이 변하는 운동을 고려하는 파라미터들인데
        % (좌표계가변함) (어떻게 계산되는지는 몰루?)
        % 기준시간을 기준으로 자전축이 x축으로 몇라디안? y축으로 몇 라디안? 움직였는지와
        % UT1(지구 자전 기반 시각)와 UTC(원자시계 시각) 값을 넣음으로써 , 위성궤도정보(지구중심관성좌표계)
        %  -> 수신기좌표(지구고정좌표계)  로 변환할때 필요하데.. 
        % (어떻게 계산되는지는 몰루..??)
        EarthOrientation = struct('ReferenceTimeEOP',0,'XAxisPolarMotionValue',0,...
            'XAxisPolarMotionDrift',0,'YAxisPolarMotionValue',0, ...
            'YAxisPolarMotionDrift',0,'UT1_UTCDifference',0, ...
            'RateOfUT1_UTCDifference',0);
        
        %UTC Structure containing UTC parameters
        %  Indicate the parameters of coordinated universal time (UTC) as a
        %  structure with fields "UTCTimeCoefficients",
        %  "PastLeapSecondCount", "ReferenceTimeUTCData",
        %  "TimeDataReferenceWeekNumber", "LeapSecondReferenceWeekNumber",
        %  "LeapSecondReferenceDayNumber", "FutureLeapSecondCount".

        % 요약: 위성내 돌아가는 GPS시간과 지구의 일반적인시간 UTC로 변환하기위한 파라미터들인데..
        %  (어떻게 계산되는지는 몰루>?) 현재 GPS시간에 18초를 더해줘야한다
        %  2149 는 2번돌면 2021년 1월 쯤..
        % GPS시간에 단순 윤초를 빼는게 아니라 보정계수들이있음!
        % ReferenceTimeUTCData=UTC 보정식의 기준시점 t_ot? (tow랑 같이설정해도된다?)
        % TimeDataReferenceWeekNumber= 보정계수의 기준시점 weeknumber
          % 'LeapSecondReferenceDayNumber',1 =월요일 그 weeknumber내에 해당요일부터 윤초를 적용하라..

        UTC = struct('UTCTimeCoefficients',[0 0 0],'PastLeapSecondCount',18, ...
            'ReferenceTimeUTCData',0,'TimeDataReferenceWeekNumber', 2149, ...
            'LeapSecondReferenceWeekNumber',2149,'LeapSecondReferenceDayNumber',1, ...
            'FutureLeapSecondCount',18)
        %DifferentialCorrection Structure containing differential
        %correction parameters
        %  Indicate the differential correction parameters as a structure
        %  with fields "ReferenceTimeDCDataPredict", "ReferenceTimeDCData",
        %  "Data". The filed "Data" is an array of structure with fields
        %  "DCDataType", "CDCPRNID", "SVClockBiasCoefficient",
        %  "SVClockDriftCorrection", "UDRAID", "EDCPRNID",
        %  "AlphaCorrection", "BetaCorrection", "GammaCorrection",
        %  "InclinationCorrection", "RightAscensionCorrection",
        %  "SemiMajorAxisCorrection", "UDRARateID".

        %  DifferentialCorrection 이라고 기준국이 gps신호를 받고
        %  따로 방송하는 신호라고 하는데?..
        % 차분 보정 데이터 값은 31번 반복 ( 위성 약32개)
        % ReferenceTimeDCData 는 기준국이 오차를 측정한시간
        % ReferenceTimeDCDataPredict 는 t초 후에 적용할 보정값 까지 한다는데 여기서는x
        %  DCDataType는 보정데이터 타입을 결정 (시계/궤도/등?)
        %  CDCPRNID 는 시계 보정을 적용할 위성 PRN 번호
        %  SVClockBiasCoefficient 위성 시계 보정값 (초)
        %  SVClockDriftCorrection 위성 시계 드리프트 값 ( 초/초)
        %  UDRAID 는 	User Differential Range Accuracy 식별자 (오차범위 식별자 1m등)
        % --------------------------------------------
        %  EDCPRNID 이제 궤도 보정을 적용할 위성 pRN번호
        % AlphaCorrection X축궤도보정
        % BetaCorrection  Y축궤도보정
        % GammaCorrection Z축궤도보정
        % InclinationCorrection 궤도 경사각 보정
        % RightAscensionCorrection 어센딩노드 보정
        % SemiMajorAxisCorrection 궤도 장반경보정
        % UDRARateID 는 UDRA가 시간에따라 얼마나커지는지의 식별자 (초당 몇m씩오차증가 같은)
        DifferentialCorrection = struct('ReferenceTimeDCData',0, ...
            'ReferenceTimeDCDataPredict',0, ...
            'Data',repmat(struct('DCDataType',0,'CDCPRNID',1,'SVClockBiasCoefficient',0, ...
            'SVClockDriftCorrection',0,'UDRAID',1,'EDCPRNID',1, ...
            'AlphaCorrection',0,'BetaCorrection',0,'GammaCorrection',0, ...
            'InclinationCorrection',0,'RightAscensionCorrection',0, ...
            'SemiMajorAxisCorrection',0,'UDRARateID',0),31,1))

        %TimeOffset Structure containing the parameters related to the time
        %offset of GPS with respect to other GNSS systems
        %  Indicate the time offset of GPS constellation with respect to
        %  other GNSS constellation as a structure with fields
        %  "ReferenceTimeGGTO", "WeekNumberGGTO", "GNSSID",
        %  "GGTOCoefficients".
        
        % 요약: GPS와 다른GNSS(Galileo, GLONASS, BeiDou 등) 이 비해  시간이얼마나차이나는지
        %  GNSSID( 2= 갈릴레오...)
        %  GGTOCoefficients  시간오차 다항식계수..
        % 왜? 멀티 GNSS 수신기를 위해 필요 
        % 어떻게계산하냐? 몰루..
        TimeOffset = struct('ReferenceTimeGGTO',0,'WeekNumberGGTO',101, ...
            'GNSSID',0,'GGTOCoefficients',[0;0;0])


        %ReducedAlmanac Reduced almanac used in modernized GPS signals

        %요약: GPS 알마낙(almanac) 정보를 간소화한 형태로 저장한 구조체 (SBAS메시지용?)
        % (알마낙도 간소화한 궤도정보아님?)
        %  주 번호 있고  기준 초 있고 
        %  PRNa  : 위성 PRN 넘버
        %  delta A: 위성 궤도 장반경의 변화량
        %  Omega0 : 승교점 경도
        %  Phi0: 	위성 궤도 내 위치 각도(위상)
        %  각 L1 L2 L5 주파수 신호 상태 ㅇㅇ 
        ReducedAlmanac = struct('WeekNumber',1,'ReferenceTimeOfAlmanac',0, ...
            'Almanac',repmat(struct('PRNa',0,'delta_A',0,'Omega0',0, ...
            'Phi0',0,'L1Health',0,'L2Health',0,'L5Health',0),6,1)) % Reduced almanac 

        %TextMessage Text message in LNAV data
        %  Indicate the text message that needs to be transmitted on the
        %  LNAV data. It is of length 22 characters. If more characters is
        %  specified, then the text is snipped to 22 characters. If less
        %  than 22 characters is specified, then the additional characters
        %  are filled with blank spaces. The default is 'This content is
        %  part of Satellite Communications Toolbox'.

        % 요약 : LNAV에서 전송할 메시지 지정 (최대22자)
        %  실제로 전송하는 일은 잘 없고 시뮬레이션용
        TextMessage = 'This content is part of Satellite Communications Toolbox. Thank you. '

        %TextInMessageType36 Text message in CNAV data message type 36
        %  Indicate the text message that needs to be transmitted on the
        %  CNAV data. It is of length 18 characters. If more characters is
        %  specified, then the text is snipped to 18 characters. If less
        %  than 18 characters is specified, then the additional characters
        %  are filled with blank spaces. The default is 'This content is
        %  part of Satellite Communications Toolbox'.

        % 요약:  CNAV에서 보낼 18자 메시지 (Message Type 36 )
        % (TYPE 30은 궤도정보)
        TextInMessageType36 = 'This content is part of Satellite Communications Toolbox. '

        %TextInMessageType15 Text message in CNAV data message type 15
        %  Indicate the text message that needs to be transmitted on the
        %  CNAV data. It is of length 29 characters. If more characters is
        %  specified, then the text is snipped to 29 characters. If less
        %  than 29 characters is specified, then the additional characters
        %  are filled with blank spaces. The default is 'This content is
        %  part of Satellite Communications Toolbox'.

        % 요약 CNAV메시지 에서 Message type 15 에 저장될 텍스트메시지(29자)
        TextInMessageType15 = 'This content is part of Satellite Communications Toolbox. '
      
        %ISM Integrity support message
        %요약: ISM는 CNAV의 무결성을 지원하는 메시지타입34(300 bit) 이라는데
        %  GNSSID 4= GPS 
        %  Weeknumber= gps 주번호
        %  TOW=  초 (최대1주)
        % CorrelationTimeConstantID : 위성고장이나 오류가 얼마나 지속되는지?..( 1:10s,2:60)
        %  AdditiveTermID & ScalarTermID 위성의 최데 예상오차= AdditiveTermID + ScalarTermID* URAID^2 (각 숫자에 대응하는 계수가있음..)
        % SatelliteFaultRateID " 개별 위성이 고장날 확률(시간당)"을 코드 값으로 표현한 것 (기본값 0 = 10만시간에 1번고장)
        % ConstellationFaultProbabilityID : 전체 위성군 (gps 시스템) 이 고장날 확률 매핑
        % MeanFaultDurationID : 위성이 한번 고장나면 평균적으로 얼마나 오래 지속되는지"**를 매핑(0:거의즉시복구)
        % ServiceLevel : 0=무결성 서비스 제공(X 1= 무결설 서비스 제공 2..3.. 더 고차원
        % SatelliteInclusionMask :  무결성(FDE/RAIM) 계산 시 어떤 위성들을 사용할지 지정하는 비트 마스크 
        % CRCPolynomial : 체크섬 계산 다항식 (cnav표준?)(어케 계산하는지?는 몰루? 비트 쉬프트?)
          % (계산값이 필요하다?) 
          ISM = struct('GNSSID',4, ... % 4 is GPS
            'Weeknumber',1,'TOW',0,'CorrelationTimeConstantID',0,'AdditiveTermID',0, ...
            'ScalarTermID',0,'SatelliteFaultRateID',0,'ConstellationFaultProbabilityID',0, ...
            'MeanFaultDurationID',0,'ServiceLevel',1,'SatelliteInclusionMask',zeros(63,1), ...
            'CRCPolynomial','x^32 + x^31 + x^24 + x^22 + x^16 + x^14 + x^8 + x^7 + x^5 + x^3 + x + 1');
    end

    properties(Hidden) % 히든이 클래스 내부에 만 사용하는 속성값 .사용X
        PageID % Useful while generating the GPS data frame with LNAV data
        SubframeID % Useful while generating LNAV data
    end

    properties(Constant,Hidden) %Constant : 값 변경 불가능
        SignalType_Values = {'CNAV','CNAV2','LNAV','L5'}
        CodesOnL2_Values = {'P-code','C/A-code','invalid'}
    end

    methods
        function obj = HelperGPSNavigationConfig(varargin)
            % 외부에서 HelperGPSNavigationConfig 객체 생성 할때 자동으로 호출, 외부에서 들어오는 여러개의 입력을 varagin으로 받고 
            % comm.internal.ConfigBase 가 속성을 자동으로 할당하는데 쓰일려고 만든 내부 클래스래.

            %HelperGPSNavigationParameters Construct an instance of this class
            %   Support name-value pair arguments when constructing object.
            obj@comm.internal.ConfigBase(varargin{:}); % 일종의 초기화 방법?.. comm.imternal.ConfigBase는 맨위에서 설정한 부모클래스?
        end

        % Set methods for independent properties validation
        % set. 이렇게하는게 나중에 클래스밖에서 지정해도 유동적으로 유효성검사도 하고 할당도 해준데...!
        function obj = set.SignalType(obj,val)
            prop = 'SignalType';
            val = validateEnumProperties(obj, prop, val);
            % validateEnumProperties 는 matlab 내부적으로 유효성검사를 하는건데 여기서는 정수형이 맞는지 문자형이 맞는지 자동적으로 체크한데
            % (속성,할당하려는값)
            obj.(prop) = string(val);
            %(prop) 괄호는 동적인 방식이라는데 뭔말인지..알거같기두.
        end

        function obj = set.PRNID(obj,val)
            prop = 'PRNID';
            validateattributes(val,{'double','single','uint8'},{'positive','integer','scalar','>=',1,'<=',210},mfilename,prop)
            %   validateattributes 는 검사할값을 받고 {허용되는 클래스형을 정의하고}, {요구되는 속성목록을 정의함양수,정수,scarlab,1보다크고 210보다 작다}/
            % 그이후 인자들은 오류메시지에 포함될 함수와 변수이름들
            obj.(prop) = val;
        end

        function obj = set.MessageTypes(obj,val)
            prop = 'MessageTypes';
            validateattributes(val,{'double','single','uint8'},{'positive','integer'})
            if ~any(any(ismember(val,[10;11;30;31;32;33;34;35;36;37;12;13;14;15])))
                error('All elements in the MessageTypes property must be from the set {10,11,12,13,14,15,30,31,32,33,34,35,36,37}.')
            end
            obj.(prop) = val;
        end

        function obj = set.FrameIndices(obj,val)
            prop = 'FrameIndices';
            validateattributes(val,{'double','single','uint8'},{'positive','integer','<=',25},mfilename,prop)
            obj.(prop) = val;
        end

        function obj = set.Preamble(obj,val)
            prop = 'Preamble';
            validateattributes(val,{'double','single','uint8'},{'nonnegative','integer'},mfilename,prop)
            obj.(prop) = val;
        end

        function obj = set.TLMMessage(obj,val)
            prop = 'TLMMessage';
            validateattributes(val,{'double','single','uint16'},{'nonnegative','integer'},mfilename,prop)
            obj.(prop) = val;
        end

        function obj = set.HOWTOW(obj,val)
            prop = 'HOWTOW';
            validateattributes(val,{'double','single','uint32'},{'nonnegative','integer'})
            obj.(prop) = val;
        end

        function obj = set.AntiSpoofFlag(obj,val)
            prop = 'AntiSpoofFlag';
            validateattributes(val,{'double','logical'},{'binary'})
            obj.(prop) = val;
        end

        function obj = set.CodesOnL2(obj,val)
            prop = 'CodesOnL2';
            val = validateEnumProperties(obj, prop, val);
            obj.(prop) = val;
        end

        function obj = set.L2PDataFlag(obj,val)
            prop = 'L2PDataFlag';
            validateattributes(val,{'double','logical'},{'binary'},mfilename,prop)
            obj.(prop) = val;
        end

        function obj = set.L2CPhasing(obj,val)
            prop = 'L2CPhasing';
            validateattributes(val,{'double','logical'},{'binary'},mfilename,prop)
            obj.(prop) = val;
        end

        function obj = set.AgeOfDataOffset(obj,val)
            prop = 'AgeOfDataOffset';
            validateattributes(val,{'double','single'},{'nonnegative','<=',27900},mfilename,prop)
            obj.(prop) = val;
        end

        function obj = set.NMCTAvailabilityIndicator(obj,val)
            prop = 'NMCTAvailabilityIndicator';
            validateattributes(val,{'double','logical'},{'binary'},mfilename,prop)
            obj.(prop) = val;
        end

        function obj = set.NMCTERD(obj,val)
            prop = 'NMCTERD';
            validateattributes(val,{'double','single','uint32'},{'vector','numel',30},mfilename,prop)
            obj.(prop) = val;
        end

        function obj = set.AlmanacFileName(obj,val)
            prop = 'AlmanacFileName';
            validateattributes(val,{'char','string'},{},mfilename,prop)
            obj.(prop) = val;
        end

        function obj = set.Ionosphere(obj,val) % set.은 매트랩규칙이래 애도 자동으로호출
            prop = 'Ionosphere';
            validateattributes(val,{'struct'},{},mfilename,prop)
            validateattributes(val.Alpha,{'double','single'},{'vector','numel',4},mfilename,[prop '.Alpha'])
            validateattributes(val.Beta,{'double','single'},{'vector','numel',4},mfilename,[prop '.Beta'])
            obj.(prop) = val;
        end

        function obj = set.EarthOrientation(obj,val)
            prop = 'EarthOrientation';
            validateattributes(val,{'struct'},{},mfilename,prop)
            validateattributes(val.ReferenceTimeEOP,{'double','single'},{'nonnegative','scalar','<=',604784},mfilename,[prop '.ReferenceTimeEOP'])
            validateattributes(val.XAxisPolarMotionValue,{'double','single'},{},mfilename,[prop '.XAxisPolarMotionValue'])
            validateattributes(val.XAxisPolarMotionDrift,{'double','single'},{},mfilename,[prop '.XAxisPolarMotionDrift'])
            validateattributes(val.YAxisPolarMotionValue,{'double','single'},{},mfilename,[prop '.YAxisPolarMotionValue'])
            validateattributes(val.YAxisPolarMotionDrift,{'double','single'},{},mfilename,[prop '.YAxisPolarMotionDrift'])
            validateattributes(val.UT1_UTCDifference,{'double','single'},{},mfilename,[prop '.UT1_UTCDifference'])
            validateattributes(val.RateOfUT1_UTCDifference,{'double','single'},{},mfilename,[prop '.RateOfUT1_UTCDifference'])
            obj.(prop) = val;
        end

        function obj = set.UTC(obj,val)
            prop = 'UTC';
            validateattributes(val,{'struct'},{},mfilename,prop)
            validateattributes(val.UTCTimeCoefficients,{'double','single'},{'vector'},mfilename,[prop '.UTCTimeCoefficients'])
            validateattributes(val.PastLeapSecondCount,{'double','single'},{},mfilename,[prop '.PastLeapSecondCount'])
            validateattributes(val.ReferenceTimeUTCData,{'double','single'},{},mfilename,[prop '.ReferenceTimeUTCData'])
            validateattributes(val.TimeDataReferenceWeekNumber,{'double','single'},{},mfilename,[prop '.TimeDataReferenceWeekNumber'])
            validateattributes(val.LeapSecondReferenceWeekNumber,{'double','single'},{},mfilename,[prop '.LeapSecondReferenceWeekNumber'])
            validateattributes(val.FutureLeapSecondCount,{'double','single'},{},mfilename,[prop '.FutureLeapSecondCount'])
            obj.(prop) = val;
        end

        function obj = set.DifferentialCorrection(obj,val)
            prop = 'DifferentialCorrection';
            validateattributes(val,{'struct'},{},mfilename,prop)
            validateattributes(val.Data,{'struct'},{},mfilename,prop)
            validateattributes(val.ReferenceTimeDCDataPredict,{'double','single'},{'nonnegative','scalar','<=',604500},mfilename,[prop '.ReferenceTimeDCDataPredict'])
            validateattributes(val.ReferenceTimeDCData,{'double','single'},{'nonnegative','scalar','<=',604500},mfilename,[prop '.ReferenceTimeDCData'])
            obj.(prop) = val;
        end

        function obj = set.TimeOffset(obj,val)
            prop = 'TimeOffset';
            validateattributes(val,{'struct'},{},mfilename,prop)
            validateattributes(val.ReferenceTimeGGTO,{'double','single'},{'nonnegative','scalar','<=',604784},mfilename,[prop '.ReferenceTimeGGTO'])
            validateattributes(val.WeekNumberGGTO,{'double','single','uint16'},{'nonnegative','scalar'},mfilename,[prop '.WeekNumberGGTO'])
            validateattributes(val.GNSSID,{'double','single','uint8'},{'nonnegative','scalar','<=',7},mfilename,[prop '.GNSSID'])
            validateattributes(val.GGTOCoefficients,{'double','single'},{'vector','numel',3},mfilename,[prop '.GGTOCoefficients'])
            obj.(prop) = val;
        end

        function obj = set.TextMessage(obj,val)
            prop = 'TextMessage';
            validateattributes(val,{'char','string'},{},mfilename,prop)
            obj.(prop) = val;
        end

        function obj = set.TextInMessageType36(obj,val)
            prop = 'TextInMessageType36';
            validateattributes(val,{'char','string'},{},mfilename,prop)
            obj.(prop) = val;
        end

        function obj = set.TextInMessageType15(obj,val)
            prop = 'TextInMessageType15';
            validateattributes(val,{'char','string'},{},mfilename,prop)
            obj.(prop) = val;
        end
    end
    
    % 표시해야할 속성명 정의라는데?..
    methods(Access = protected)
        function flag = isInactiveProperty(obj,prop)
            flag = true; % true= 속성 안보이게
            visiblePropListLNAV = {'SignalType','PRNID','FrameIndices','TLMMessage', ...
                'HOWTOW','AntiSpoofFlag','CodesOnL2','L2PDataFlag','SVHealth', ...
                'IssueOfDataClock','URAID','WeekNumber','GroupDelayDifferential', ...
                'SVClockCorrectionCoefficients','ReferenceTimeOfClock', ...
                'SemiMajorAxisLength','MeanMotionDifference','FitIntervalFlag', ...
                'Eccentricity','MeanAnomaly','ReferenceTimeOfEphemeris','HarmonicCorrectionTerms', ...
                'IssueOfDataEphemeris','IntegrityStatusFlag','ArgumentOfPerigee', ...
                'RateOfRightAscension','LongitudeOfAscendingNode','Inclination', ...
                'InclinationRate','AlertFlag','AgeOfDataOffset','NMCTAvailabilityIndicator', ...
                'NMCTERD','AlmanacFileName','Ionosphere','UTC','TextMessage'};
            visiblePropListCNAV = {'SignalType','PRNID','MessageTypes','HOWTOW', ...
                'L2CPhasing','SignalHealth','WeekNumber','GroupDelayDifferential', ...
                'ReferenceTimeOfClock','SemiMajorAxisLength','ChangeRateInSemiMajorAxis', ...
                'MeanMotionDifference','RateOfMeanMotionDifference','Eccentricity', ...
                'MeanAnomaly','ReferenceTimeOfEphemeris','HarmonicCorrectionTerms', ...
                'IntegrityStatusFlag','ArgumentOfPerigee','RateOfRightAscension', ...
                'LongitudeOfAscendingNode','Inclination','InclinationRate', ...
                'URAEDID','InterSignalCorrection','ReferenceTimeCEIPropagation', ...
                'ReferenceWeekNumberCEIPropagation','URANEDID','AlertFlag', ...
                'AgeOfDataOffset','AlmanacFileName','Ionosphere','EarthOrientation', ...
                'UTC','DifferentialCorrection','TimeOffset','ReducedAlmanac', ...
                'TextInMessageType36','TextInMessageType15'};
            visiblePropListCNAV2 = {'SignalType','PRNID','L1CSubframe3PageSequence', ...
                'L1CTOI','L1CITOW','L1CHealth','WeekNumber','GroupDelayDifferential', ...
                'SemiMajorAxisLength','ChangeRateInSemiMajorAxis','MeanMotionDifference', ...
                'RateOfMeanMotionDifference','Eccentricity','MeanAnomaly','ReferenceTimeOfEphemeris', ...
                'HarmonicCorrectionTerms','IntegrityStatusFlag','ArgumentOfPerigee', ...
                'RateOfRightAscension','LongitudeOfAscendingNode','Inclination', ...
                'InclinationRate','URAEDID','InterSignalCorrection','ISCL1CP', ...
                'ISCL1CD','ReferenceTimeCEIPropagation','ReferenceWeekNumberCEIPropagation', ...
                'URANEDID','AlmanacFileName','Ionosphere','EarthOrientation', ...
                'UTC','DifferentialCorrection','TimeOffset','ReducedAlmanac','TextMessage','ISM'};
            % strcmp는 두문자열이 같은지 검사 
            % 여기는 일단넘어가자
            if strcmp(obj.SignalType,'LNAV') 
                flag = ~any(strcmp(prop,visiblePropListLNAV)); % any : 논리배열에 단하나라도 참이면 참
            elseif strcmp(obj.SignalType,'CNAV') || strcmp(obj.SignalType,'L5')
                flag = ~any(strcmp(prop,visiblePropListCNAV));
            elseif strcmp(obj.SignalType,'CNAV2')
                flag = ~any(strcmp(prop,visiblePropListCNAV2));
            end
        end
    end
end