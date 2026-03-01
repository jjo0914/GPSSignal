% !! 핵심 파일명과 저장할 변수를 설정하기
%int16gps=Orign; % !!수정 따로저장할때 int16(round(Orign.*32767));
Path = '\\wsl.localhost\Ubuntu\root\gps_int'; % !!수정 끝에파일명
fid = fopen(Path,'wb'); % 바이너리는 wb?

testNoise=[real(int16gps) imag(int16gps)]; % !!수정 저장할 변수명 real imag 바꿀때
testNoise=testNoise.';   
fwrite(fid,testNoise(:),'int16'); % *2행렬을 선형으로 int16, float32,
fclose(fid);
disp('Ubuntu로 저장 완');
% 5e6 30초만 되도 엄청파일크기큼 1G가넘네