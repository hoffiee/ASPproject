% This function performs the equalisation
function [s_hat H_hat] = equalization(r,rt,st,N,Nt)
	
	H_hat = rt./st;

	H_hat = kron(H_hat, ones(1,N/Nt));

	s_hat = conj(H_hat).*r;

end