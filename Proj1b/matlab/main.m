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
plots = 		false;		
filepath = 		'/fig/'; 	% Filepath to figure folder


% ==== DEFINE SYSTEM CONSTANTS ====
sigm = 			0.2;			% Noise level, sigma
f_s = 			16000;		% 16kHz Sample frequency
w_s = 			2*pi*f_s;	% Sample frequency rad/s
f_cm = 			4000;		% 4kHz modulation center frequency
bw = 			f_s/8;		% Bandwidth of real valued signal (only real frequencies)
N = 			64;			% 64 OFDM subcarriers, 64*2=128 bits
N_t = 			64;			% OFDM training package = 64 symbols
N_cp = 			 32;			% Cyclic prefix length, unknown at the moment but maximal 32
R = 			8;			% Upsampling rate	
D = 			8;			% Downsampling rate, same as upsampling	


NN = 2^14; % Number of frequency grid points
f = (0:NN-1)/NN;

%===================================
%======= 	TRANSMITTER 	========
%===================================

%===================================
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
B = firpm(63,[0 1/R 1/R*1.6 1],[1 1 0 0]);
z_i = conv(z_u,B);


% figure;
% plot([real(z_i) imag(z_i)])

% z_i(n) 	-> Modulation 	-> z_imr(n)
n = (0:length(z_i)-1);
z_imr = z_i.*exp(1i*2*pi*f_cm/f_s*n);


z_mr = real(z_imr);

% y length 
% y_len = R*(2*N_cp+N_t+N)+length(B)-1;
y_len = length(z_mr);
%===================================
%======= 	  CHANNEL 	 	========
%===================================
y_rec = simulate_audio_channel(z_mr,sigm).'; % Turn into row vector to fit our code


%===================================
%======= 	 RECEIVER 		========
%===================================


% Synchronization

E_avg = max(y_rec).^2*sum(abs(y_rec).^2)/length(y_rec)
E_avg = max(y_rec).^2*(sum(abs(y_rec))/(2*length(y_rec))).^2*2*pi

E_avg = 2*pi*sum(abs(y_rec(1:100)).^2)/100
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
%===================================

if diagnostics 
	% System information
	BER = sum(b~=b_hat)/(2*N);
	disp(['BER: 			', num2str(BER*1e3),'e-3'])
	
	% Signal power
	signal_power = sum(abs(z_mr).^2);
	disp(['Signal power: 		', num2str(signal_power)])
	
	% Cyclic prefix length
	disp(['Cyclic prefix length: 	', num2str(N_cp)])
	% Spectral efficiency

	symb_eff = N / (2*N_cp+N_t+N); % Amount of data symbols compared to all symbols sent.
	disp(['Symbol efficiency 	', num2str(symb_eff*100),'%'])

end

if plots
	% Plot estimated channel
	figure; plot(abs(H_hat))
	title('Estimated channel $|H(\omega)|$','Fontsize',15,'Interpreter','Latex')
	% Här lägger vi ALLA plots, så vill man inte vänta på plots 
	% som kan ta tid ibland så har man plots = false;
	
	figure;
	plot(abs(fft(y))), hold on
	plot(abs(fft(z)))
	legend('show')

	% Plot signal spectrum through different parts of the system


	figure;
	semilogy(f,abs(fft(z,NN))) % Check transform
	xlabel('relative frequency f/fs');
	figure;
	semilogy(f,abs(fft(z_u,NN))) % Check transform
	xlabel('normalized frequency f/fs');

	figure;
	semilogy(f,abs([fft(z_u,NN); fft(z_i,NN); fft(B,NN)])) % Check transforms
	legend('Up-sampled z_u','Interpolated after LP filtering','LP-filter')
	xlabel('relative frequency f/fs');
end
