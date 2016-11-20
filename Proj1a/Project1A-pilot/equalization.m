% This function performs the equalisation with pilots
function [s_hat H_hat] = equalization(r,pilots)

	N = length(r);
	nrPilots = length(pilots);
	step_size = N/nrPilots;
	pilots_ind = step_size/2:step_size:N;

	H_hat = r(pilots_ind) ./ pilots;
	
	% This fills the estimation to enough samples
	H_hat = kron(H_hat, ones(1,step_size));

	for k = 1:length(H_hat)
		if (mod(k, step_size) == 0) && (k ~= N)
			H_hat(k) = (H_hat(k)+H_hat(k+1))/2;
		end
	end
	
	s_hat = r./H_hat;

end