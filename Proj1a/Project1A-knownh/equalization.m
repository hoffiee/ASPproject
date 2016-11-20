% This function performs the equalisation
function b_hat = equalization(r,H)

	% Equalization is done within QPSK with this method.

	% b_hat = r;

	b_hat = conj(H).*r./abs(H).^2;

end