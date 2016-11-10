% This is a test file used to test implemented functions
clear all, clc, format compact

% Define predetermined bits, do 3 testcases
% b1 = [-1 -1 -1 -1 1 1 1 1]
% b2 = [1 -1 1 -1 1 -1 1 -1];
% b3 = [1 -1 -1 1 -1 -1 1 1];

% s1 = qpsk(b1,1)
% s2 = qpsk(b2,1)
% s3 = qpsk(b3,1)

% z1 = ofdm(s1)


% y1 = channel(z1, 1)

N_cp = 10; 

b = bits(128);
s = qpsk(b);


z = ofdm(s, N_cp);


[h, H] = channel(1);

y = conv(h,z);

r = ofdm(y, N_pc, -1);

b_hat = qpsk(r,-1);


validation(b,b_hat)

