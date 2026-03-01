classdef HelperGNSSChannel < matlab.System
    % HelperGNSSChannel Add channel impairment
    %
    % Note: This is a helper and its API and/or functionality may change
    % in subsequent releases.
    %
    %   GNSSCHAN = HelperGNSSChannel creates a GNSS (Global navigation
    %   satellite system) channel object. It add three impairments to the
    %   input waveform. The added impairments are frequency offset, signal
    %   delay and AWGN.
    %   
    %   WAVE = HelperGNSSChannel(IQ) generates an impaired waveform WAVE.
    %   IQ is a vector that contains a GNSS waveform.
    %
    %   GNSSCHAN = HelperGNSSChannel(Name,Value) creates a GNSS channel
    %   object, GNSSCHAN, with the specified property Name set to the
    %   specified Value. You can specify additional name-value pair
    %   arguments in any order as (Name1,Value1,...,NameN,ValueN).
    % 
    %   HelperGNSSChannel methods:
    %
    %   step          -  Generate a waveform impaired with GNSS channel
    %   release       -  Allow property value and input characteristics
    %                    changes
    %   clone         -  Create a GNSS channel object with same
    %                    property values
    %   isLocked      -  Locked status (logical)
    %   reset         -  Reset states of GNSS channel object
    %
    %   HelperGNSSChannel properties:
    %   SampleRate                - Sample rate
    %   IntermediateFrequency     - Intermediate frequency
    %   DisableImpairments        - Option to disable all the channel impairments
    %   SignalToNoiseRatio        - SNR of each satellite
    %   SignalDelay               - Signal delay of each satellite signal
    %   FrequencyOffset           - Frequency offset of each satellite signal
    %   RandomStream              - Random number source
    %   Seed                      - Initial seed
    % 
    %   % Example 1:
    %   gnssChann = HelperGNSSChannel;
    %   waveSample = 1-1i;
    %   waveform = gnssChann(waveSample);
    % 
    %   See also HelperNavICBBWaveform
    
    %   Copyright 2024-2025 The MathWorks, Inc.

    properties
        %SignalToNoiseRatio SNR of each satellite
        %   Specify signal to noise ratio (SNR) in dB as a vector of length
        %   corresponding to the SNR of each satellite signal. If this is a
        %   scalar, then the same value is applicable to all the input
        %   signals. This property is applicable only when
        %   DisableImpairments is set to false. Default is 1. This property
        %   is tunable.
        SignalToNoiseRatio = 1; % In dB
        %SignalDelay Signal delay of each satellite signal
        %   Specify the signal delay in seconds as a vector of length
        %   corresponding to the delay of each satellite signal. If this is
        %   a scalar, then the same value is applicable to all the input
        %   signals. This property is applicable only when
        %   DisableImpairments is set to false. Default is 0 sec. This
        %   property is tunable.
        SignalDelay = 0; % In seconds
        %FrequencyOffset Frequency offset of each satellite signal
        %   Specify the frequency offset in Hz as a vector of length
        %   corresponding to the frequency offset of each satellite signal.
        %   If this is a scalar, then the same value is applicable to all
        %   the input signals. This property is applicable only when
        %   DisableImpairments is set to false. Default is 0 Hz. This
        %   property is tunable.
        FrequencyOffset = 0; % In Hz
    end
    % Public, non-tunable properties
    properties (Nontunable)
        %SampleRate Sample rate
        %   Specify the sample rate of the waveform in Hz. Default is 5e6 Hz.
        SampleRate = 5e6;  % In samples/sec
        %IntermediateFrequency Sample rate
        %   Specify the intermediate frequency of the output waveform in
        %   Hz. When this value is zero, output is a complex base-band
        %   waveform, else the output is a real waveform. Default is 0 Hz.
        IntermediateFrequency = 0; % In Hz
        %DisableImpairments Option to disable all the channel impairments
        %   Option to disable all the channel impairments. Default is
        %   false.
        DisableImpairments (1,1) logical = false % When true output signal will be in base-band only
        %RandomStream Random number source
        %   Specify the source of random number stream as one of "Global
        %   stream" | "mt19937ar with seed". If RandomStream is set to
        %   "Global stream", the current global random number stream is
        %   used for additive white Gaussian noise generation, in which
        %   case the reset method only resets the filters. If RandomStream
        %   is set to "mt19937ar with seed", the mt19937ar algorithm is
        %   used for additive white Gaussian noise generation, in which
        %   case the reset method not only resets the filters but also
        %   re-initializes the random number stream to the value of the
        %   Seed property. The default value is "Global stream".
        RandomStream (1,1) string {matlab.system.mustBeMember(RandomStream, ...
            {'Global stream','mt19937ar with seed'})} = "Global stream"
        %Seed Initial seed
        %   Specify the initial seed of a mt19937ar random number generator
        %   algorithm as a non-negative integer scalar. This property
        %   applies when you set the RandomStream property to
        %   "mt19937ar with seed". The default value is 73.
        Seed = 73
    end

    properties(Nontunable,Hidden)
        % Noise variance, Nr = K (Boltzmann constant)* T (Temperature in kelvin) * B (bandwidth in hertz)
        NoiseVariance;  % Thermal noise power in watts
    end

    % Pre-computed constants or internal states
    properties (Access = private)

        pIsConstantDelayPresent
        pSamplesPerFrame

        pNumSamplesWithConstantDelay

        pConstDelayObj
        pVariableDelayObj
        pFrequencyOffsetObj

                           % Pre-compute exp() to save execution time in the step method
        pExpPower1jXPhases % Don't save but re-calculate when loading

        pIFSampleIndex

        % Random stream object for "mt19937ar with seed"
        pRNGStream

    end

    methods
        % Constructor
        function obj = HelperGNSSChannel(varargin)
            % Support name-value pair arguments when constructing object
            setProperties(obj,nargin,varargin{:})
        end

        % Set methods
        function set.Seed(obj, val)
            prop = 'Seed';
            validateattributes(val,{'double','single','uint32'}, ...
                {'scalar','integer','nonnegative','<=',intmax('uint32')}, ...
                [class(obj) '.' prop],prop);
            obj.(prop) = val;
        end
    end

    methods (Access = protected)
        %% Common functions
        function setupImpl(obj,u)
            % Perform one-time calculations, such as computing constants

            fs = obj.SampleRate;
            obj.NoiseVariance =1; % 스마트폰잡음
            % Initialize the delay object
            numSamplesDelay = fs*obj.SignalDelay(1,:); % This can be a fractional value too
            maxDelayForFractionalFilter = 6e4; % Actually, it is 65536
            obj.pIsConstantDelayPresent = false;
            obj.pNumSamplesWithConstantDelay = 0;
            if numSamplesDelay>maxDelayForFractionalFilter
                % Then barring 30k samples, model the entire delay using
                % dsp.Delay
               
                obj.pNumSamplesWithConstantDelay = round(numSamplesDelay-maxDelayForFractionalFilter/2);
                obj.pConstDelayObj = dsp.Delay(obj.pNumSamplesWithConstantDelay); % 딜레이 30k sample빼고 나머지
                obj.pIsConstantDelayPresent = true;
            end
            obj.pVariableDelayObj = dsp.VariableFractionalDelay("MaximumDelay",65535,"InterpolationMethod","Linear");
            % samplerate 2*1.023e6 에서 0.03초차이 까지는커버가능
 
            % Initialize the object for frequency offset
            obj.pFrequencyOffsetObj = comm.PhaseFrequencyOffset("FrequencyOffsetSource","Input port","SampleRate",fs);

            % Set up the random number generation
            setupRNG(obj);

            % Pre-compute some constants to save some memory. But then
            % don't save these properties. Rather re-compute when loading
            obj.pSamplesPerFrame = size(u,1);
            if obj.IntermediateFrequency~=0
                obj.pExpPower1jXPhases = exp(1j*2*pi*obj.IntermediateFrequency*(0:(obj.pSamplesPerFrame-1)).'/fs);
            end
        end

        function y = stepImpl(obj,signal)
            % Implement algorithm. Calculate y as a function of input u and
            % internal or discrete states.
            validateattributes(signal,{'double','single'},...
                {'finite'},mfilename,'SIGNAL');

            y = distortionsCore(obj,signal);
        end

        function resetImpl(obj)
            % Initialize / reset internal or discrete states
            obj.pIFSampleIndex = 0;

            % Reset the System objects used in the code
            if ~isempty(obj.pConstDelayObj)
                reset(obj.pConstDelayObj);
            end
            if ~isempty(obj.pVariableDelayObj)
                reset(obj.pVariableDelayObj);
            end
            if ~isempty(obj.pFrequencyOffsetObj)
                reset(obj.pFrequencyOffsetObj);
            end
            resetRNG(obj)
        end

        %% Backup/restore functions
        function s = saveObjectImpl(obj)
            % Set properties in structure s to values in object obj

            % Set public properties and states
            s = saveObjectImpl@matlab.System(obj);
            
            % Save private and protected properties
            if isLocked(obj)
                s.pNumSamplesWithConstantDelay = obj.pNumSamplesWithConstantDelay;
                s.pIsConstantDelayPresent      = obj.pIsConstantDelayPresent;
                s.pIFSampleIndex               = obj.pIFSampleIndex;
                s.pRNGStream                   = obj.pRNGStream;
                s.pSamplesPerFrame             = obj.pSamplesPerFrame;

                if ~isempty(obj.pConstDelayObj)
                    s.pConstDelayObj = matlab.System.saveObject(obj.pConstDelayObj);
                end
                if ~isempty(obj.pVariableDelayObj)
                    s.pVariableDelayObj = matlab.System.saveObject(obj.pVariableDelayObj);
                end
                if ~isempty(obj.pFrequencyOffsetObj)
                    s.pFrequencyOffsetObj = matlab.System.saveObject(obj.pFrequencyOffsetObj);
                end
            end
        end

        function loadObjectImpl(obj,s,wasLocked)
            % Set properties in object obj to values in structure s

            % Set public properties and states
            loadObjectImpl@matlab.System(obj,s,wasLocked);

            % Set private and protected properties
            if wasLocked
                obj.pNumSamplesWithConstantDelay = s.pNumSamplesWithConstantDelay;
                obj.pIsConstantDelayPresent = s.pIsConstantDelayPresent;
                obj.pIFSampleIndex = s.pIFSampleIndex;
                obj.pSamplesPerFrame = s.pSamplesPerFrame;


                if obj.IntermediateFrequency~=0
                    obj.pExpPower1jXPhases = exp(1j*2*pi*obj.IntermediateFrequency*(0:(obj.pSamplesPerFrame-1)).'/obj.SampleRate);
                end

                if isfield(s,'pConstDelayObj') && ~isempty(s.pConstDelayObj)
                    obj.pConstDelayObj = matlab.System.loadObject(s.pConstDelayObj);
                end
                if isfield(s,'pVariableDelayObj') && ~isempty(s.pVariableDelayObj)
                    obj.pVariableDelayObj = matlab.System.loadObject(s.pVariableDelayObj);
                end
                if isfield(s,'pFrequencyOffsetObj') && ~isempty(s.pFrequencyOffsetObj)
                    obj.pFrequencyOffsetObj = matlab.System.loadObject(s.pFrequencyOffsetObj);
                end

                setupRNG(obj);
                if isfield(s,'pRNGStream') && ~isempty(s.pRNGStream)
                    obj.pRNGStream.State = s.pRNGStream.State;
                end
            end
        end

        %% Advanced functions
        function flag = isInputSizeMutableImpl(~,~)
            % Return false if input size cannot change
            % between calls to the System object
            flag = false;
        end

        function flag = isInactivePropertyImpl(obj,prop)
            % Return false if property is visible based on object
            % configuration, for the command line and System block dialog
            flag = false;
            if any(strcmp(prop,{'SignalToNoiseRatio','SignalDelay','FrequencyOffset','RandomStream'}))
                flag = obj.DisableImpairments;
            elseif strcmp(prop,'Seed')
                flag = strcmp(obj.RandomStream,'Global stream') || obj.DisableImpairments;
            end
        end
    end

    % Methods that are specifically written for implementing the
    % propagation channel
    methods(Access=protected) % Methods here can be used by the inherited classes
        function wave = distortionsCore(obj,bbwave)

            numSamples = size(bbwave,1);
            numSats=size(bbwave,2);
            fc = obj.IntermediateFrequency;
            fs = obj.SampleRate;
            if obj.DisableImpairments
                if fc~=0
                    ifwave = real(bbwave.*obj.pExpPower1jXPhases.*exp(1j*2*pi*fc*obj.pIFSampleIndex/fs));
                    obj.pIFSampleIndex = obj.pIFSampleIndex + numSamples;
                else
                    ifwave = bbwave;
                end
                wave = ifwave;
            else
                        % Nr= 신호전력* 샘플레이트/db2pow(CN0)
          %      CN0=53; %% dB-HZ 샘플레이트가높아지면 높아지네
                        % 값이 per위성을 의도한거라 노이즈를 위성갯수만큼 더작게해야해
         %        Nr = obj.SampleRate/db2pow(CN0)./numSats; % 신호전력은1 노이즈전력이1 SNR=pathloss면..
                % currentSNR=db2pow(obj.SignalToNoiseRatio); % 1*위성
                % %currentSNR = matchrowsize(10.^(obj.SignalToNoiseRatio/10),numSamples); % Convert to linear form and match size to number of samples in input
                % sqrtSignalPower = sqrt(currentSNR*Nr); % Nr=1이니깐 신호전력 1w에서->snr로 조절

                % Frequency offset -> 시간에따라도는위상? 도플러?
                fcfo = matchrowsize(obj.FrequencyOffset,numSamples);
                bbwave = obj.pFrequencyOffsetObj(bbwave,fcfo); % x[n]*e^i*2pi*df*n / fs

                % Up-convert

                if fc~=0
                    ifwave = real(bbwave.*obj.pExpPower1jXPhases.*exp(1j*2*pi*fc*obj.pIFSampleIndex/fs));
                    obj.pIFSampleIndex = obj.pIFSampleIndex + numSamples;
                else
                    ifwave = bbwave;
                end

                % Delay
                %numSamplesDelay = matchrowsize(fs*obj.SignalDelay,numSamples); % This can be a fractional value too
                numSamplesForRemainingDelay = fs*obj.SignalDelay(1,:) - obj.pNumSamplesWithConstantDelay;
                                         
                if obj.pIsConstantDelayPresent
                    ifwave = obj.pConstDelayObj(ifwave); % 계속 상수딜레이 적용 
                   
                end
                % delay를 샘플마다 적용 % 원래numSamplesForRemainingDelay 를 1번적용
                %sampledelay= (1:numSamples).'.*numSamplesForRemainingDelay/numSamples ;
 
                ifwave = obj.pVariableDelayObj(ifwave,double(numSamplesForRemainingDelay));%ifwave = obj.pVariableDelayObj(ifwave,double(numSamplesForRemainingDelay))

                % Scale the signal
               %  rmsPow = rms(ifwave); % rms로나누면 만들어진신호 총 1W로 맞춤 
               %                        %rms는 위성1열씩 계산 
               %  rmsPow(rmsPow==0) = 1; % NaN예방
               % % ifwave = sqrtSignalPower.*ifwave./rmsPow; % rms로나누고 원하는power의 sqrt곱하면 전력조정
                                                            % % ifwave는 굳이안건들어도 전력1이긴해

                % Sum up signals from several satellites
                waveform = sum(ifwave,2) ;% power1의 신호 다 더하면 power 엄청커짐

               % % Generate and add noise
               %  if strcmp(obj.RandomStream,"Global stream")
               %      if fc~=0 % Real noise
               %          noisesig = wgn(numSamples,1,10*log10(Nr));
               %      else % Complex baseband noise
               %          noisesig = (wgn(numSamples,1,10*log10(Nr)) + 1j*wgn(numSamples,1,10*log10(Nr)))./sqrt(2);
               %      end
               %  else
               %      if fc~=0 % Real noise
               %          noisesig = wgn(numSamples,1,10*log10(Nr),1,obj.pRNGStream);
               %      else % Complex baseband noise
               %          noisesig = (wgn(numSamples,1,10*log10(Nr),1,obj.pRNGStream) + 1j*wgn(numSamples,1,10*log10(Nr),1,obj.pRNGStream))./sqrt(2);
               %      end
               %  end
                 rmsPow = rms(waveform);
                 rmsPow(rmsPow==0) = 1;
                waveform=waveform./rms(rmsPow); % 전체위성전력 1
                w = waveform ;%+ noisesig;% 굳이노이즈를추가해야함?
                wave=w;   
               
                % 피크정규화는 맨마지막에 한번만하래
        %       wave = w/max(abs(w));   % rms(w) 로 전력 1맞추기 vs 피크1로맞추기
       %       wave=w/rms(w); %마지막에만 하래 0000땜에
        %      wave=0.9.*wave; % 살짝여유
                              
                    
         
            end
        end
    end

    methods(Access = private)
        function setupRNG(obj)
            % Setup the random number generator if it is not global stream
            if ~strcmp(obj.RandomStream,"Global stream")
                if isempty(coder.target)
                    obj.pRNGStream = ...
                        RandStream('mt19937ar','Seed',obj.Seed);
                else
                    obj.pRNGStream = coder.internal.RandStream( ...
                        'mt19937ar','Seed',obj.Seed);
                end
            end
        end

        function resetRNG(obj)
            % Reset random number generator if it is not global stream
            if ~strcmp(obj.RandomStream,"Global stream")
                reset(obj.pRNGStream,obj.Seed);
            end
        end
    end
    methods (Access = protected, Static)
        function group = getPropertyGroupsImpl
            % Define property section(s) for System block dialog
            genprops = {'SampleRate', ...
                'IntermediateFrequency', ...
                'DisableImpairments', ...
                'FrequencyOffset', ...
                'SignalDelay', ...
                'SignalToNoiseRatio', ...
                'RandomStream', 'Seed'};
            group = matlab.system.display.SectionGroup('PropertyList', genprops);
        end
    end
end

function y = matchrowsize(x,n)
%matchrowsize matches the input size to the specified number of samples by repeating
%each element value
%
%   Y = matchrowsize(X,N) Treats each column in X as a separate input and expands
%   X to have N number of rows to form Y. Each element of a column in X is repeated
%   by a factor of N/size(X,1). Number of columns in Y will be same as that of in X.

downfac = size(x,1);
idx = 1:downfac:n*downfac;
y = x(ceil(idx/n),:);
end
