% This is a test file used to test implemented functions
clear all, clc, clf, close all, format compact

% Given constants
N = 128;
N_cp = 60; 
ch = 1;
time_delay = 0;
sigm = 0.01;


for sigma_case = 1:100
% sigma_case
sigm = 0+0.001*(sigma_case-1);
testcases = 100;
totalbits = testcases*N;
biterrors = 0;
snr_avg(sigma_case) = 0;

for i = 1:testcases



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
% SNRdb = 10*log10(SNR);

snr_avg(sigma_case) = snr_avg(sigma_case) + SNRdb;
biterrors = biterrors + sum(b ~= b_hat);
end


snr_avg(sigma_case) = 1/testcases*snr_avg(sigma_case);

Pb(sigma_case) = (biterrors/totalbits);




end

semilogy(snr_avg/2,Pb)
title('BER (Pb) vs SNR (db)','Fontsize',15,'Interpreter','latex')
xlabel('Eb/N0 (dB)','Fontsize',15,'Interpreter','latex')
% leg = legend('$i_{11}$','$i_{21}$','$i_0$','$v_0$');
% set(leg,'Fontsize',15,'Interpreter','latex')
grid on
print('fig/BERvSNR','-depsc')
