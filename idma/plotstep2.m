function[]=plotstep2(ttotal,f,sn,FS,sn_delay,impulseresponse,timpulse,impresp,s_conv,t_conv,theta)
%Plots
%Plot of the frequency error
figure()
plot(ttotal, theta(1:length(ttotal)))
title(['Phase error as a function of time']);
axis([0 5.2 0 10]);
set(gca,'ytick',[0 3.1415 6.2831], 'YTickLabel',{'0 ','pi ','2pi '});
xlabel('Time - Seconds');
ylabel('Phase error');
%Plot of the frequency spectrum of the received signal
figure();
subplot(211);
plot(f/1000, abs(fft(sn, FS))/FS);
title(['Spectrum of the received signal']);
axis([35 41 0 3]);
xlabel('Frequency - kHz');
ylabel('Amplitude');
subplot(212);
pwelch(sn,[],[],[],FS);
axis([35 41 -50 20]);
%Plot of the transmitted signal
figure();
subplot(211)
plot(ttotal, sn_delay);
title(['The transmitted signal']);
axis([0 5.2 -600 600]);
xlabel('Time - Seconds');
ylabel('Amplitude');
subplot(212)
plot(ttotal, sn_delay);
axis([1.748 1.76 -400 400]);
xlabel('Time - Seconds');
ylabel('Amplitude');
if impulseresponse == 1
%Plot of the impulseresponse of the channel
figure()
stem(timpulse, impresp);
title(['Channel impulse response']);
xlabel('Time - Seconds');
ylabel('Amplitude');
%Plot of the received signal
figure()
subplot(211)
plot(ttotal, s);
title(['The transmitted signal']);
axis([2.18 2.21 -200 200]);
xlabel('Time - Seconds');
ylabel('Amplitude');
subplot(212)
plot(t_conv, s_conv)
title(['The received signal']);
axis([2.18 2.21 -200 200]);
xlabel('Time - Seconds');
ylabel('Amplitude');
end
end