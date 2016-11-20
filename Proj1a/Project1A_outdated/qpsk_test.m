% This file tests the function of qpsk.

b128 = bits(128);
b256 = bits(256);

s128 = qpsk(b128);
s256 = qpsk(b256);

b_hat128 = qpsk(s128, N, -1);
b_hat256 = qpsk(s256, N, -1);

validation(b128,b_hat128)
validation(b256,b_hat256)

