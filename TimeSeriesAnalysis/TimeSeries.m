%Justin Haupt
%Computer Applications
%Time Series Analysis - Clackamas River

clear; clc; close all
load('data.mat')

t = 1:3625;

%plotting the discharge data
figure
subplot(1,2,1); plot(t,OCdis); title('Oregon City Discharge')
xlabel('Days'); ylabel('Cubic feet per second')
subplot(1,2,2); plot(t,Edis); title('Estacada Discharge')
xlabel('Days'); ylabel('Cubic feet per second')

%plotting the temperature data
figure
subplot(1,2,1); plot(t,OCtemp); title('Oregon City Temperature')
xlabel('Days'); ylabel('Celcius(C{\circ})')
subplot(1,2,2); plot(t,Etemp); title('Estacada Temperature')
xlabel('Days'); ylabel('Celcius(C{\circ})')


%% Fourier Transform

fftsize = 2^nextpow2(length(t));
ffthalf = fftsize/2;

%fast Fourier transforms
Fd1 = fft(OCdis,fftsize);  
Fd2 = fft(OCtemp,fftsize);
Fd3 = fft(Edis,fftsize);
Fd4 = fft(Etemp,fftsize);


%% Power Spectrum

del = 1;              %the sampling interval
Nyfreq = 1/(2*del);   %the Nyquist frequency

%constructs vector of positive first half of fft frequencies-
%has units of Nyquist frequencies
f = Nyfreq*(0:ffthalf)/(ffthalf);

Pd1 = Fd1 .* conj(Fd1)/(fftsize^2);
Pd2 = Fd2 .* conj(Fd2)/(fftsize^2);
Pd3 = Fd3 .* conj(Fd3)/(fftsize^2);  
Pd4 = Fd4 .* conj(Fd4)/(fftsize^2);  

%PS for discharges
figure
subplot(1,2,1); plot(f,Pd1(1:ffthalf+1));
subplot(1,2,2); plot(f,Pd3(1:ffthalf+1))

%PS for temperatures
figure
subplot(1,2,1); plot(f,Pd2(1:ffthalf+1))
subplot(1,2,2); plot(f,Pd4(1:ffthalf+1))


%% Detrended Power Spectrum

dt1 = detrend(OCdis);
dt2 = detrend(OCtemp);
dt3 = detrend(Edis);
dt4 = detrend(Etemp);

%the FFT
Fdt1 = fft(dt1,fftsize);
Fdt2 = fft(dt2,fftsize);
Fdt3 = fft(dt3,fftsize);
Fdt4 = fft(dt4,fftsize);

%the power spectrum
Pdt1 = Fdt1 .* conj(Fdt1)/(fftsize^2);
Pdt2 = Fdt2 .* conj(Fdt2)/(fftsize^2);
Pdt3 = Fdt3 .* conj(Fdt3)/(fftsize^2);
Pdt4 = Fdt4 .* conj(Fdt4)/(fftsize^2);

%detrended PS for discharges
figure
subplot(1,2,1); plot(f,Pdt1(1:ffthalf+1))
title('Oregon City'); xlabel('Nyquist Frequencies')
subplot(1,2,2); plot(f,Pdt3(1:ffthalf+1))
title('Estacada'); xlabel('Nyquist Frequencies')

%detrended PS for temperatures
figure
subplot(1,2,1); plot(f,Pdt2(1:ffthalf+1))
title('Oregon City'); xlabel('Nyquist Frequencies')
subplot(1,2,2); plot(f,Pdt4(1:ffthalf+1))
title('Estacada'); xlabel('Nyquist Frequencies')


%% Correlation of the data

%overlaps the two data sets for discharge and temperature
figure
subplot(1,2,1); plot(t,OCdis); hold on; plot(t,Edis,'r');
title('Discharge Data'); xlabel('Days'); ylabel('Cubic feet per second')
legend('Oregon City','Estacada')
subplot(1,2,2); plot(t,OCtemp); hold on; plot(t,Etemp,'r'); 
title('Temperature Data'); xlabel('Days'); ylabel('Celcius(C{\circ})')
legend('Oregon City','Estacada')

%Correlate two data sets by multiplying the first fft to the complex
%conjugate of the second, then take the invers fft
len = length(t);

%correlation via fft analysis
nfft = 2^nextpow2(2*len-1);

cor_dis = ifft(fft(OCdis,nfft) .* conj(fft(Edis,nfft)));
cor_temp = ifft(fft(OCtemp,nfft) .* conj(fft(Etemp,nfft)));

t = -(len-1):+(len-1);  %rearange the time values according to lags

%rearrange the correlation values according to lags
cor_dis = [cor_dis(end-len+2:end);  cor_dis(1:len)];
cor_temp = [cor_temp(end-len+2:end);  cor_temp(1:len)];

figure
plot(t,cor_dis); title('River Discharge Correlation')
xlabel('Lag (days)'); ylabel('Correlation')

figure
plot(t,cor_temp,'r'); title('River Temperature Correlation')
xlabel('Lag (days)'); ylabel('Correlation')




