%The function used to simulate the channel
function sn_delay = channelMod(channel_delay, SNR, phase_error, impulseresponse)
load OFDMspace.mat;
timpulse=[];
impresp=[];
s_conv=[];
t_conv=[];
delay_samples = round(channel_delay/T);
ttotal= 0:T:(Tu*(M+1)+M*T+T*delay_samples+(M)*guard); %Total time including delay
%CHANNEL MODELING
%phase error
theta = zeros(1,length(ttotal));
if phase_error > 0
    %Linear phase error
    theta = 0:(phase_error)/(length(s)):(phase_error);
end
s_phase_error = s.*exp(i.*-theta(1:length(s)));
s_phase_error_real = real(s_phase_error);
%Adding white gausian noise
S_0 = mean(s_phase_error_real.^2);
if SNR ~= -1
    sigma = S_0/(10^(SNR/10));
else
    sigma = 0;
    SNR = inf;
end
AWGN = sigma*randn(size(s_phase_error_real));
sn = s_phase_error_real + AWGN;
%Adding delay
sn_delay = zeros(1,length(sn)+delay_samples);
sn_delay((delay_samples+1):length(sn_delay)) = sn;
%Multipaths
if impulseresponse == 1
    impulselength = 20e-3;
    timpulse = 0:T:impulselength;
    impresp = zeros(1, length(timpulse));
    impresp(1) = 1;
    impresp(200) = 0.6;
    impresp(400) = 0.4;
    impresp(600) = 0.3;
    impresp(800) = 0.25;
    s_conv = conv(sn_delay, impresp);
    t_conv = 0:T:(impulselength+ttotal(length(ttotal)));
    %Creating wave file
    MAX_SN = max(abs(s_conv));
    wavwrite(s_conv/MAX_SN, FS, 'signal');
    REF = ref/MAX_SN;
else
    %Creating wave file
    MAX_SN = max(abs(sn));
    wavwrite(sn_delay/MAX_SN, FS, 'signal');
    REF = ref/MAX_SN;
end
save('MAX_SN.mat', 'MAX_SN', 'SNR', 'phase_error', 'impulseresponse', 'channel_delay');
if plots ==1
    plotstep2(ttotal,f,sn,FS,sn_delay,impulseresponse,timpulse,impresp,s_conv,t_conv,theta)
end
% plot(h);