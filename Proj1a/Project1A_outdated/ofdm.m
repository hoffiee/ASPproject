
function z = qpsk(s, N, N_cp, fcn_type)

	% Check nr of arguments to determine what to do
	if nargin < 4 || fcn_type == 1
		

		% N = length(s)
		

		% FFT
		for n = 0:N-1
			z(n+1)=0;
			for k = 0:N-1
				z(n+1) = z(n+1) + (1/N)*s(k+1)*exp(i*2*pi*n*k/N);
			end
		end		

		% z = ifft(s);

		% Add cyclic prefix
		z = [z(end-N_cp+1:end) z];

	else if nargin == 4 && fcn_type == -1


		% start = 60 + N_cp -1;

		% IFFT
		for k = 0:N-1
			z(k+1) = 0;
			for n = 0:length(s)-1
				z(k+1) = z(k+1) + s(n+1)*exp(-i*2*pi*k*n/N);  
			end
		end

		% z = fft(s,N);
		
	end

end