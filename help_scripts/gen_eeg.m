% script to simulate a EEG

%% Generate time series for the active dipoles

 % Phase shift for the sources (in seconds)
phase_shift = [0.375 0.75 1.125] ;

% Get number of active dipoles
Nact = length(phase_shift);

% Central frequency for the wavelets
fc_wl = [7 10 13]; 

% Generate time series
for i = 1:Nact
    f0 = fc_wl(i);
    
    % Normalization terms for the wavelet
    sigma_f = f0/7;
    sigma_t = 1/(2*pi*sigma_f);
    
    % "source" contains the time courses of active sources
    source(i,:) =  real(exp(2*1i*pi*f0*model.t).*...
        exp((-(model.t-phase_shift(i)).^2)/(2*sigma_t^2)));
end

% Place the time series in dipoles lying on given coordinates
dip_or = randn(3,3);
% [J, actidx] = nip_simulate_activity(model.cortex.vc,[30 30 30], source, randn(2,3), model.t);
[J, actidx] = nip_simulate_activity(model.cortex.vc,[30 0 20; -30 0 20; 10 -40 0], source, dip_or, model.t);
% Apply a spatial low-pass filter to the activity so we get smoothed patch
% of activity
fuzzy = nip_fuzzy_sources(model.cortex,1.5,struct('dataset','montreal','save',true));
index = (1:3:model.Nd);
for i = 0:2
    J(index+i,:) = fuzzy*J(index+i,:); 
end

% Compute pseudo-EEG
clean_y = model.L*J;

% Add measurement noise to the EEG
snr = 1;
model.y = nip_addnoise(clean_y, snr);
