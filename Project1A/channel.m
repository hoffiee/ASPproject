% This function models the channels
function [y1 y2] = channel(ch_choice) % z
	% z is the input vector to the channel
	% ch_choice choses between h1 and h2 with 1 and 2 respectively

	if ch_choice == 1



		h = [];

		for n = 0:59
			h = [h 0.8^n];
		end

		y1 = h;

		N=128;
		for k = 0: N-1
			H(k+1) = 1;
			for n = 0:length(h)-1
				H(k+1) = H(k+1) + h(n+1)*exp(-i*2*pi*k*n/N);
			end
		end

		y2 = H;

	elseif ch_choice == 2
		


		h = [zeros(1,9)];
		h(1) = 0.5;
		h(9) = 0.5;

		% y = conv(h,z);
		y = h;

		N=128;
		for k = 0: N-1
			H(k+1) = 1;
			for n = 0:length(h)-1
				H(k+1) = H(k+1) + h(k+1)*exp(-i*2*pi*k*n/N);
			end
		end

		y2 = H;
		
	end
		

end
