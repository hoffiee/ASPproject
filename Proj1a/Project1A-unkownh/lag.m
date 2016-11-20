% This file creates lag for the system
function y_out = lag(y_in, td, sigm)

	if td < 0 
		y_out = [w(sigm,abs(td)) y_in(1:end-abs(td))];
		% y_out = y_in(1:end-abs(td));
	elseif td > 0
		% y_out = y_in(abs(td):end);
		y_out = [y_in(abs(td):end) w(sigm,abs(td))];
	elseif td == 0
		y_out = y_in;
	end

end