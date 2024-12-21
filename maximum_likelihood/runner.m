clear; 
rng(42);

% read data
data = load("../data/TrainingSamplesDCT_8_new.mat") ;

% calculate prior
[BG_num_rows, BG_num_cols] = size(data.TrainsampleDCT_BG) ;
[FG_num_rows, FG_num_cols] = size(data.TrainsampleDCT_FG) ;
total_num_pixels = BG_num_rows + FG_num_rows ;
BG_prior = BG_num_rows / total_num_pixels ;
FG_prior = FG_num_rows / total_num_pixels ;
fprintf("%d BG pixels\n", BG_num_rows) ;
fprintf("%d FG pixels\n", FG_num_rows) ;
fprintf("BG prior = %.6f\n", BG_prior) ;
fprintf("FG prior = %.6f\n", FG_prior) ;

% draw histogram
freq = [ones(1, FG_num_rows), zeros(1, BG_num_rows)];

fig = figure('Visible', 'off');
histogram(freq);
xlabel('Label');
ylabel('Frequency');
title('Label Frequency Histogram');
saveas(fig, 'generated_images/label_frequency_histogram.png');
close(fig);


fig = figure('Visible', 'off');
bar([ BG_prior , FG_prior ]);
xticks([1 2]); 
xticklabels({'0', '1'});  
xlabel('Label');
ylabel('Probability');
title('Prior');
saveas(fig, 'generated_images/prior_probability.png');
close(fig);


% compute mean and stds (using N as normalization term)
fg_means = mean(data.TrainsampleDCT_FG);
bg_means = mean(data.TrainsampleDCT_BG);
fg_stds = std(data.TrainsampleDCT_FG, 1);
bg_stds = std(data.TrainsampleDCT_BG, 1);


% plot 64 features
fig = figure('Position', [100, 100, 2500, 2000], 'Visible', 'off');
t = tiledlayout(8, 8, 'TileSpacing', 'compact', 'Padding', 'compact'); 
for i = 1 : BG_num_cols
    nexttile;

    fg_mean = fg_means(i);
    bg_mean = bg_means(i);
    fg_std = fg_stds(i);
    bg_std = bg_stds(i);
    
    x_min = min([fg_mean - 4 * fg_std, bg_mean - 4 * bg_std]);
    x_max = max([fg_mean + 4 * fg_std, bg_mean + 4 * bg_std]);
    x = linspace(x_min, x_max, 500);
    
    fg_curve = (1 / (fg_std * sqrt(2 * pi))) * exp(-0.5 * ((x - fg_mean) / fg_std).^2);
    bg_curve = (1 / (bg_std * sqrt(2 * pi))) * exp(-0.5 * ((x - bg_mean) / bg_std).^2);
    
    plot(x, fg_curve, '-b'); 
    hold on;
    plot(x, bg_curve, '-r');

    title(['Feature ', num2str(i)]);

    hold off;
end

sgtitle('Gaussian Distributions of 64 Features -- Blue Cheetah -- Red Grass');
saveas(fig, 'generated_images/64_gaussian.png');
close(fig);
fprintf('Finished Generate 64 features gaussian\n');


% select best and worst features
best_feature_indices = [1 2 3 4 36 47 50 57];
worst_feature_indices = [12 19 37 46 48 62 63 64];


% draw best 8 features
fig = figure('Position', [100, 100, 1000, 500], 'Visible', 'off');
t = tiledlayout(2, 4, 'TileSpacing', 'compact', 'Padding', 'compact'); 
for i = 1:numel(best_feature_indices)
    nexttile;

    idx = best_feature_indices(i);

    fg_mean = fg_means(idx);
    bg_mean = bg_means(idx);
    fg_std = fg_stds(idx);
    bg_std = bg_stds(idx);
    
    x_min = min([fg_mean - 4 * fg_std, bg_mean - 4 * bg_std]);
    x_max = max([fg_mean + 4 * fg_std, bg_mean + 4 * bg_std]);
    x = linspace(x_min, x_max, 500);
    
    fg_curve = (1 / (fg_std * sqrt(2 * pi))) * exp(-0.5 * ((x - fg_mean) / fg_std).^2);
    bg_curve = (1 / (bg_std * sqrt(2 * pi))) * exp(-0.5 * ((x - bg_mean) / bg_std).^2);
    
    plot(x, fg_curve, '-b'); 
    hold on;
    plot(x, bg_curve, '-r');

    title(['Feature ', num2str(idx)]);

    hold off;
end

