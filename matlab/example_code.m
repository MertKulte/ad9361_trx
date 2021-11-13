clear all;
%close all;

ip_addr = '192.168.1.35';

conn_status = test_connection(ip_addr);
if(strcmp(conn_status, 'CONN_OK') ~= 1)
    disp('Connection not established.')
    return;
end

% Select one of the pre-defined profiles.
% Profile 1 => 61.44 MHz sampling rate, 50   MHz bandwidth.
% Profile 2 => 30.72 MHz sampling rate, 25   MHz bandwidth.
% Profile 3 => 15.36 MHz sampling rate, 12.5 MHz bandwidth.
% Profile 4 =>  7.68 MHz sampling rate, 6.25 MHz bandwidth.
set_profile(ip_addr, 4);

% Read the current LO frequency.
current_lo_freq = get_lo_freq(ip_addr);
% Change the LO frequency.
lo_freq_set = set_lo_freq(ip_addr, 2400000000);

% Set gain mode of channel 1 to auto and channel 2 to manual.
set_gain_mode(ip_addr, 1, 1);
set_gain_mode(ip_addr, 2, 2);
% Set channel 2 gain to 35 dB and read channel 1 gain.
gain_value_set = set_gain_value(ip_addr, 2, 35);
disp(['Ch2 gain is set to ' num2str(gain_value_set)]);
gain_value = get_gain_value(ip_addr, 1);
disp(['Ch1 gain is ' num2str(gain_value)]);

% Generate I Q waveform and load into TX1.
% Total data points.
points = 1000;
% fs/4 frequency offset from carrier.
phaseInc = 2*pi*(1/10);
phase = phaseInc * (0:points-1);
% Create an IQ waveform
Iwave = cos(phase);
Qwave = sin(phase);
IQData = [Iwave' Qwave'];
IQData = floor(IQData'*2^10);
plot(mag2db(abs(fftshift(fft(complex(IQData(1,:),IQData(2,:)))))))
% Load data into TX1 channel.
set_tx_data(ip_addr, 2, IQData);
% Enable TX1 and disable TX2.
en_dis_tx_ch(ip_addr, 1, 0);
en_dis_tx_ch(ip_addr, 2, 1);

% Receive time domain data
[ch1_data_td, ch2_data_td] = get_td_data(ip_addr, 10000);
figure(1);
plot(real(ch1_data_td));
hold on;
plot(imag(ch1_data_td));
hold off;
figure(2);
plot(real(ch2_data_td));
hold on;
plot(imag(ch2_data_td));
hold off;

% Receive frequency domain data
[ch1_data_fd, ch2_data_fd] = get_fd_data(ip_addr, 4096);
figure(3);
plot(fftshift(real(ch1_data_fd)));
hold on;
plot(fftshift(imag(ch1_data_fd)));
hold off;
figure(4);
plot(fftshift(real(ch2_data_fd)));
hold on;
plot(fftshift(imag(ch2_data_fd)));
hold off;

figure(5)
plot(mag2db(fftshift(abs(ch1_data_fd))));
figure(6)
plot(mag2db(fftshift(abs(ch2_data_fd))));