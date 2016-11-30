% This is the test_several file for Project1b 
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

diagnostics = 	false; 
plots = 		false;		
filepath = 		'/fig/'; 	% Filepath to figure folder


% ==== DEFINE SYSTEM CONSTANTS ====
SNR = 			15; 		% 1/sigma due to the fact that the magnitude in channel is 1
sigm = 			10^-(SNR/20);
f_s = 			16000;		% 16kHz Sample frequency
f_cm = 			4000;		% 4kHz modulation center frequency
N = 			64;			% 64 OFDM subcarriers, 64*2=128 bits
N_t = 			64;			% OFDM training package = 64 symbols
N_cp = 			32;		% Cyclic prefix length, unknown at the moment but maximal 32
R = 			8;			% Upsampling rate	
D = 			R;			% Downsampling rate, same as upsampling	
bw = 			f_s/R;		% Bandwidth of real valued signal (only real frequencies)

% ==== Define test constants ====
testcases = 10;
totalbits = testcases*N*2; 
biterrors = 0;
BER = [];
SNR = 5:0.5:30;

for i = 1:length(SNR)
	biterrors = 0;
	for j = 1:testcases
		% SNR(i)
		biterror_temp = main_function(SNR(i), f_s, f_cm, N, N_t, N_cp, R, diagnostics);
		biterrors = biterrors + biterror_temp;

	end
	temp = (biterrors/totalbits);
	BER = [BER, temp];

	disp(['SNR:', num2str(SNR(i)), ', BER: ', num2str(BER(i))])
end

plot(SNR,BER)



