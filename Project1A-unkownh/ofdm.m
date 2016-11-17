
function z = qpsk(s, N, N_cp, fcn_type)

	% Check nr of arguments to determine what to do
	if nargin < 4 || fcn_type == 1
		
		data = ifft(s,N);

		% Add cyclic prefix
		

		cp_data =  data(end-N_cp+1:end);

		% train_z
		% cp_train_z = train_z(end-N_cp+1:end);

		z = [cp_data data];

	else if nargin == 4 && fcn_type == -1
	
		s = s(N_cp+1:end-N_cp+1);

		z = fft(s,N);
		
	end

end