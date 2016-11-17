
function z = qpsk(s, N, N_cp, fcn_type)

	% Check nr of arguments to determine what to do
	if nargin < 4 || fcn_type == 1
		
		z = ifft(s,N);

		% Add cyclic prefix
		z = [z(end-N_cp+1:end) z];

	else if nargin == 4 && fcn_type == -1
	
		s = s(N_cp+1:end-N_cp+1);

		z = fft(s,N);
		
	end

end