sgtitle('Best 8 Features -- Blue Cheetah -- Red Grass');
saveas(fig, 'generated_images/best_8.png');
close(fig);
fprintf('Finished Generate best 8 features gaussian\n');



% draw worst 8 features
fig = figure('Position', [100, 100, 1000, 500], 'Visible', 'off');
t = tiledlayout(2, 4, 'TileSpacing', 'compact', 'Padding', 'compact'); 
for i = 1:numel(worst_feature_indices)
    nexttile;

    idx = worst_feature_indices(i);

    fg_mean = fg_means(idx);
    bg_mean = bg_means(idx);
    fg_std = fg_stds(idx);
    bg_std = bg_stds(idx);
    
    x_min = min([fg_mean - 4 * fg_std, bg_mean - 4 * bg_std]);
    x_max = max([fg_mean + 4 * fg_std, bg_mean + 4 * bg_std]);
    x = linspace(x_min, x_max, 500);
    
    fg_curve = (1 / (fg_std * sqrt(2 * pi))) * exp(-0.5 * ((x - fg_mean) / fg_std).^2);
    bg_curve = (1 / (bg_std * sqrt(2 * pi))) * exp(-0.5 * ((x - bg_mean) / bg_std).^2);
    
    plot(x, fg_curve, '-b'); 
    hold on;
    plot(x, bg_curve, '-r');

    title(['Feature ', num2str(idx)]);

    hold off;
end

sgtitle('Worst 8 Features -- Blue Cheetah -- Red Grass');
saveas(fig, 'generated_images/worst_8.png');
close(fig);
fprintf('Finished Generate worst 8 features gaussian\n');



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


% % ---------- Using 64 features ----------
fg_features = data.TrainsampleDCT_FG;
bg_features = data.TrainsampleDCT_BG;

% compute mean
fg_mean = mean(fg_features);
bg_mean = mean(bg_features);

% compute covariance matrix
fg_cov = cov(fg_features, 1);
bg_cov = cov(bg_features, 1);

% make prediction
A = zeros(image_height, image_width);

for i = 1 : image_height - block_height + 1
    for j = 1 : image_width - block_width + 1

        x = img(i : i + block_height - 1 , j : j + block_width - 1);
        x = dct2(x);
        x = zigzagSort(x);

        p0 = mvg(x, bg_mean, bg_cov) * BG_prior;
        p1 = mvg(x, fg_mean, fg_cov) * FG_prior;

        if p1 > p0
            A(i, j) = 1;
        end
    end
end

assert(isequal(size(A), size(mask)));

% save prediction
figure;
imagesc(A); 
colormap(gray(255));
axis image;
title('Predicted Mask using 64 features');
imwrite(A, 'generated_images/predicted_mask_64_features.png');


% evaluate
num_diff = sum(A(:) ~= mask(:));
total_num_pixels = image_height * image_width;
error_rate = num_diff / total_num_pixels;
fprintf("\n---------- Using 64 Features ----------\n")
fprintf("Among %d pixels, %d were classified wrong\n", total_num_pixels, num_diff);
fprintf("Error Rate = %.6f\n", error_rate);




% ---------- Using best 8 features ----------
fg_features = data.TrainsampleDCT_FG(:, best_feature_indices);
bg_features = data.TrainsampleDCT_BG(:, best_feature_indices);

% compute mean
fg_mean = mean(fg_features);
bg_mean = mean(bg_features);

% compute covariance matrix
fg_cov = cov(fg_features, 1);
bg_cov = cov(bg_features, 1);

% make prediction
A = zeros(image_height, image_width);

for i = 1 : image_height - block_height + 1
    for j = 1 : image_width - block_width + 1

        x = img(i : i + block_height - 1 , j : j + block_width - 1);
        x = dct2(x);
        x = zigzagSort(x);
        x = x(:, best_feature_indices);

        p0 = mvg(x, bg_mean, bg_cov) * BG_prior;
        p1 = mvg(x, fg_mean, fg_cov) * FG_prior;

        if p1 > p0
            A(i, j) = 1;
        end
    end
end


assert(isequal(size(A), size(mask)));

% save prediction
figure;
imagesc(A); 
colormap(gray(255));
axis image;
title('Predicted Mask using best 8 features');
imwrite(A, 'generated_images/predicted_mask_8_features.png');


% evaluate
num_diff = sum(A(:) ~= mask(:));
total_num_pixels = image_height * image_width;
error_rate = num_diff / total_num_pixels;
fprintf("\n---------- Using best 8 Features ----------\n")
fprintf("Among %d pixels, %d were classified wrong\n", total_num_pixels, num_diff);
fprintf("Error Rate = %.6f\n", error_rate);