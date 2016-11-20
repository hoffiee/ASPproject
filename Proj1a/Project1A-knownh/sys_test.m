clear all, clf, close all, clc, format compact




N = 128;
N_cp = 60;
time_delay = [-4 -1 0 1 4];
sigm = [0 0.01 0.05];
% sigm = 0.05;

% plotgeneratorknown(N,N_cp, ch, time_delay, sigm)


for ch = 1:2		% plot for both channels
	for s = 1:length(sigm)
		for t = 1:length(time_delay)
			plotgeneratorknown(N,N_cp, ch, time_delay(t), sigm(s))

		end
	end
end



