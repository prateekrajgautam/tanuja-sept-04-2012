function[]=OFDMTX(Tu, B, guard, data_type,N,M,FS,fc, plots,DataIn)
%s_tot=OFDMTX(symbollength, bandwidth, guard_time, 'random', numberofcarriers,numberofsymbols,Sampling_freq,Carrier_freq, plots);
Data1=[];
freq_space_factor = round(B*Tu/N); %Factor spacing of the frequency spectrum
T = 1/FS; %Elementary period for under water channel
guard_samples = round(guard/T); %Guard time in samples
tt = 0:T:Tu; %Time vector
t_guard = 0:T:(Tu+guard) ; %Time vector including guard time
f = (1:FS); %Frequency vector
ttotal= 0:T:(Tu*(M+1)+M*T+(M)*guard); %Total time including delay and guard
%% TRANSMISSION
%% Generating QPSK data
Data_QPSK = QPSKmodulator(DataIn);
%% Seral to parallell data
Data_par=reshape(Data_QPSK,numel(Data_QPSK)/M,M);


%% DPSK
%Creating a random reference symbol
rand('state',1)
bb = -1+2*round(rand(1,N)).'+i*(-1+2*round(rand(1,N))).';
%% Mapping the symbols as a phasedifference
phase_shift = zeros(N, M);
Data_phase_diff = zeros(N, M+1);
Data_phase_diff(1:N,1) = bb./sqrt(2); %Normalize the reference symbol
dim = size(Data_phase_diff);
for pp = 2:dim(2);
    for qq = 1:dim(1)
        if Data_par(qq,pp-1) == 1+i;
            phase_shift(qq,pp-1) = -1;
        elseif Data_par(qq,pp-1) == -1-i;
            phase_shift(qq,pp-1) = 1;
        elseif Data_par(qq,pp-1) == -1+i;
            phase_shift(qq,pp-1) = i;
        elseif Data_par(qq,pp-1) == 1-i;
            phase_shift(qq,pp-1) = -i;
        end
        %creating a vector where the phasedifference is b-vector
        Data_phase_diff(qq,pp) =(1/abs(phase_shift(qq,pp-1)))*phase_shift(qq,pp-1) *(1/abs(Data_phase_diff(qq,pp-1)))*Data_phase_diff(qq,pp-1);
    end
end
%Zero padding
A = size(Data_phase_diff);
info = zeros(length(tt), M+1);
for zz = 1:M+1
    info(1:freq_space_factor:(freq_space_factor*(N/2)),zz) = [Data_phase_diff(1:N/2,zz)];
    info(length(tt)-(freq_space_factor*(N/2)-1):freq_space_factor:length(tt),zz) =[Data_phase_diff((N/2+1):A(1),zz)]; %Zeros placed in the middle of the data
end
%Creating M+1 OFDM symbols
%% OFDM
for symbol = 1:M+1; 
    carriers = FS.*ifft(info(1:length(info),symbol));
    %Upshifting
    s_tilde = carriers.*exp(i*2*pi*fc*tt');
    %Inserting guard
    s_guard = zeros(1, length(t_guard));
    s_guard((guard_samples+1):length(s_guard)) = s_tilde;
    %Creating the total signal
    s_tot((1+(symbol-1)*length(s_guard)):length(s_guard)*symbol) = s_guard;
    %Saving the reference symbol
    if symbol==1;
        ref = real(s_tilde);
    end
end
s = real(s_tot(guard_samples+1:length(s_tot)));
%% Creating wave file
MAX_SN = max(abs(s_tot));
wavwrite(s/MAX_SN, FS, 'signal');
%% Saving variables
save('OFDMspace.mat', 'ref', 'Data_par', 'DataIn', 'N', 'M', 'B', 'FS', 'fc','s', 'T', 'Tu', 'f', 'guard', 'guard_samples', 'data_type', 'plots','freq_space_factor');

% if strcmp(data_type, 'sound');
%     save('OFDMspace.mat', 'ref', 'Data_par', 'DataIn', 'N', 'M', 'B', 'FS', 'fc','Fs_sound', 'bits', 's', 'T', 'Tu', 'f', 'guard', 'guard_samples', 'data_type','plots', 'freq_space_factor');
% elseif strcmp(data_type, 'random');
%     save('OFDMspace.mat', 'ref', 'Data_par', 'DataIn', 'N', 'M', 'B', 'FS', 'fc','s', 'T', 'Tu', 'f', 'guard', 'guard_samples', 'data_type', 'plots','freq_space_factor');
% end
if plots == 1
    plotstep1(Data1,DataIn,data_type,Data_QPSK,f,carriers, FS,N,phase_shift,s)
end
end


function [b] = QPSKmodulator(bit_vector)
a_d = bit_vector;
b = zeros(length(a_d)/2,1);
k = 1;
%Mapping two by two bits on to a QPSK-symbol
for j = 2:2:length(a_d);
    if a_d(j-1)==1 & a_d(j)==1;
        b(k) = 1 + i;
    elseif a_d(j-1)==0 & a_d(j)==1;
        b(k) = -1 + i;
    elseif a_d(j-1)==1 & a_d(j)==0;
        b(k) = 1 - i;
    elseif a_d(j-1)==0 & a_d(j)==0;
        b(k) = -1 - i;
    end
    k = k + 1;
end
end