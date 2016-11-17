function output = w(sigma, y_len)

	output = 1/sqrt(2)*sigma*(randn(y_len,1) + 1i*randn(y_len,1))';

end