
function z = qpsk(s, N, N_cp, fcn_type)

	% Check nr of arguments to determine what to do
	if nargin < 4 || fcn_type == 1
		

		data = ifft(s);

		% Add cyclic prefix
		
		if length(data) >= N_cp
			cp_data =  data(end-N_cp+1:end);
		elseif length(data) < N_cp 			% If Cyclic prefix is longer than the actual test package
			cp_data = [data]; 
			while length(cp_data) < N_cp

				cp_data = [cp_data data];
			end
			
			cp_data = cp_data(end-N_cp+1:end);
			length(cp_data)
		end
			
		% train_z
		% cp_train_z = train_z(end-N_cp+1:end);

		z = [cp_data data];

	else if nargin == 4 && fcn_type == -1
	
		s = s(N_cp+1:N_cp+N);
		length(s)
		z = fft(s,N);
		
	end

end