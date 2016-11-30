% This is the main file for Project1b 
%
% List of functions that is reused from project1a
% 	- bits.m
%	- qpsk.m
%	- simulate_audio_channel.m
%
% Author:
%	- Oscar Aspestrand
%	- Rickard Andersson
%	- Viktor Claesson
%	- Joel Åström
%
% 	date: 2016-11-22
clear all, clf, close all, clc, format compact


diagnostics = 	true; 
plots = 		true;		

% ==== DEFINE SYSTEM CONSTANTS ====
% sigm = 			0.2;		% Noise level, sigma
SNR = 			60; 		% 1/sigma due to the fact that the magnitude in channel is 1
sigm = 			10^-(SNR/20);
% sigm = 			0.01;
f_s = 			16000;		% 16kHz Sample frequency
% w_s = 			2*pi*f_s;	% Sample frequency rad/s
f_cm = 			4000;		% 4kHz modulation center frequency
N = 			64;			% 64 OFDM subcarriers, 64*2=128 bits
N_t = 			64;			% OFDM training package = 64 symbols
N_cp = 			32;		% Cyclic prefix length, unknown at the moment but maximal 32
R = 			8;			% Upsampling rate	
D = 			R;			% Downsampling rate, same as upsampling	
bw = 			f_s/R;		% Bandwidth of real valued signal (only real frequencies)


%===================================
%======= 	TRANSMITTER 	========
%===================================
b = bits(2*N);		% Data
bt = bits(2*N_t);	% training data
% b(k) 		-> QPSK 		-> s(k)
s = qpsk(b);		% symbols
st = qpsk(bt);		% training symbols
% s(k) 		-> OFDM 		-> z(n)
symb = ifft(s);		% data
symbt = ifft(st);	% training
z_data = [symb(end-N_cp+1:end) symb];	% add cyclic prefix
zt = [symbt(end-N_cp+1:end) symbt];		% add cyclic prefix
z = [zt z_data];	% Package to be sent, N_cp+N_t+N_cp + N = 192
%===================================
%===================================

% z(n) 		->	Interpol.	-> z_i(n) ##NOTE: also known as upsampling l= R*192 = 1536
z_u = zeros(1,R*length(z));	% Make vector with zeros 
z_u(1:R:end) = z;	% Add values from z(n)

% Interpolation filter
B = firpm(255,[0 1/R 1.1/R 1],[1 1 0 0]);
z_i = conv(z_u,B);

% figure;
% plot([real(z_i) imag(z_i)])

% z_i(n) 	-> Modulation 	-> z_im(n)
n = (0:length(z_i)-1);
z_im = z_i.*exp(1i*2*pi*f_cm/f_s*n);


z_imr = real(z_im);

% y length 
% y_len = R*(2*N_cp+N_t+N)+length(B)-1;
y_len = length(z_imr);
%===================================
%======= 	  CHANNEL 	 	========
%===================================
y_rec = simulate_audio_channel(z_imr,sigm)'; % Turn into row vector to fit our code


%===================================
%======= 	 RECEIVER 		========
%===================================
% Synchronization
E_avg = max(y_rec).^2*sum(abs(y_rec).^2)/length(y_rec)
% E_avg = max(y_rec).^2*(sum(abs(y_rec))/(2*length(y_rec))).^2*2*pi
% E_avg = 2*pi*sum(abs(y_rec(1:100)).^2)/100
ind = 1;
while true

	if abs(y_rec(ind)).^2 > E_avg

		break;
	end
	ind = ind + 1;
end
y_synch = y_rec(ind+N_cp:ind+N_cp+y_len-1);

% y_rec(n) 	-> Demodulation -> y_ib(n)
y_ib = y_synch.*exp(-1i*2*pi*f_cm/f_s*n);

% y_ib(n) 	-> Decimation 	-> y(n)
y_i = conv(y_ib,B);		% Filter
y = y_i(1:D:end);


