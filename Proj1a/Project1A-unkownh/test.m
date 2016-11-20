% This is a test file used to test implemented functions
clear all, clc, format compact
% clf, close all

%==============================================
%============== SYSTEM CONSTANTS ==============
%==============================================
N = 128;			% 128 subcarriers
N_cp = 60; 			% Cyclic prefix length
Nt = 128/(2^0);
ch = 1; 			% Choose between 1, 2
time_delay = 0;
sigm = 0.01;		% noise value: 0.01, 0.02, 0.05 (examples)

plots = 0;
%==============================================
%==============================================
%==============================================



testcases = 1;
totalbits = testcases*2*N;
biterror = 0;
snr_avg = 0;

for i = 1:testcases

% 1. Generate a bit sequence b(k), length 2N = 2*128.
b = bits(N);
bt = bits(Nt);

% 2. Encode the bit sequence b(k) into a QPSK sequence s(k)
s = qpsk(b,N);
st = qpsk(bt,Nt);

%3. Generate the OFDM sequence z(n) from s(k). Use N = 128 sub-carriers in the OFDM. Select a proper cyclic prefix length Ncp.
[z ~] = ofdm(s, N, N_cp);
[zt ~] = ofdm(st, Nt, N_cp);

z_frame = [zt z];
% 4. Use a channel description (h1(n) or h2(n)) with corresponding Hi(k)
[h, H] = channel(ch,N);

% Add cyclic prefix, this is done within ofdm
y_len = length(z_frame) + length(h) - 1;
yt = length(z_frame)+length(h)-1;

wn = w(sigm,y_len);

y = conv(h,z_frame)+wn;


y = lag(y, time_delay, sigm);

[r rt] = ofdm(y, N, N_cp, Nt, -1);


[s_hat H_Hat] = equalization(r,rt,st,N,Nt);
% title(['Nt:', num2str(Nt)])
b_hat = qpsk(s_hat,N, H,-1);




SNRdb=10*log10(4/(N*sigm)*sum(abs(s).^2));

snr_avg = snr_avg + SNRdb;

biterror = biterror + sum(b~=b_hat);


end

BER = biterror / totalbits
Chann_eff = N / (N+Nt+2*N_cp)*100
snr_avr = snr_avg / testcases/2


% % Plot S, S^
% figure;
% plot(s,'x'), hold on
% plot(s_hat,'o')
% legend('symbols s(n)','estimated symbols shat(n)')
% % title('Perfect synch. no noise: Symbols')
% xlabel('$Re$','Fontsize',15,'Interpreter','Latex')
% ylabel('$Im$','Fontsize',15,'Interpreter','Latex')

% plot Hhat
figure;
plot(abs(H)), hold on, plot(abs(H_Hat))
xlabel('Subcarrier (k)','Fontsize',15,'Interpreter','Latex')
ylabel('|H(k)|','Fontsize',15,'Interpreter','Latex')
legend('H','estimated H')


% print('fig/est_h_noise_ch1_train','-depsc')

% BER = sum(b ~= b_hat)/(2*N)

% SNRdb=10*log10(4/(N*sigm)*sum(abs(s).^2))




	

