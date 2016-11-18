% This function performs the equalisation with pilots
function [s_hat H_hat] = equalization(r,pilots)

	N = length(r);
	nrPilots = length(pilots)
	step_size = N/nrPilots
	pilots_ind = 1:step_size:N



	h_est = r(pilots_ind) ./ pilots;
	plot(abs(h_est))
	figure;
	plot(abs(fft(h_est)))




	pil_count = 1;
	for k = 1:N
		if k < step_size % This is estimated through the first values
			s_est(k) = r(k) ./ h_est(1)
		elseif k > pilots_ind(end) 	% If the index is bigger than the last pilot index, use the last datapoint
			s_est(k) = r(k) ./ h_est(end)
		elseif % When index passes pilot index inc pil_count and 
	end




	s_hat = r;%conj(H_hat).*r;

end