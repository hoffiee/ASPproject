% This function compares generated bitsstream with estimated bitstream and returns a percent on how well the estimate fits

function val = validation(b,b_hat)

	% Calculate the calidation
	
	% Check the amount of bits
	if length(b) == length(b_hat)	
		wb = 0;

		for k = 1:length(b)
			if ~(b(k) == b_hat(k))
				wb = wb + 1;
			end
		end
		disp(['Bit error: ', num2str(100*(wb)/length(b)), '%'])
	else
		disp('length mismatch')	
	end

end