%===================================
% y(n) 		-> OFDM-1 		-> r(k)
yt = y(N_cp+1:N_cp+N_t); 				% get training symbols
y_data = y(N_cp+N_t+N_cp+1:N_cp+N_t+N_cp+N);	% get data
rt = fft(yt);
r = fft(y_data);

% r(k) 		-> EQ 			-> s_hat(k)
H_hat = rt./st; 					% Estimate H_hat
H_hat = kron(H_hat, ones(1,N/N_t));	% expand estimated H_hat so that length matches
s_hat = conj(H_hat).*r;%./abs(H_hat).^2;

% s_hat(k) 	-> QPSK-1 		-> b_hat(k)
b_hat = qpsk(s_hat, -1);
%===================================

if diagnostics 
	% System information
	BER = sum(b~=b_hat)/(2*N);
	disp(['BER: 			', num2str(BER*1e3),'e-3'])
	
	disp(['SNR: 	', num2str(SNR), ' sigma: 	', num2str(sigm)])

	% Signal power
	signal_power = sum(abs(z_imr).^2);
	disp(['Signal power: 		', num2str(signal_power)])
	
	% Cyclic prefix length
	disp(['Cyclic prefix length: 	', num2str(N_cp), ' Samples'])

	% Spectral efficiency
	% 				Bits / 	  		s        /     Hz
	% spectral_eff = 	 N   / ((2*N_cp+N+N_t)*(1/f_s) *  (bw ));
	% Total Tx time
	Ts = y_len / f_s;
	% Symbol rate Rs
	Rs = N / Ts;
	% Bitrate Rb bits/s
	Rb = Rs * 2;

	% Spectral efficiency bits/s/Hz
	spectral_eff = Rb / bw;


	disp(['Bitrate Rb: 	', num2str(Rb)])
	disp(['Spectral efficiency: 	', num2str(spectral_eff),' Bits/s/Hz'])

	symb_eff = N / (2*N_cp+N_t+N); % Amount of data symbols compared to all symbols sent.
	disp(['Symbol efficiency 	', num2str(symb_eff*100),'%'])

end

if plots

	% Define Plotting properties
	title_fontsize = 	15;
	axis_fontsize = 	12;
	legend_fontsize = 	10;
	path_to_fig = 		'fig/'; 	% Filepath to figure folder
	NN = 				2^14;		% Number of frequency grid points
	f = 				(0:NN-1)/NN;
	F = 				(0:NN-1)/NN*f_s;


	% Plot estimated channel
	% figure; plot(abs(H_hat))
	% title('Estimated channel $|H(\omega)|$','Fontsize',title_fontsize,'Interpreter','latex')
	% xlabel('Subcarrier (k)','Fontsize',axis_fontsize,'Interpreter','latex')
	% ylabel('$|H(k)|$','Fontsize',axis_fontsize,'Interpreter','latex')
	%print([path_to_fig 'channel_est'],'-depsc') % Nöjd med den vi har nu, så sparar inte ut fler kanal estimationer
	% Här lägger vi ALLA plots, så vill man inte vänta på plots 
	% som kan ta tid ibland så har man plots = false;


	% Magnitude of filter 1

	% figure;
	% semilogy(F,abs([fft(z_i,NN); fft(z_im,NN); fft(z_imr,NN)])) % Check transforms
	% legend('Interpolated','Modulated','real and modulated')
	% xlabel('Frequency (Hz)');


	% Frequency spectrum
	figure('units','normalized','outerposition',[0 0 1 1])
	subplot(2,2,1); semilogy(f,[abs(fft(z_u,NN))]), hold on, grid on
	semilogy(f(1:end/R),abs(fft(z,NN/R)))
	title('Tx','Fontsize',title_fontsize,'Interpreter','Latex')
	xlabel('Normalized frequency','Fontsize',axis_fontsize,'Interpreter','latex')
	ylabel('Magnitude','Fontsize',axis_fontsize,'Interpreter','latex')
	leg = legend('Upsampled $z(n)$','$z(n)$');
	set(leg,'Fontsize',legend_fontsize,'Interpreter','latex')
	subplot(2,2,2); semilogy(f,[abs(fft(z_i,NN)); abs(fft(z_im,NN)); abs(fft(z_imr,NN))]), grid on
	title('Tx','Fontsize',title_fontsize,'Interpreter','Latex')
	xlabel('Normalized frequency','Fontsize',axis_fontsize,'Interpreter','latex')
	ylabel('Magnitude','Fontsize',axis_fontsize,'Interpreter','latex')
	leg = legend('Interpolated $z(n)$','modulated $z(n)$','real and modulated signal');
	axis([0 1 1e-6 1e2])


