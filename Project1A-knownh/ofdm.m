function z = ofdm(s, N, N_cp, fcn_type)

	% Check nr of arguments to determine what to do
	if nargin < 4 || fcn_type == 1
		
		z = ifft(s);
		% disp(['z:',num2str(length(z))])

		% Add cyclic prefix
		z = [z(end-N_cp+1:end) z];

		% disp(['z: ', num2str(length(z))])

	else if nargin == 4 && fcn_type == -1

		
		s = s(N_cp+1:N_cp+N);
		% disp(['s: ', num2str(length(s))])
		z = fft(s);
	end
end