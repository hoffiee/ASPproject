% This function performs the equalisation
function b_hat = equalization(r,rt,st)

	length(rt)
	length(st)
	H_hat = rt./st;

	figure;
	plot(abs(H_hat))

	h_hat = ifft(H_hat);
	H_hat = fft(h_hat,128);

	b_hat = conj(H_hat).*r;

end