% y_synch = y_rec(ind+N_cp:ind+N_cp+y_len-1);

% % y_rec(n) 	-> Demodulation -> y_ib(n)
% y_ib = y_synch.*exp(-1i*2*pi*f_cm/f_s*n);

% % y_ib(n) 	-> Decimation 	-> y(n)
% y_i = conv(y_ib,B);		% Filter
% y = y_i(1:D:end);


	subplot(2,2,3); semilogy(f,[abs(fft(y_synch,NN)); abs(fft(y_ib,NN))]), grid on
	title('Rx','Fontsize',title_fontsize,'Interpreter','Latex')
	xlabel('Normalized frequency','Fontsize',axis_fontsize,'Interpreter','latex')
	ylabel('Magnitude','Fontsize',axis_fontsize,'Interpreter','latex')
	leg = legend('Frame synched $y(n)$','demodulated $y(n)$');
	set(leg,'Fontsize',legend_fontsize,'Interpreter','latex')

	subplot(2,2,4); semilogy(f,abs(fft(y_i,NN))), hold on, grid on
	semilogy(f(1:end/R),abs(fft(y,NN/R)))
	title('Rx','Fontsize',title_fontsize,'Interpreter','Latex')
	xlabel('Normalized frequency','Fontsize',axis_fontsize,'Interpreter','latex')
	ylabel('Magnitude','Fontsize',axis_fontsize,'Interpreter','latex')
	leg = legend('LP-filtered $y(n)$','Downsampled $y(n)$');
	set(leg,'Fontsize',legend_fontsize,'Interpreter','latex')
	axis([0 1 1e-5 1e3])

	print([path_to_fig 'freq_spec'],'-depsc')
	
	
	% figure;
	% semilogy(f, abs(fft(y_synch,NN)))
	% title('Synch')
	% % figure;
	% % semilogy(f, abs(fft(y_ib,NN)))
	% % title('Demodulation')
	% figure;
	% semilogy(f, abs(fft(y_i,NN))), hold on
	% semilogy(f, abs(fft(y_ib,NN)))
	% semilogy(f(1:end/R), abs(fft(y,NN/R)))
	% legend('LP-filter','Demodulated','Downsampled')
	



	% Plot signal spectrum through different parts of the system
	% figure;
	% title('f abs(fft(z,NN))')
	% semilogy(f,abs(fft(z,NN))) % Check transform
	% xlabel('relative frequency f/fs');


	% figure;
	% semilogy(f,abs(fft(z,NN))) % Check transform
	% title('Transform before interpol','Fontsize',title_fontsize,'Interpreter','Latex')
	% xlabel('relative frequency f/fs');
	% figure;
	% semilogy(f,abs(fft(z_u,NN))) % Check transform
	% xlabel('normalized frequency f/fs');

	% figure;
	% semilogy(f,abs([fft(z,NN); fft(z_u,NN); fft(z_i,NN); fft(B,NN); fft(z_im,NN)])) % Check transforms
	% % title('','Fontsize',title_fontsize,'Interpreter','Latex')
	% legend('u','Up-sampled z_u','Interpolated after LP filtering','LP-filter','Modulated z_im')
	% xlabel('relative frequency f/fs');
end
