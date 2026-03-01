% V4: rinex 정보그대로 활용 시간대는 과거시간대사용
clc; clear all;
%스푸핑 리넥스를-> LNAV메시지로    
useSDR            = false;         % In the default case, do not use SDR
WriteWaveToFile   = false;         % 파일저장여부
almFileName   = "gpsAlmanac.txt";  % 간단하다운 sem.txt (https://www.navcen.uscg.gov/gps-nanus-almanacs-opsadvisories-sof)
signalType        = "GPS C/A"; % Possible values: "GPS C/A" | "GPS L1C", "GPS L2C" | "GPS L5"
centerFrequency   = 1575.42e6; % Possible values: L1 (1575.42 MHz), L2 (1254.35 MHz), and L5 (1176.45 MHz)
sampleRate        =  4*1.023e+06; %  fs> 4*C/A 칩레이트 1.023MHZ / 2*1.023e+06;
                               % 1023000   /
                                  % 4를추천.. gnss-sdr 락풀리는거 4라고 되는거아님
                                 %  fs> 4*P코드 칩레이트 10.20MHZ
maximumsat=5;                                 
                      
numchannels=1;
 waveDuration=1; % 총시간 초 단위 
                   % 와 3분너무길다 그렇다고 와바박 되는것도아님..

 stepTime = 0.001;  % !수정 0.02가 best인데 수신기락풀리면 0.001까지 
                    % 지연적용은 1코드블록이좋다? 0.001s마다 적용너무오래걸려 <아님총샘플은그대로라서
                    % 1초로하니깐 아예수신기 락이풀림 이유모르겟어 <1초마다 딜레이가확확바껴서 =오류
                    % 최대0.02 , 0.001: 2046샘플 ->0.0005: 1023? / 0.0001:메모리부족이래
 enableImpairments =  true;                 % Option to enable or disable impairments
minElevationAngle = 10; % !수정 각도조절해서 navcfg2위성수 조절
seed              = 73; % Seed for getting reproducible results


wavegenobj = gpsWaveformGenerator(SampleRate=sampleRate,SignalType="legacy");
% WaveformGenerator : 비트->샘플 객체만생성
% switch(signalType)
%     case "GPS C/A"
%         wavegenobj.SignalType = "legacy";  % <<<< 사용
%         navDataType = "LNAV";           
%     case "GPS L1C"
%         wavegenobj.SignalType = "l1C";
%         navDataType = "CNAV2";
%     case "GPS L2C"
%         wavegenobj.SignalType = "l2C";
%         navDataType = "CNAV";
%     case "GPS L5"
%         wavegenobj.SignalType = "l5";
%         navDataType = "L5";
% end


                                    % CNAV: 1bit=0.04s 
% Initialize satellite scenario 
rinexFileName="DAEJ00KOR_R_20260560000_01D_GN.rnx" % 최신 RINEX로 항상 업글 (화,수,목,금,토 만가능)
                                                   % 링크 https://cddis.nasa.gov/archive/gnss/data/daily/2026/0dd/26n/
                                                   % jjo0914/Jjo72002021!
% BRST: 프랑스 13/4/4 오전6시:24분 34초 
% ㅣ= 41.275060 [deg], Long = 1.987740 [deg], Height = 66.90 [m] 를재현하겟음


rinexdata=rinexread(rinexFileName);
PRNIDs=rinexdata.GPS.SatelliteID(end:-1:1);   % 마지막이 최신값..?
[~,idx_first]=unique(PRNIDs,'stable'); % 'stable' 순서유지 ㅇ
idx=height(rinexdata.GPS)-idx_first+1;% 총크기-last + 1 하면 원래위치 ㅇㅇ
newrinexdata=struct('GPS',timetable);
newrinexdata.GPS=rinexdata.GPS(idx,:); % 최신 궤도값가진 prnid만추출
% -> PRNIDS 오름차순 정렬 
PRNIDs=newrinexdata.GPS.SatelliteID(1:end);
[~,idx]=unique(PRNIDs,"sorted");
newrinexdata4.GPS=newrinexdata.GPS(idx,:);
%- 중복된 txtime
txtime=mode(newrinexdata4.GPS.TransmissionTime);
idx=find(newrinexdata4.GPS.TransmissionTime==txtime);
newrinexdata3.GPS=newrinexdata4.GPS(idx,:);
% 중복된 txtime내에서 중복된 toe
toe=mode(newrinexdata3.GPS.Toe);
idx=find(newrinexdata3.GPS.Toe==toe);
newrinexdata4.GPS=newrinexdata3.GPS(idx,:); % 이러면 time까지 같음
            % toe-txtime 이 7200 ~ -7200 이면괜찬 (txtime은 점점증가)
gpsweek=newrinexdata4.GPS.GPSWeek(1); % gpsweek은다중복,,
% 바꿀시간대=지금
% 자전이느려져서 +1초씩 추가 gpst랑맞춤(지금 지구가 18초느린상태).
newtxtime=txtime-mod(txtime,30)+30; % 걍 서브프레임1번으로 맞춤 내마음 ㅇㅇ
transmissionTime=HelperGPSConvertTime(gpsweek,newtxtime);% UTC
%transmissionTime=  transmissionTime+hours(3);  % !!수정 gpst로해야 서브프레임1부터시작 필수?
                                                 % datetime('now','TimeZone','UTC');
                                                   % datetime(2026,01,30,07,47,30,6)<됨
                                                   % == 2026,01,23 이랑 tow같음week다름
                                                   % datetime(2026,01,30,08,00,00,00)<안됨
                                                   % datetime(2026,01,21,08,00,00,0)<됨
                                                     %datetime(2006,06,07,08,00,00,0)
                                                   %<2026년으로 래핑안되서 그냥 내가 바꿔봄
                           % datetime(2026,01,20,22,00,00,0) 되다가 안되다가이럼
                           % datetime(2026,01,20,21,59,42,0) 16 interval
                                                   % datetime(2026,02,05,22,00,00,0)
                                                   % datetime(2026,02,05,22,00,00,0)
                                                   % gpst->+ 18 하면이게30초단위가딱됨 
                                                   % -----------SPAIN=-=-=-=-=-=
                                                   %1 :=datetime(2013,04,04,06,23,44,0);
                                                   %

                                 
transmissionTime.TimeZone=''; % TimeZone 비어있는값으로설정해야됨..
[newGPSWeek,newTOW]=HelperGPSConvertTime(transmissionTime); % UTC->GPST
if any(newGPSWeek~=[newrinexdata4.GPS.GPSWeek]) % MATLAB 위성시나리에오에서 GPSWEEK바껴도 갱신이안됨
    disp('의도한 transmissionTime과 rinex GPS week가 일치하지 않음.GPSWeek를 맞추세요');
    return
end
%IODE 랑 IODC를 바꿔야하는데 2시간마다 +1로 업데이트되는데 ->랜덤으로바꿀게
% dayinterval=day(transmissionTime)-day(newrinexdata2.GPS.Time); % 음수가나올때도잇
% interval=dayinterval*12 + (transmissionTime.Hour-floor(hour(newrinexdata2.GPS.Time)/2));
 
 newIODC=mod(newrinexdata4.GPS.IODC+randi([0 1023])+1,1023); % 그냥랜덤값더해주고
 newIODE=mod(newIODC,256);
% ------------> RINEXDATA에서 32PRN 최신 정보만 뽑아내고 -> HOWTOW위조상태에서 -> 현재시간기준으로 다시 스푸핑해보자..-//

% GPS.TIME= toc, gps.transmisstiontime=hotwo,gps.toe=toe 
%----------------!!수정 그냥 원본 유지 
% 아이게 하루전날껄로 해야되는이유가 큰 오차 혹은 REJECT되는게 있을거같음
% 그러면 오래된 RINEX여도 특정몇개만 바꿔 주기만해도  되지않을까?
% 어떤 정보를 바꿔야할지 확신이 서지 않는다.
% TOW는 수신기가 위치계산할때쓰이는 시간이라 너무 오래되면안될거 같음
% 바꿀수있는 궤도값들이있긴해 < 바꿔말아?
%newrinexdata2.GPS.GPSWeek(:)=newGPSWeek; % gpsweek추가 
  %newrinexdata2.GPS.Time(:)=newrinexdata2.GPS.Time(end); % toc 지금시간대 이건 추가해도될거같지않아  %!!수정 toe toc랑 같게햅보려고 
  newrinexdata4.GPS.TransmissionTime(:)=newTOW; % 위성시나리오땜에 지연계산 맞춰줘야되 HOWTOW만 최신
                                                % 아니면 txtime을 rienx추출가능하고%
 %newrinexdata2.GPS.Toe(:)=newrinexdata2.GPS.Toe(end); % TOE도 지금시간대  !!수정 toe빼볼게 
 newrinexdata4.GPS.IODC=newIODC; % 애네는 배열
newrinexdata4.GPS.IODE=newIODE; % 애네는 배열
% 만약 2시간 유효판정이있다면 최소TOE 바꿔야되고 ..TOC는 시계정보?어떻게바꿈
% 나머지궤도정보는 실제랑 유사하게할려면 시간에따라 계산해서 바꾸면되 이제 나머지는 위성시나리오가계산 
%----------------------
%%
% -sattelite scenario--
sc = satelliteScenario;
% Set up the satellites based on the RINEX data
sat = satellite(sc,newrinexdata4, 'OrbitPropagator', 'gps'); % 이게 ecef인지 gcrf인지 ..

rxlla=[35.682074 139.767112 8]; % !!수정수신기위치 서울RIENX면 서울
                              %모현도서관 37.33568 127.2496 57
                              %서울광화문 37.576266 126.976840 32
                              %일본 도쿄 35.682074 139.767112 8
                              %스페인예시 41.27506 1.987740 8
                          
 
rx = groundStation(sc,rxlla(1),rxlla(2)); % Set up the receiver which doesn't move
rx.MinElevationAngle = minElevationAngle; % 기본값 : 0도 30
sc.StartTime = transmissionTime; %
sc.SampleTime=stepTime;                                                                                                                         
sc.StopTime= sc.StartTime+seconds(waveDuration); %  (기본값~12시간)

% ---맥시멈 위성 ---
ac = access(sat,rx);
s = accessStatus(ac,transmissionTime);
idx=find(s,maximumsat,"first"); % 최대 위성갯수 ㅇ
%---



baseFrequency=0;
dopShifts = dopplershift(sat(idx),rx,Frequency=centerFrequency); % !!수정 centerfrequency->baseband
dopShifts= dopShifts.'; %!!수정 마이너스가맞는데? 뭐냐
                        %  dopshifts는 gcrf기준이라는데 
ltncy = latency(sat(idx),rx).'; % NaN값은 위성이 수평선(minElevationangle)넘어가버릴떄
                                   % single(latency(sat,rx).');
                                   % rx sat은진짜오래걸리네
%------------- ltncy와 dopshifts에 시간오차항추가-------------------
[~,toc]=HelperGPSConvertTime(newrinexdata4.GPS.Time(idx));
toc=toc.'-18; % !!수정 19년도이전 -16 이후-18
[~,t1]=HelperGPSConvertTime(transmissionTime);
t=t1:stepTime:t1+waveDuration;
dt=t.'-toc;  %행렬
af0 = newrinexdata4.GPS.SVClockBias((idx)).';       % 1 x Nsat (sec)
af1 = newrinexdata4.GPS.SVClockDrift((idx)).';      % 1 x Nsat (sec/sec)
%af2 = newrinexdata2.GPS.SVClockDriftRate.';  % 1 x Nsat (sec/sec^2, often 0)
terr=af0 + af1.*dt; % af2는 0이라서
doperr=af1*centerFrequency; % 1*31 을 50001*31에 전부빼면됨 ㅇ   
%----------------------------------- 보정항 빼기 수신기에서 더함 ㅇ
ltncy=ltncy-terr;  % 이거추가하니깐 gnss-sdr정확해짐ㅇ
 dopShifts=dopShifts+doperr; % !수정 도플러어케할건데 도플러는 부호반대농
%------------------------------------------------------------------
% 송신 SNR조절
c = physconst("LightSpeed"); % Speed of light in m/sec
% Pt = 44.8;                   % Typical transmission power of GPS satellite in watts
% 
% Dt = 0;                     % Directivity of the transmit antenna in dBi
% DtLin = db2pow(Dt);
% Dr = 0;                      % Directivity of the receive antenna in dBi
% DrLin = db2pow(Dr);
% k = physconst("boltzmann");  % Boltzmann constant in Joules/Kelvin
% T = 300;                     % Room temperature in Kelvin

% free-space path formula /firl'slaw
% Pr=Pt*Dt*Dr(파장/4pi *거리).^2    (파장=빛의속도/주파수)
% -> Pr=Pt*Dt*Dr(빛의속도/4pi*거리*주파수).^2
% -> Pr=Pt*Dt*Dr(1/4pi*지연초*주파수).^2
% Pr & SNR 필요없어
%Pr   = Pt*DtLin*DrLin./((4*pi*(centerFrequency+dopShifts).*ltncy).^2); % 1e-16 WATT보다 크면좋음(-160dBW)
% snrs = 10*log10(Pr/(k*T*sampleRate))+3; % 실제 수신하면 목표전력 보다 3dB 손실이발생해서 추가로넣어줌
% snrs= 수신기가완전히수신햇을때 신호/노이즈    % -16~-25나와야한다는데
                                      % 샘플레이트낮으면 -4dB = SNR좋음.
% 위성하나마다 snrs조절 작게만들고 
% 다합치고+ 노이즈 ?
% snrs는 위성마다 delay dopshifts가 다다르다 다다르게적용 즉작게만들고
% 다더한후 큰노이즈를 추가하기 그런다음 w=w/rms(w) < 이거는 ..왜? 노이즈도 줄고 신호도 일정비율로 줄여 ㅇㅇ

navcfg2 = HelperGPSRINEX2Config(almFileName,newrinexdata4.GPS(idx,:));
prnIDs=[navcfg2.PRNID]; 
 % satindices=~isnan(ltncy(1,:));
 % visbilePRN=prnIDs(satindices);
 disp( sat.Name);
disp("Available satellites - " + num2str(prnIDs));
if length(prnIDs)<4
    disp("Visble 위성 갯수는 4개 이상이여야 합니다.")
    return
end
%navcfg2=navcfg(satindices); % 유효한 navcfg만 다시 추출
%ltncy=ltncy(:,satindices); % 


% %ltncy=movsum(ltncy,2,1);ltncy=ltncy(2:end,:)./2;     % !수정 지연중간값
% % fd=gradient(ltncy.',stepTime); % 계산한 doppler
% % fd=-centerFrequency*fd.';
% dopShifts=-dopShifts(:,satindices); % !gcrf좌표계어쩌구 
%                                     % !수정 이거왜 음수가맞냐?
% %dopShifts=fd; % !수정 계산 vs 위성시나리오
% %snrs=pow2db(Pr(:, satindices)); % 1 1 1 1 1..
% one=ones(1, size(dopShifts,2));

zero=zeros(1, size(dopShifts,2));
snrs=zero; % db니깐 0이맞노
%%
%%---------비트만들기~ ----------%%
tempnavdata = HelperGPSNAVDataEncode(navcfg2(1)); %navcfg2(1) 의풀비트 37500비트(12.5분)
navdata = zeros(length(tempnavdata),length(navcfg2));
navdata(:,1) = tempnavdata;
for isat = 2:length(navcfg2)
    navdata(:,isat) = HelperGPSNAVDataEncode(navcfg2(isat));
end
wavegenobj.PRNID = prnIDs; % GPSwave만들때 prnid필요

gnsschannelobj = HelperGNSSChannel(FrequencyOffset=dopShifts(1,:), ...
    SignalDelay=ltncy(1,:), ...
    SignalToNoiseRatio=snrs(1,:), ...
    SampleRate=sampleRate);%RandomStream="Global stream",Seed=seed);%!!수정 캐리어주파수톤+100추가
 % -> 만약 
 numsteps = round(waveDuration/stepTime);
samplesPerStep = sampleRate*stepTime; % 1step=0.001s(1비트)=2046샘플
  

%numchannels = 1*enableImpairments + length(prnIDs(satindices))*(~enableImpairments); % 합치는설정=1개or각 위성수
gpswaveform = zeros(numsteps*samplesPerStep,numchannels);% 10초 40920000
    
numCACodeBlocksPerBit=20;
numCACodeBlocksPerStep=0.001/stepTime * numCACodeBlocksPerBit;
% 원하는 비트 만큼만 waveform생성 ㅇ.,,
% 

Fs = sampleRate;
fc = 1.2e6;  % 컷오프(대충 1.1~1.3 MHz 많이 씀) 최소 Fs/2



for istep = 1:numsteps

     CodeBlockNumber = mod(istep-1,numCACodeBlocksPerStep);
     if CodeBlockNumber == 0
         bitidx = floor((istep-1)/numCACodeBlocksPerStep)+1;
         OnebitWaveform = wavegenobj(navdata(bitidx,:));%   40920샘플
         OnebitWaveform = imag(OnebitWaveform)+1i*real(OnebitWaveform);
       
     end
 %  sampleidx=(istep-1)*samplesPerStep+(1:samplesPerStep);
 % ===================일단 위성 한개만해볼떄 수정구역==================
    iqsig = OnebitWaveform(CodeBlockNumber*samplesPerStep +(1:samplesPerStep),:);%!1위성만 먼저
 %    gnsschannelobj.FrequencyOffset = zero;
   gnsschannelobj.FrequencyOffset = dopShifts(istep,:); % !설정 1스텝 1위성만 적용

 %  gnsschannelobj.SignalDelay = zero;
     gnsschannelobj.SignalDelay =ltncy(istep,:);    % !설정 1스텝 1위성만 적용
   
     gnsschannelobj.SignalToNoiseRatio = snrs(1,:); % !설정 1스탭 1위성만 적용 
 % ===============================================================================

    waveform = gnsschannelobj(iqsig); % 1코드블록= 1/20 비트 씩 적용
    % gnssChannel에서 rms(w) 안하면 . e-10 엄청작음.. 
    % 파워정규화하면 1초과.. ...우움... 
    % 내가진폭을잘라야하나..
  
    gpswaveform((istep-1)*samplesPerStep+ (1:samplesPerStep),1)=waveform;
     %

end
%   % 필터제한
%        gpswaveform = lowpass(gpswaveform, fc, Fs, ...
%     'Steepness', 0.95, ...            % 전이대역 가파름(0~1)
%     'StopbandAttenuation', 60);       % 스톱밴드 감쇠(dB)
% fprintf("gps waveform생성 완 sampleRate: %d 길이 : %d \n",sampleRate,sampleRate*waveDuration)

gpswaveform=gpswaveform./ max(abs(gpswaveform)) ; %  절대값 크기가작을수록 더잘되는거같은데?..
% 필터?

%  gpswaveform=gpswaveform .* 0.5;
% MAX값 확인
% if max(real(gpswaveform))>1 || max(imag(gpswaveform))<-1
%     disp('신호값이 1 -1 을초과합니다 스케일링 다시 해주세요')
% end

% noise=

% int 16으로만들기 < 트랙킹 잘깨져서 포기 
int16gps=int16(round(gpswaveform(1:end).*32767)); % !!수정 앞에 0제거(samprate*0.1) or 

% 우분투로저장
UbuntuFileSave;
%UbuntuFileSave_float;

% % sdr전송하기..!
% runsdr=input('GPS waveform 생성 완료, SDR로 전송 1(yes) or 0(false) : ');
% if runsdr
%   txSig = gpswaveform(:); %  gpswaveform 크기1로맞춤 ㅇㅇ(0.7 + 0.7i로)
%  txSig = complex(single(txSig)); % pluto는 single선호
% loopback=true;
% createTx=true;
% createRx=true;
% 
% centerfrequency=1575.42e6; % GPS 1575.42e6
% fsampTx = sampleRate;  % jcg-401 최대역폭 20mhz
% fsampRx = fsampTx;  % 수신샘플링 다르면 오류.ㅜ 만들때보다 최소2배?
% % maxsampFrame 16777216(2*1.023e6 최대82초?가능)
% nsampsFrameTx = length(gpswaveform);       % 2^24=max값 
%                             % 프레임이너무길어서 빨리전송되나?
%                             % 내가볼때 원하는시간보다 늦지않을정도만 ㅇ
%                             % 즉 시간이길어줄수록 프레임많이 ..
% % nsampsFrameRx = 2048;
% 
% [sdrtx, sdrrx] = plutoCreateTxRx(createTx = createTx, createRx = createRx, loopback = loopback, ...
%     sampleRateRx=  fsampRx,sampleRateTx=fsampTx,centerFrequency=centerfrequency);
%  sdrtx.Gain=0; % 송신gain=0 최대0
% 
% if nsampsFrameTx<16777216  % 이걸프레임을 나누는게맞을까한번에보내는게맞는지
%      t0 = tic;
% 
% 
% 
%      sdrtx(gpswaveform);
% 
% 
%     fprintf('\n transmitted Code is Done. Now transmitting Total: %.2fs 초 경과\n', toc(t0));
%      % 사용 후 자원 해제
%         release(sdrtx);
% else %60초이상할려면 프레임초과가 당연함..
%     fprintf('GPswaveform의 길이가 최대 프레임갯수를 초과 했읍니다.')
% end
% 
% end