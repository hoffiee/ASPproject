% This is a test file used to test implemented functions
clear all, clc, format compact
% clf, close all

%==============================================
%============== SYSTEM CONSTANTS ==============
%==============================================
N = 128;			% 128 subcarriers
N_cp = 100; 			% Cyclic prefix length
ch = 2; 			% Choose between 1, 2
nrPilots = 128/(2^1);		% Amount of pilots
time_delay = 0;
sigm = 0;		% noise value: 0.01, 0.02, 0.05 (examples)
diagnotics = 1;
plots = 0;
%==============================================
%==============================================
%==============================================


testcases = 100;

totalbits = testcases*N
biterrors = 0;
for i = 1:testcases




% 1. Generate a bit sequence b(k), length 2N = 2*128.
b = bits(N);
b_pilots = bits(nrPilots);

% 2. Encode the bit sequence b(k) into a QPSK sequence s(k)
s = qpsk(b,N);
pilots = qpsk(b_pilots,nrPilots);
% Add pilots to datapackage at even indices
count = 1;
step_size = N/nrPilots;
for i = step_size/2:step_size:N
	s(i) = pilots(count);
	count = count + 1;
end


%3. Generate the OFDM sequence z(n) from s(k). Use N = 128 sub-carriers in the OFDM. Select a proper cyclic prefix length Ncp.
z = ofdm(s, N, N_cp);
% 4. Use a channel description (h1(n) or h2(n)) with corresponding Hi(k)
[h, H] = channel(ch,N);

% Add cyclic prefix, this is done within ofdm
y_len = length(z) + length(h) - 1;

wn = w(sigm,y_len);

y = conv(h,z)+wn;


y = lag(y,time_delay, sigm);
plot(abs(y))

r = ofdm(y, N, N_cp, -1);


[s_hat H_hat] = equalization(r, pilots);
% figure(1); hold on, plot(abs(H))
% plot(abs(H_hat))
b_hat = qpsk(s_hat,N, H,-1);


if diagnotics
	disp('=======================================')
	disp(['=== Unknown H, channel: ', num2str(ch), '           ==='])
	disp(['=== Channel: ', num2str(ch), ', Ncp: ', num2str(N_cp), ' Sigma: ', num2str(sigm), '  ==='])
	disp('=======================================')

	count=0;

	% BER = count/(N-nrPilots)*100;
	% BER = sum(b ~= b_hat)/N*100
	BER = abs( (sum(b ~= b_hat)/N) - (nrPilots)/N)*100
	disp(['Expected BER: ', ])
	disp(['carrier eff:', num2str((N-nrPilots)/N*100)])
	disp(['BER: ', num2str(BER), '%, nr pilots:', num2str(nrPilots)])
	disp(['Number of bits b: 		', num2str(length(b))])
	disp(['Number of symbols, s: 		', num2str(length(s))])
	disp(['number of samples z: 		', num2str(length(z))])
	disp(['Calculated Length of y: 	', num2str(y_len)])
	disp(['Real length of y: 		', num2str(length(y))])
	disp(['Number of est. symbols, s_hat: 	', num2str(length(s_hat))])
	disp(['Number of est. bits, b_hat: 	', num2str(length(b_hat))])

	SNR=10*log10(4/(N*sigm)*sum(abs(s).^2));
SNRdb = 10*log10(SNR)


biterrors = biterrors + sum(b ~= b_hat);
end
end

BER = abs( (biterrors/totalbits) - (nrPilots)/N)

if plots 
	%=====================================
	%=====   Display system plots    =====
	%=====================================
	figure; stem(b)
	title('Bitstream')

	figure; plot(s)
	title('Symbols')

	figure; plot(real(z)), hold on, plot(imag(z))
	legend('real(z)','imag(z)'), title('OFDM z')

	figure; plot(h), title('Channel h')
	figure; plot(abs(H)), title('Channel H')

end
