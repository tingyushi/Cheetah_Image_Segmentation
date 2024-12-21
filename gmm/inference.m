clear;

data = load('../data/TrainingSamplesDCT_8_new.mat');
fg_data = data.TrainsampleDCT_FG;
bg_data = data.TrainsampleDCT_BG;
[N1, ~] = size(fg_data);
[N2, ~] = size(bg_data);
fg_prior = N1 / (N1 + N2);
bg_prior = 1 - fg_prior;


%% Problem (a) 
mixtures = [1 2 3 4 5];
dim_ranges = [1 2 4 8 16 24 32 40 48 64];
errorMap = containers.Map();

for fg_mix_idx = mixtures
for bg_mix_idx = mixtures

fprintf("fg mixture = %d -- bg mixture = %d\n", fg_mix_idx, bg_mix_idx);
fg_record = load(sprintf("records/a_fg_mixture_%d_C_8.mat", fg_mix_idx)).record;
bg_record = load(sprintf("records/a_bg_mixture_%d_C_8.mat", bg_mix_idx)).record;

error_rates = zeros(size(dim_ranges));
for i =1:numel(dim_ranges)
    [error_rate, p_mask] = BDR(fg_record.mus, fg_record.sigmas, fg_record.pis, fg_prior, ...
                          bg_record.mus, bg_record.sigmas, bg_record.pis, bg_prior, ...
                          dim_ranges(i));
    
    imwrite(p_mask, sprintf("images/a_fg%d_bg%d_dim%d.png", fg_mix_idx, bg_mix_idx, dim_ranges(i)));

    error_rates(i) = error_rate;
    fprintf("dim_range = %d -- error rate = %.4f\n", dim_ranges(i), error_rate);
end

errorMap(sprintf("fg_%d_bg_%d", fg_mix_idx, bg_mix_idx)) = error_rates;

fprintf("\n\n");

end
end

save('records/a_errorMap.mat', 'errorMap');


%% Problem (b)
Cs = [1 2 4 8 16 32];
dim_ranges = [1 2 4 8 16 24 32 40 48 64];
errorMap = containers.Map();

for C=Cs

fprintf("BG/FG Mixture C = %d\n",C);
fg_record = load(sprintf("records/b_fg_C_%d.mat", C)).record;
bg_record = load(sprintf("records/b_bg_C_%d.mat", C)).record;

error_rates = zeros(size(dim_ranges));
for i =1:numel(dim_ranges)
    [error_rate, p_mask] = BDR(fg_record.mus, fg_record.sigmas, fg_record.pis, fg_prior, ...
                          bg_record.mus, bg_record.sigmas, bg_record.pis, bg_prior, ...
                          dim_ranges(i));
    imwrite(p_mask, sprintf("images/b_C%d_dim%d.png", C, dim_ranges(i)));
    error_rates(i) = error_rate;
    fprintf("dim_range = %d -- error rate = %.4f\n", dim_ranges(i), error_rate);
end

errorMap(sprintf("fg_bg_C_%d", C)) = error_rates;

fprintf("\n\n");

end

save('records/b_errorMap.mat', 'errorMap');