
function [z zt] = qpsk(s, N, N_cp, Nt, fcn_type)

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
		end
			
		% train_z
		% cp_train_z = train_z(end-N_cp+1:end);

		z = [cp_data data];

		zt = [];

	else if nargin == 5 && fcn_type == -1
	
		st = s(N_cp+1:N_cp+Nt);
		
		s = s(2*N_cp+Nt+1:N_cp+Nt+N_cp+N);


		z = fft(s);
		zt = fft(st);
		
	end

end