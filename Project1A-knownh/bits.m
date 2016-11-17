% This is the function generating the bitstream of 2N = 2*128
function b = bits(N)
	% N defines the length of the bitstream
	% b e {-1,1}
	R=randi([0 1],2*N,1);
for n=1:length(R)
    if R(n) == 0
        b(n)=-1;
    elseif R(n) == 1
        b(n)=1;
    end
end