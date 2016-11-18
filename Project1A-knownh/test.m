% This is a test file used to test implemented functions
clear all, clc, clf, close all, format compact

% Given constants
N = 128;
N_cp = 70; 
ch = 1;
time_delay = 0;
sigm = 0;

testcases = 100;
totalbits = testcases*N;
biterror = 0;
snr_avg = 0;

for i = 1:testcases;
% 1. Generate a bit sequence b(k), length 2N = 2*128.
b = bits(N);

% 2. Encode the bit sequence b(k) into a QPSK sequence s(k)
s = qpsk(b,N);

%3. Generate the OFDM sequence z(n) from s(k). Use N = 128 sub-carriers in the OFDM. Select a proper cyclic prefix length Ncp.
z = ofdm(s, N, N_cp);

% 4. Use a channel description (h1(n) or h2(n)) with corresponding Hi(k)
[h, H] = channel(ch,N);

% Add cyclic prefix, this is done within ofdm
y_len = length(z) + length(h) - 1;

y = conv(h,z)+w(sigm,y_len);
% plot(abs(y)), hold on
y = lag(y,time_delay,sigm);
% plot(abs(y))

r = ofdm(y, N, N_cp, -1);

s_hat = equalization(r,H);

b_hat = qpsk(s_hat, N, H,-1);



SNRdb=10*log10(4/(N*sigm)*sum(abs(s).^2));

snr_avg = snr_avg + SNRdb;

biterror = biterror + sum(b(b~=b_hat));
end

% Pb
BER = biterror / totalbits
Chann_eff = (N-N_cp) / (N+N_cp)*100






%=====================================
%=====   Display system plots    =====
%=====================================
% figure; stem(b)
% title('Bitstream')

% figure; plot(s)
% title('Symbols')

% figure; plot(real(z)), hold on, plot(imag(z))
% legend('real(z)','imag(z)'), title('OFDM z')

% figure; plot(h), title('Channel h')
% figure; plot(abs(H)), title('Channel H')