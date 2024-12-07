clc;
close all;

recObj = audiorecorder;
recDuration = 5;
disp("Begin speaking.")
recordblocking(recObj,recDuration);
disp("End of recording.")
y = getaudiodata(recObj);

sound(y);
pause(10);
figure,plot(y);
title('input');
xlabel('time');
ylabel('amplitude');

y = awgn(y,40);
noi = y;
figure;
plot(y);
title('awgn');
figure;
plot(abs(fft(y)));
xlabel('frequency');
ylabel('amplitude');
title('awgn');
disp('playing added noise...');
sound(y);
pause(10)

 

%'Fp,Fst,Ap,Ast' (passband frequency, stopband frequency, passband ripple, stopband attenuation)
hlpf = fdesign.lowpass('Fp,Fst,Ap,Ast');
D = design(hlpf);
freqz(D);
x = filter(D,y);
disp('playing denoised sound');
figure;
plot(x);
title('denoise');
xlabel('time');
ylabel('amplitude');

sound(x);
figure;
plot(abs(fft(x)));
xlabel('frequency');
ylabel('amplitude');
title('denoise');

pause(10);

m= input('Enter the amount of loss in hearing in db: ');
gainRequired=db2mag(m);
amplifiedSignal=y*gainRequired;
soundsc(amplifiedSignal);
figure;
plot(amplifiedSignal);
title('Amplified signal');
pause(5);


% freq shaper using band pass
len = length(x);
p = log2(len);
q = ceil(p);
N = 2^q;
f1 = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2');
hd = design(f1,'equiripple');
y = filter(hd,x);
freqz(hd);
disp('playing frequency shaped...');
sound(y);

pause(10);

% amplitude shaper 
disp('amplitude shaper')
out1=fft(y);
phase=angle(out1);
mag=abs(out1)/N;
[magsig,~]=size(mag);
threshold=1000;
out=zeros(magsig,1);

for i=1:magsig/2
   if(mag(i)>threshold)
       mag(i)=threshold;mag(magsig-i)=threshold;
   end
   out(i)=mag(i)*exp(1i*phase(i));
   out(magsig-i)=out(i);
end
outfinal=real(ifft(out))*10000;
disp('playing amplitude shaped...');
sound(outfinal);

pause(10);

figure;
subplot(2,1,1);
specgram(noi);
title('Spectrogram of Original Signal');

subplot(2,1,2);
specgram(outfinal);
title('Spectrogram of Adjusted Signal');
