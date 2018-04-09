function[DataOut,biterror]= OFDMRX()
% function biterror = OFDMRX(B,N,Tu,FS,fc,M,MAX_SN,Data_par)
%The function used to demodulate the OFDM-signal created by the OFDMTX.m
load OFDMspace.mat;
load MAX_SN.mat;
Fs_sound=[];
% B = B; %Bandwidth
% N = N; %Number of carriers
% Tu = Tu; %Symbol length
% FS=FS; %Sampling freq
T = 1/FS; %Elementary period
% fc = fc; %Carrier freq
tt = 0:T:Tu; %Time vector
% M = M; %Number of symbols - reference symbol
f = (1:FS); %Frequency vector
ttotal= 0:T:Tu*(M+1)+M*T; %Total signal time
%Reference vector
% Data_par = Data_par;
%RECEPTION
max_sn = MAX_SN;
% ref_normalized = REF;
[m_normalized d] = wavread('signal');
m = max_sn.*m_normalized;
% ref = max_sn.*ref_normalized;
%Removing delay and synchronizing
m_sync = zeros(length(m_normalized),1);
m_short = m(1:400000);
x = xcorr(ref, m_short);
[C I] = max(x);
delay = length(m_short)-I;
if delay < 0
    delay = 0;
end
m_sync(1:(length(m)-delay),1) = m((delay+1):(length(m)));
m_no_guard = zeros(1, length(ttotal));
active = 0;
for symbreceived = 1:M+1;
    %Removing guard
    m_no_guard = m_sync((1+(length(tt)*(symbreceived-1))+guard_samples*(symbreceived-1)*active):length(tt)*symbreceived+guard_samples*(symbreceived-1)*active);
    if symbreceived == 1
        ref_chan = m_no_guard;
    end
    %Downshifting
    r_tilde = m_no_guard.*exp(-i*2*pi*fc*tt');
    %Lowpass filtering
    [bb aa] = butter(13, 1/2);
    r = filter(bb, aa, r_tilde);
    %OFDM
    info(1:length(r),symbreceived) = (1/FS).*fft(r);
    %Removing Zero padding
    info_1(1:(N/2),symbreceived) = info(1:freq_space_factor:(freq_space_factor*(N/2)), symbreceived);
    info_1((N/2+1):N, symbreceived) = info((length(tt)-(freq_space_factor*(N/2)-1)):freq_space_factor:length(tt), symbreceived);active = 1;
end
info_1_dim = size(info_1);
data = zeros(N, M);
phase_shift_2 = zeros(N, M);
for rr = 2:info_1_dim(2);
    for ss = 1:info_1_dim(1);
        %Finding the phase difference
        phase_shift_2(ss,rr-1) = info_1(ss,rr)*conj(info_1(ss, rr-1));
        %Demodulating the differential coding
        if abs(imag(phase_shift_2(ss,rr-1)))>abs(real(phase_shift_2(ss,rr-1)));
            if imag(phase_shift_2(ss,rr-1))<0; %-i
                data(ss,rr-1) = 1-i;
            elseif imag(phase_shift_2(ss,rr-1))>0; %i
                data(ss,rr-1) = -1+i;
            end
            elseif abs(imag(phase_shift_2(ss,rr-1)))<abs(real(phase_shift_2(ss,rr-1)));
            if real(phase_shift_2(ss,rr-1))<0; %-1
                data(ss,rr-1) = 1+i;
            elseif real(phase_shift_2(ss,rr-1))>0; %1
                data(ss,rr-1) = -1-i;
            end
        end
    end
end
%Finding the QPSK errors
QPSK_errors = 0;
for k = 1:M
    for l = 1:N
        if data(l,k)==Data_par(l,k)
            QPSK_errors = QPSK_errors;
        else
            QPSK_errors = QPSK_errors + 1;
        end
    end
end
DataIn = DataIn;
DataOut = QPSKdemodulator(data, N, M);
%If data_type is sound, a wav-file is created
if strcmp(data_type, 'sound');
    wavData = writeSound(DataOut, Fs_sound, bits, plots);
end
%Comparing the DataOut vector with DataIn vector
bit_errors = 0;
for j = 1:length(DataOut);
    if DataOut(j)==DataIn(j);
        bit_errors = bit_errors;
    else
        bit_errors = bit_errors + 1;
    end
end
% clc;
% %display in MATLAB
% disp(['OFDM PARAMETERS:'])
% disp(['Data type: ',data_type])
% disp(['Symbol length: ',num2str(Tu),' s'])
% disp(['Number of carriers: ',num2str(N)])
% disp(['Number of symbols: ',num2str(M)])
% disp(['Guard time: ',num2str(guard),' s'])
% disp([' '])
% disp(['CHANNEL PARAMETERS:'])
% disp(['Signal to noise ratio: ' num2str(SNR) ' dB'])
% disp(['Phase error: ' num2str(phase_error) ' rad'])
% disp(['Impulseresponse: ' num2str(impulseresponse) ' : 1 Enabled, 0 disabled'])
% disp(['Delay: ' num2str(channel_delay) ' s'])
% disp([' '])
biterror = bit_errors/length(DataOut);
% disp(['RESULTS:'])
% disp(['Number of QPSK-symbol errors: ' num2str(QPSK_errors) '/' num2str(M*N)])
% disp(['Number of bit errors: ' num2str(bit_errors)  '/' num2str(length(DataOut))])
% disp(['BER: ' num2str(biterror)])
% disp([' '])
save('ref_chan.mat', 'ref_chan')
if plots == 1
    plotstep3(f,FS,r,phase_shift_2,SNR,data,DataOut,Fs_sound,data_type)
end
end


%The function used to retrieve bits from the QPSK-symbols
function [a_data] = QPSKdemodulator(data, N, M)
dim = size(data);
a_data = zeros(2*N*M,1);
p = 2;
%Retrieving bits from the QPSK-symbol
for j = 1:1:dim(2);
    for k = 1:1:dim(1)
        if data(k,j) == 1 + i;
            a_data(p-1)=1;
            a_data(p)=1;
        elseif data(k,j) == -1 + i;
            a_data(p-1)=0;
            a_data(p)=1;
        elseif data(k,j) == 1 - i;
            a_data(p-1)=1;
            a_data(p)=0;
        elseif data(k,j) == -1 - i;
            a_data(p-1)=0;
            a_data(p)=0;
        end
        p = p + 2;
    end
end
end