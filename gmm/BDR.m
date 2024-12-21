function [error_rate, predicted_mask] = BDR(fg_mus, fg_sigmas, fg_pis, fg_prior, ...
                                            bg_mus, bg_sigmas, bg_pis, bg_prior, ...
                                            dim_range)


% read original image
img = imread("../data/cheetah.bmp") ;
img = im2double(img);
[image_height, image_width] = size(img);

% read mask(true label)
mask = imread("../data/cheetah_mask.bmp") ;
mask = im2double(mask); 

% define block size
block_height = 8;
block_width = 8;

% prepare mus
new_fg_mus = fg_mus(:, 1:dim_range);
new_bg_mus = bg_mus(:, 1:dim_range);

% prepare covariance matrics
[C, ~] = size(fg_sigmas);
fg_covs = zeros(dim_range, dim_range, C);
for i=1:C
    fg_covs(:, :, i) = diag( fg_sigmas(i, 1:dim_range) );
end

[C, ~] = size(bg_sigmas);
bg_covs = zeros(dim_range, dim_range, C);
for i=1:C
    bg_covs(:, :, i) = diag( bg_sigmas(i, 1:dim_range) );
end

% create gm objects
fg_gm_obj = gmdistribution(new_fg_mus, fg_covs, fg_pis);
bg_gm_obj = gmdistribution(new_bg_mus, bg_covs, bg_pis);

% load dct features
temp = load("../data/dct_features.mat");
dct_features = temp.dct_features;
feats = dct_features(:, 1:dim_range);

% calculate probability
p0 = pdf(bg_gm_obj, feats) * bg_prior;
p1 = pdf(fg_gm_obj, feats) * fg_prior;

% predict mask
A = zeros(image_height, image_width);
counter = 1;
for i = 1 : image_height - block_height + 1
    for j = 1 : image_width - block_width + 1
        if p1(counter) > p0(counter)
            A(i, j) = 1;
        end
        counter = counter + 1;
    end
end

assert(isequal(size(A), size(mask)));
predicted_mask = A;

% evaluate
num_diff = sum(A(:) ~= mask(:));
total_num_pixels = image_height * image_width;
error_rate = num_diff / total_num_pixels;

end