function[]=plotstep1(Data1,DataIn,data_type,Data_QPSK,f,carriers, FS,N,phase_shift,s)
%Plots
if strcmp(data_type, 'sound');
%Plot of soundIn and the binary stream
t = 0:1/Fs_sound:(length(Data1)-1)/Fs_sound;
figure();
subplot(211)
plot(t, (Data1-(2^(bits-1)))/(2^(bits-1)));
title('Wave-file to be transmitted')
axis([0 0.35 -0.6 0.6]);
xlabel('Time - Seconds')
ylabel('Amplitude')
subplot(212)
stem(DataIn(1:24));
title('Bit stream DataIn ');
axis([0 24 -0.5 1.5]);
set(gca,'ytick',[0 1]);
xlabel('Bit number');
ylabel('Bit value');
else
figure()
stem(DataIn(1:24));
title('Bit stream DataIn ');
axis([0 24 -0.5 1.5]);
set(gca,'ytick',[0 1]);
xlabel('Bit number');
ylabel('Bit value');
end
%Plot of the QPSK symbols
figure();
subplot(211);
stem(real(Data_QPSK(1:12)));
title('The real part of the Data\_QPSK-vector');
axis([0 12 -1.5 1.5]);
set(gca,'ytick',[-1 1]);
xlabel('Symbol number');
ylabel('Value');
subplot(212);
stem(imag(Data_QPSK(1:12)));
title('The imaginary part of the Data\_QPSK-vector');
axis([0 12 -1.5 1.5]);
set(gca,'ytick',[-1 1]);
xlabel('Symbol number');
ylabel('Value');
%Plot of the QPSK symbols
figure();
plot(Data_QPSK,'LineStyle','none', 'Marker','x', 'MarkerSize',10);
title('QPSK symbol constallation');
axis([-1.5 1.5 -1.5 1.5]);
grid on;
xlabel('Real');
ylabel('Imag');
%Plot of the received phase shifts before decision
figure();
plot(phase_shift(1:N,1),'LineStyle','none', 'Marker','x', 'MarkerSize',10);title('Phase difference');
axis([-1.5 1.5 -1.5 1.5]);
grid on;
xlabel('Real');
ylabel('Imag');
%Plot of the baseband spectrum
figure();
subplot(211);
plot(f/1000, abs(fft(carriers, FS))/FS);
title('Spectrum of the carriers-vector');
axis([0 192 0 3]);
xlabel('Frequency - kHz');
ylabel('Amplitude');
subplot(212);
pwelch(carriers,[],[],[],FS);
%Plot of the frequency spectrum of s(t)
figure();
subplot(211);
plot(f/1000, abs(fft(real(s), FS))/FS);
title('Spectrum of s(t)');
axis([35 41 0 3]);
xlabel('Frequency - kHz');
ylabel('Amplitude');
subplot(212);
pwelch(real(s),[],[],[],FS);
axis([35 41 -50 20]);
end