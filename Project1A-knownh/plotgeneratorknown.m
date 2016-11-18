function plotgeneratorknown(N, N_cp, ch, time_delay, sigm)
% This file is used to generate a massive amount of plots
clf, close all

% N = 128;
% N_cp = 60;
% ch = 1;
% time_delay = 0;
% sigm = [0 0.01 0.05];
% sigm = 0.05;



% =====================
% === Transmitter	===
% =====================
b = bits(N);
s = qpsk(b,N);
z = ofdm(s, N, N_cp);

% =====================
% === Channel 		===
% =====================
[h, H] = channel(ch,N);
y_len = length(z) + length(h) - 1;
wn = w(sigm,y_len);
y = conv(h,z)+wn;
y = lag(y,time_delay,sigm);

% =====================
% === Receiver 		===
% =====================
r = ofdm(y, N, N_cp, -1);
s_hat = equalization(r,H);
b_hat = qpsk(s_hat, N, H,-1);


disp(['Ncp: ',num2str(N_cp), ' ch: ', num2str(ch), ' td: ', num2str(time_delay), ' sigm: ', num2str(sigm)])

BER = sum(b ~= b_hat)*100 / N;
disp(['BER: 			', num2str(BER), '%'])

SNR = (1/(2*length(y)+1)*sum(abs(y).^2))/(1/(2*length(wn)+1)*sum(abs(wn).^2));
SNRdb = 10*log10(SNR);

disp(['SNR: 			', num2str(SNRdb), ' dB'])

f_eff = N*100/N;

disp(['frequency eff: 		', num2str(f_eff),'%'])
t_eff = N*100/y_len;
disp(['time Effeciency: 	', num2str(t_eff), '%'])


% % plots, added *100 to prevent '.' in the filename which removes the formating when saved
% figure; plot(s,'o'), title('Symbols s(k)','Fontsize',15,'Interpreter','Latex')
% xlabel('$Re$','Fontsize',15,'Interpreter','Latex')
% ylabel('$Im$','Fontsize',15,'Interpreter','Latex')
% filename = ['fig/s_ch_', num2str(ch),'_td_', num2str(time_delay), '_sigm_', num2str(sigm*100),'_BER_', num2str(int32(BER)) ,];
% print(filename,'-depsc')

% figure; plot(r,'o'), title('Received constellation before Eq. Symbols s(k)','Fontsize',15,'Interpreter','Latex')
% xlabel('$Re$','Fontsize',15,'Interpreter','Latex')
% ylabel('$Im$','Fontsize',15,'Interpreter','Latex')
% filename = ['fig/r_ch_', num2str(ch),'_td_', num2str(time_delay), '_sigm_', num2str(sigm*100),'_BER_', num2str(int32(BER)) ,];
% print(filename,'-depsc')

% figure; plot(s_hat,'o'), title('Estimated Symbols s(k)','Fontsize',15,'Interpreter','Latex')
% xlabel('$Re$','Fontsize',15,'Interpreter','Latex')
% ylabel('$Im$','Fontsize',15,'Interpreter','Latex')
% filename = ['fig/shat_ch_', num2str(ch),'_td_', num2str(time_delay), '_sigm_', num2str(sigm*100),'_BER_', num2str(int32(BER)) ,];
% print(filename,'-depsc')

% Closes all figures
close all


end