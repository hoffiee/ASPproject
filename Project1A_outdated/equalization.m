% This function performs the equalisation
function b_hat = equalization(r,h)

	% M = length(r) + length(h) - 1;

	% % R = fft(r,M);
	% H = fft(h,length(r));
	% b_hat = ifft(r./H);

	% length(b_hat)

	% b_hat = r./H;

	b_hat = r;

end