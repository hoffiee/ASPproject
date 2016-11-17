% This is a test file used to test implemented functions
clear all, clc, clf, close all, format compact

% Given constants
N = 128;
N_cp = 60; 
sigma = 0.1;

% 1. Generate a bit sequence b(k), length 2N = 2*128.
b = bits(N);


% 2. Encode the bit sequence b(k) into a QPSK sequence s(k)
s = qpsk(b,N);


%3. Generate the OFDM sequence z(n) from s(k). Use N = 128 sub-carriers in the OFDM. Select a proper cyclic prefix length Ncp.
z = ofdm(s, N, N_cp);


% 4. Use a channel description (h1(n) or h2(n)) with corresponding Hi(k)
[h, H] = channel(1,N);

% Add cyclic prefix, this is done within ofdm
y_len = length(z) + length(h) - 1;

y = conv(h,z)+w(sigma,y_len);

y = y(N_cp+1:end-N_cp+1);


r = ofdm(y, N, N_cp, -1);


% GÖR INGET FÖR TILLFÄLLET
s_hat = equalization(r,h);

b_hat = qpsk(r,N,-1);

validation(b,b_hat);

%=====================================
%===== Display system properties =====
%=====================================
disp('===========================')
disp('==== System properties ====')
disp('===========================')
disp(['Number of bits b: 		', num2str(length(b))])
disp(['Number of symbols, s: 		', num2str(length(s))])
disp(['length of z: 			', num2str(length(z))])
disp(['Calculated Length of y: 	', num2str(y_len)])
disp(['Real length of y: 		', num2str(length(y))])
disp(['Number of est. symbols, s_hat: 	', num2str(length(s_hat))])
disp(['Number of est. bits, b_hat: 	', num2str(length(b_hat))])

%=====================================
%=====   Display system plots    =====
%=====================================
% figure; stem(b)
% title('Bitstream')

% figure; plot(s)
% title('Symbols')

% figure; plot(real(z)), hold on, plot(imag(z))
% legend('real(z)','imag(z)'), title('OFDM z')
