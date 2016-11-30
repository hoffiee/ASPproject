function [biterror, SNR] = main_function(SNR, f_s, f_cm, N, N_t, N_cp, R, diagnostics)

sigm = 			10^-(SNR/20);
D = 			R;			% Downsampling rate, same as upsampling	
bw = 			f_s/R;		% Bandwidth of real valued signal (only real frequencies)


%===================================
%======= 	TRANSMITTER 	========
%===================================
b = bits(2*N);		% Data
bt = bits(2*N_t);	% training data
s = qpsk(b);		% symbols
st = qpsk(bt);		% training symbols
symb = ifft(s);		% data
symbt = ifft(st);	% training
z_data = [symb(end-N_cp+1:end) symb];	% add cyclic prefix
zt = [symbt(end-N_cp+1:end) symbt];		% add cyclic prefix
z = [zt z_data];	% Package to be sent, N_cp+N_t+N_cp + N = 192
%===================================

% z(n) 		->	Interpol.	-> z_i(n) ##NOTE: also known as upsampling l= R*192 = 1536
z_u = zeros(1,R*length(z));	% Make vector with zeros 
z_u(1:R:end) = z;	% Add values from z(n)

% Interpolation filter
B = firpm(63,[0 1/R 1.6/R 1],[1 1 0 0]);
z_i = conv(z_u,B);

% z_i(n) 	-> Modulation 	-> z_imr(n)
n = (0:length(z_i)-1);
z_im = z_i.*exp(1i*2*pi*f_cm/f_s*n);
z_imr = real(z_im);
y_len = length(z_imr);
%===================================
%======= 	  CHANNEL 	 	========
%===================================
y_rec = simulate_audio_channel(z_imr,sigm)'; % Turn into row vector to fit our code

%===================================
%======= 	 RECEIVER 		========
%===================================
% Synchronization
E_avg = max(y_rec).^2*sum(abs(y_rec).^2)/length(y_rec);
% E_avg = max(y_rec).^2*(sum(abs(y_rec))/(2*length(y_rec))).^2*2*pi
% E_avg = 2*pi*sum(abs(y_rec(1:100)).^2)/100
ind = 1;
while true
	if abs(y_rec(ind)).^2 > E_avg
		break;
	end
	ind = ind + 1;
end
% y_synch = y_rec(ind+N_cp:ind+N_cp+y_len-1);
y_synch = y_rec(ind:ind+y_len-1);

% y_rec(n) 	-> Demodulation -> y_ib(n)
y_ib = y_synch.*exp(-1i*2*pi*f_cm/f_s*n);

% y_ib(n) 	-> Decimation 	-> y(n)
y_i = conv(y_ib,B);		% Filter
y = y_i(1:D:end);

%===================================
yt = y(N_cp+1:N_cp+N_t); 				% get training symbols
y_data = y(N_cp+N_t+N_cp+1:N_cp+N_t+N_cp+N);	% get data
rt = fft(yt);
r = fft(y_data);

% r(k) 		-> EQ 			-> s_hat(k)
H_hat = rt./st; 					% Estimate H_hat
H_hat = kron(H_hat, ones(1,N/N_t));	% expand estimated H_hat so that length matches
s_hat = conj(H_hat).*r;%./abs(H_hat).^2;
b_hat = qpsk(s_hat, -1);
%===================================


biterror = sum(b~=b_hat);

% signal_power = sum(abs(z_imr).^2);
% SNR = 20*log10(signal_power/sigm);
% SNR = 20*log20(1/sigm);


if diagnostics 
	% System information
	BER = sum(b~=b_hat)/(2*N);
	
	disp(['BER: 			', num2str(BER*1e3),'e-3'])
	disp(['SNR: 	', num2str(SNR), ' sigma: 	', num2str(sigm)])
	% Signal power
	signal_power = sum(abs(z_mr).^2);
	disp(['Signal power: 		', num2str(signal_power)])
	% Cyclic prefix length
	disp(['Cyclic prefix length: 	', num2str(N_cp), ' Samples'])
	% Spectral efficiency
	% 				Bits / 	  		s        /     Hz
	spec_eff = 	 N   / ((2*N_cp+N+N_t)*(1/f_s) *  (bw ));
	disp(['Spectral efficiency: 	', num2str(spec_eff),' Bits/s/Hz'])
	symb_eff = N / (2*N_cp+N_t+N); % Amount of data symbols compared to all symbols sent.
	disp(['Symbol efficiency 	', num2str(symb_eff*100),'%'])
end





% if plots

% 	title_fontsize = 15;
% 	axis_fontsize = 12;
% 	legend_fontsize = 10;
% 	NN = 2^14; % Number of frequency grid points
% 	f = (0:NN-1)/NN;
% 	F = (0:NN-1)/NN*f_s;


% 	% Plot estimated channel
% 	figure; plot(abs(H_hat))
% 	title('Estimated channel $|H(\omega)|$','Fontsize',title_fontsize,'Interpreter','Latex')
% 	% Här lägger vi ALLA plots, så vill man inte vänta på plots 
% 	% som kan ta tid ibland så har man plots = false;

% 	figure;
% 	semilogy(F,abs([fft(z_i,NN); fft(z_imr,NN); fft(z_mr,NN)])) % Check transforms
% 	legend('Interpolated','Modulated','real and modulated')
% 	xlabel('Frequency (Hz)');


% 	% Plot signal spectrum through different parts of the system
% 	% figure;
% 	% title('f abs(fft(z,NN))')
% 	% semilogy(f,abs(fft(z,NN))) % Check transform
% 	% xlabel('relative frequency f/fs');


% 	% figure;
% 	% semilogy(f,abs(fft(z,NN))) % Check transform
% 	% title('Transform before interpol','Fontsize',title_fontsize,'Interpreter','Latex')
% 	% xlabel('relative frequency f/fs');
% 	% figure;
% 	% semilogy(f,abs(fft(z_u,NN))) % Check transform
% 	% xlabel('normalized frequency f/fs');

% 	figure;
% 	semilogy(f,abs([fft(z,NN); fft(z_u,NN); fft(z_i,NN); fft(B,NN); fft(z_imr,NN)])) % Check transforms
% 	% title('','Fontsize',title_fontsize,'Interpreter','Latex')
% 	legend('u','Up-sampled z_u','Interpolated after LP filtering','LP-filter','Modulated z_imr')
% 	xlabel('relative frequency f/fs');
% end










end