function sqr_error = dpGaussianFunc(init,target_locations,AE_gen_data)
    
% Load parameters
sigma = init(1);    % Width of generalization e.g. 45
mu = init(2);       % Peak of adaptation e.g. 0
height = init(3);   % Max adaptation (not including global generalization) e.g. 20
offset = init(4);   % global adaptation e.g. 0

% Generate gaussian based on parameters
simulated_gen = height.*(gaussmf(target_locations,[sigma mu])) + offset;
% 'gaussmf' is part of a the "Fuzzy Logic" Matlab toolbox.


sqr_error = sum( (AE_gen_data - simulated_gen).^2 );

