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

%
% !!!!NOTE!!!!
% We are doing everything in one file, in that way it is easier
% to check variables and stuff which otherwise won't be saved
% in workspace
% !!!!NOTE!!!!
%
clear all, clf, close all, clc, format compact


diagnostics = 	true; 
plots = 		true;		
filepath = 		'/fig/' 	% Filepath to figure folder


% ==== DEFINE SYSTEM CONSTANTS ====
sigm = 			0;			% Noise level, sigma
f_s = 			16000;		% 16kHz Sample frequency
f_cm = 			4000;		% 4kHz modulation center frequency
bw = 			f_s/8;		% Bandwidth of real valued signal (only real frequencies)
N = 			64;			% 64 OFDM subcarriers, 64*2=128 bits
N_t = 			64;			% OFDM training package = 64 symbols
N_cp = 			60;			% Cyclic prefix length, unknown at the moment but maximal 32
est_method =	'train';	% 'train', 'pilot', 'feedback', does nothing atm
							

%===================================
%======= 	TRANSMITTER 	========
%===================================

% bits is usually generated outside of the transmitter, hence
% data and training data will be generated here
% variables with 't' is training data
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
z = [zt z_data];	% Package to be sent


% z(n) 		->	Interpol.	-> z_i(n)



% z_i(n) 	-> Modulation 	-> z_imr(n)



%===================================
%======= 	  CHANNEL 	 	========
%===================================
% y_rec = simulate_audio_channel(z_mr,sigm)

% Test with old channel so that the old stuff works - This will be removed later on
h = channel(1);
w = (1/sqrt(2))*sigm*(randn(length(z)+length(h)-1,1) + 1i*randn(length(z)+length(h)-1,1))';
y = conv(z,h) + w;



%===================================
%======= 	 RECEIVER 		========
%===================================

% y_rec(n) 	-> Demodulation -> y_ib(n)



% y_ib(n) 	-> Decimation 	-> y(n)


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


if diagnostics 
	% Nödvändig info så som lengths osv
	BER = sum(b~=b_hat)/(2*N);
	disp(['BER: 	', num2str(BER)])
	% Signal power
	% Cyclic prefix length
	% Spectral efficiency
end

if plots
	% Plot estimated channel
	figure; plot(abs(H_hat))
	title('Estimated channel $|H(\omega)|$','Fontsize',15,'Interpreter','Latex')
	% Här lägger vi ALLA plots, så vill man inte vänta på plots 
	% som kan ta tid ibland så har man plots = false;
	
	% Plot signal spectrum through different parts of the system
end
