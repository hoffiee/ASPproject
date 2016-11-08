% This is a test file used to test implemented functions
clear all, clc, format compact



% Test for qpsk.m

% Define predetermined bits, do 3 testcases
b1 = [-1 -1 -1 -1 1 1 1 1];
b2 = [1 -1 1 -1 1 -1 1 -1];
b3 = [1 -1 -1 1 -1 -1 1 1];




s1 = qpsk(b1)
s2 = qpsk(b2)
s3 = qpsk(b3)

