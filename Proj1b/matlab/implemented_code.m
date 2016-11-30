% This is the main file for Project1b 
%
% List of functions that is reused from project1a
% 	- bits.m
%	- qpsk.m
%
% Author:
%	- Oscar Aspestrand
%	- Rickard Andersson
%	- Viktor Claesson
%	- Joel Åström
%
% 	date: 2016-11-22
clear all, clf, close all, clc, format compact

% ==== DEFINE SYSTEM CONSTANTS ====
SNR = 			90; 		% 1/sigma due to the fact that the magnitude in channel is 1
sigm = 			10^-(SNR/20); 
f_s = 			16000;		% 16kHz Sample frequency
f_cm = 			4000;		% 4kHz modulation center frequency
N = 			64;			% 64 OFDM subcarriers, 64*2=128 bits
N_t = 			64;			% OFDM training package = 64 symbols
N_cp = 			32;			% Cyclic prefix length, unknown at the moment but maximal 32
R = 			8;			% Upsampling rate	
D = 			R;			% Downsampling rate, same as upsampling	
bw = 			f_s/R;		% Bandwidth of real valued signal (only real frequencies)

%===================================
%======= 	TRANSMITTER 	========
%===================================
b = bits(2*N);		% Data
bt = bits(2*N_t);	% training data
s = qpsk(b);		% symbols
st = qpsk(bt);		% training symbols
symb = ifft(s);		% data
symbt = ifft(st);	% training
z_data = [symb(end-N_cp+1:end) symb];	% add cyclic prefix
zt = [symbt(end-N_cp+1:end) symbt];		% add cyclic prefix
z = [zt z_data];	% Package to be sent, N_cp+N_t+N_cp + N = 192
%===================================
%===================================
% z(n) 		->	Interpol.	-> z_i(n)
z_u = zeros(1,R*length(z));	% Make vector with zeros 
z_u(1:R:end) = z;	% Add values from z(n)

% Interpolation filter
B = firpm(63,[0 1/R 1.6/R 1],[1 1 0 0]);
z_i = conv(z_u,B);

% z_i(n) 	-> Modulation 	-> z_im(n)
n = (0:length(z_i)-1);
z_im = z_i.*exp(1i*2*pi*f_cm/f_s*n);
z_imr = real(z_im);
y_len = length(z_imr);

%===================================
%======= 	  CHANNEL 	 	========
%===================================
y_rec = simulate_audio_channel(z_imr,sigm)'; % Turn into row vector to fit our code

%===================================
%======= 	 RECEIVER 		========
%===================================
% Synchronization
E_avg = max(y_rec)^2*2*pi*sum(abs(y_rec))^2/(length(y_rec)^2);
ind = 1;
while true
	if abs(y_rec(ind)).^2 > E_avg
		break;
	end
	ind = ind + 1;
end
y_synch = y_rec(ind:ind+y_len-1);

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
H_hat = rt./st; 					% Estimate H_hat
H_hat = kron(H_hat, ones(1,N/N_t));	% expand estimated H_hat so that length matches
s_hat = conj(H_hat).*r;%./abs(H_hat).^2;
b_hat = qpsk(s_hat, -1);
%===================================