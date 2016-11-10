% This is the function for the block QPSK which turns a vector of bits
% into an s(k)

% fcn_type defines if regular or inverse.

function s = qpsk(b, fcn_type)

	% Check nr of arguments to determina what to do
	if nargin < 2 || fcn_type == 1
		% it is given that we will receive a bitstream of 128 bit, therefore it is
		% not needed to handle cases where an uneven length of b is received
		for n = 1:length(b)/2
			s(n) = (1/sqrt(2))*(b(2*n-1) + i*b(2*n));
		end
	
	else if nargin == 2 && fcn_type == -1
		% This is what we do if it is the inverse
	end

end