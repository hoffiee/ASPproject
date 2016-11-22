% This function models the channels
function [h H] = channel(ch_choice) % z
	% z is the input vector to the channel
	% ch_choice choses between h1 and h2 with 1 and 2 respectively

	if ch_choice == 1

		h = [];

		for n = 0:59
			h = [h 0.8^n];
		end

		H = fft(h);

	elseif ch_choice == 2

		h = [zeros(1,9)];
		h(1) = 0.5;
		h(9) = 0.5;

		H = fft(h);
		
	end

end
