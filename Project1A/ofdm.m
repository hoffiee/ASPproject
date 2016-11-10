
function z = qpsk(s, N_cp, fcn_type)

	% Check nr of arguments to determina what to do
	if nargin < 3 || fcn_type == 1
		

		N = length(s);
		
		for n = 0:N-1
			z(n+1)=0;
			for k = 0:N-1
				z(n+1) = z(n+1) + (1/N)*s(k+1)*exp(i*2*pi*n*k/N);
			end
		end


		z = [z(end-N_cp:end) z];

		
	else if nargin == 3 && fcn_type == -1

		N = 128;


		for k = 0:N-1
			z(k+1) = 0;
			for n = 0:length(s)-1
				z(k+1) = z(k+1) + s(n+1)*exp(-i*2*pi*k*n/N);  
			end
		end
	end
end