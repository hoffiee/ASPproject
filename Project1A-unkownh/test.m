% This is a test file used to test implemented functions
clear all, clc, format compact
% clf, close all

%==============================================
%============== SYSTEM CONSTANTS ==============
%==============================================
N = 128;			% 128 subcarriers
N_cp = 10; 			% Cyclic prefix length
Nt = 128/(2^0);
ch = 2; 			% Choose between 1, 2
nrPilots = 64;		% Amount of pilots
sigm = 0.05;		% noise value: 0.01, 0.02, 0.05 (examples)
diagnotics = 1;
plots = 0;
%==============================================
%==============================================
%==============================================


% 1. Generate a bit sequence b(k), length 2N = 2*128.
b = bits(N);
bt = bits(Nt);

% 2. Encode the bit sequence b(k) into a QPSK sequence s(k)
s = qpsk(b,N);
st = qpsk(bt,Nt);

%3. Generate the OFDM sequence z(n) from s(k). Use N = 128 sub-carriers in the OFDM. Select a proper cyclic prefix length Ncp.
z = ofdm(s, N, N_cp);
zt = ofdm(st, Nt, N_cp);
% 4. Use a channel description (h1(n) or h2(n)) with corresponding Hi(k)
[h, H] = channel(ch,N);

% Add cyclic prefix, this is done within ofdm
y_len = length(z) + length(h) - 1;
yt = length(zt)+length(h)-1;

wn = w(sigm,y_len);
wt = w(sigm,yt);

y = conv(h,z)+wn;
yt = conv(h,zt)+wt;



r = ofdm(y, N, N_cp, -1);
rt = ofdm(yt, Nt, N_cp, -1);

[s_hat H_Hat] = equalization(r,rt,st);
% title(['Nt:', num2str(Nt)])
b_hat = qpsk(s_hat,N, H,-1);



if diagnotics
	disp('=======================================')
	disp(['=== Unknown H, channel: ', num2str(ch), '           ==='])
	disp(['=== Channel: ', num2str(ch), ', Ncp: ', num2str(N_cp), ' Sigma: ', num2str(sigm), '  ==='])
	disp('=======================================')
	% SER = sum(s ~= s_hat)/length(s)*100;
	BER = sum(b ~= b_hat)/length(b)*100;
	disp(['BER: ', num2str(BER), '%'])
	disp(['Number of bits b: 		', num2str(length(b))])
	disp(['Number of symbols, s: 		', num2str(length(s))])
	disp(['number of samples z: 		', num2str(length(z))])
	disp(['Calculated Length of y: 	', num2str(y_len)])
	disp(['Real length of y: 		', num2str(length(y))])
	disp(['Number of est. symbols, s_hat: 	', num2str(length(s_hat))])
	disp(['Number of est. bits, b_hat: 	', num2str(length(b_hat))])

	SNR = (1/length(y)*sum(abs(y).^2))/(1/length(wn)*sum(abs(wn).^2));
SNRdb = 10*log10(SNR)

end

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
