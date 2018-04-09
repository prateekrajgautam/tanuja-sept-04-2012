function[]=plotstep3(f,FS,r,phase_shift_2,SNR,data,DataOut,Fs_sound,data_type)
%Plot of the baseband spectrum
figure();
subplot(211);
plot(f/1000, abs(fft(r, FS))/FS);
title('Spectrum of the received signal r(t)');
axis([0 192 0 1.5]);
xlabel('Frequency - kHz');
ylabel('Amplitude');
subplot(212);
pwelch(r,[],[],[],FS);
%Plot of the received phase shifts before decision
figure();
plot(phase_shift_2,'LineStyle','none', 'Marker','x', 'MarkerSize',10);
title(['Phase difference - SNR ', num2str(SNR), 'dB']);
axis([-0.5 0.5 -0.5 0.5]);
grid on;
xlabel('Real');
ylabel('Imag');
%Plot of the first 12 received QPSK Symbols
figure();
subplot(211);
stem(real(data(1:12)));
title('The real part of the data-vector');
axis([0 12 -1.5 1.5]);
set(gca,'ytick',[-1 1]);
xlabel('Symbol number');
ylabel('Value');
subplot(212);
stem(imag(data(1:12)));
title('The imaginary part of the data-vector');
axis([0 12 -1.5 1.5]);
set(gca,'ytick',[-1 1]);
xlabel('Symbol number');
ylabel('Value');
%Plot of the first 24 received bits and the soundOut
if strcmp(data_type, 'sound');
    figure();
    subplot(211)
    stem(DataOut(1:24));
    title('The DataOut-vector');
    axis([0 24 -0.5 1.5]);
    set(gca,'ytick',[0 1]);
    xlabel('Bit number');
    ylabel('Bit value');
    subplot(212)
    t = 0:1/Fs_sound:(length(wavData)-1)/Fs_sound;
    plot(t, wavData);
    title('The received wave-file')
    axis([0 0.35 -0.6 0.6]);
    xlabel('Time - Seconds')
    ylabel('Amplitude')
    else
    figure();
    stem(DataOut(1:24));
    title('The DataOut-vector');
    axis([0 24 -0.5 1.5]);
    set(gca,'ytick',[0 1]);
    xlabel('Bit number');
    ylabel('Bit value');
end