clear; 
rng(42);


% read data
data = load("../data/TrainingSamplesDCT_8.mat") ;
assert(all(data.TrainsampleDCT_BG(:) >= 0));
assert(all(data.TrainsampleDCT_FG(:) >= 0));

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


% calculate conditional probabilty
BG_second_largest_indices = secondLargestIndex(data.TrainsampleDCT_BG);
FG_second_largest_indices = secondLargestIndex(data.TrainsampleDCT_FG);
BG_index_count = zeros(1, BG_num_cols);
FG_index_count = zeros(1, FG_num_cols);
for i = 1:BG_num_cols
    BG_index_count(i) = sum(BG_second_largest_indices == i);
    FG_index_count(i) = sum(FG_second_largest_indices == i);
end 
BG_conditional_prob = BG_index_count / BG_num_rows;
FG_conditional_prob = FG_index_count / FG_num_rows;


fig = figure('Visible', 'off');
histogram(BG_second_largest_indices, 1:64);
xlim([1, 64]);
xlabel('Index');
ylabel('Frequency');
title('BG Frequency Histogram');
saveas(fig, 'generated_images/bg_frequency_histogram.png');
close(fig);


fig = figure('Visible', 'off');
histogram(FG_second_largest_indices, 1:64);
xlim([1, 64]);
xlabel('Index');
ylabel('Frequency');
title('FG Frequency Histogram');
saveas(fig, 'generated_images/fg_frequency_histogram.png');
close(fig);

fig = figure('Visible', 'off');
bar(BG_conditional_prob);
xlabel('Index');
ylabel('Probability');
title('P(x|grass)');
saveas(fig, 'generated_images/bg_prob_histogram.png');
close(fig);

fig = figure('Visible', 'off');
bar(FG_conditional_prob);
xlabel('Index');
ylabel('Probability');
title('P(x|cheetah)');
saveas(fig, 'generated_images/fg_prob_histogram.png');
close(fig);


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

% define the position of central pixel
central_pixel_row = 4;
central_pixel_col = 4;

% calculate the amount the pad
pad_left = central_pixel_col - 1;
pad_right = block_width - central_pixel_col;
pad_up = central_pixel_row - 1;
pad_bottom = block_height - central_pixel_row;

% pad image
padded_img = zeros(image_height + pad_left + pad_right, image_width + pad_up + pad_bottom);
padded_img(pad_up + 1 : pad_up + image_height , pad_left + 1 : pad_left + image_width) = img;

% compute feature matrix
feats = zeros(image_height*image_width, block_height*block_width);
counter = 1 ;
for i = pad_up+1 : pad_up+image_height
    for j = pad_left+1 : pad_left+image_width

        % get block
        block = padded_img(i-pad_up : i+pad_bottom , j-pad_left : j+pad_right);
        
        % compute dct
        block_dct = dct2(block);

        % zigzag arrange
        zigzag_sorted = zigzagSort(block_dct);
           
        % store feat
        feats(counter , :) = abs(zigzag_sorted);

        counter = counter + 1;
    end
end

assert(counter - 1 == image_height*image_width )

% find indices of the second largest element
feats_second_largest_indices = secondLargestIndex(feats);

% make prediction
A = zeros(image_height, image_width);

trigger = 0;
for i = 1:image_height
    for j = 1:image_width
        idx = (i - 1) * image_width + j;
        x = feats_second_largest_indices(idx);
        p_fg_x_numerator = FG_prior * FG_conditional_prob(x);
        p_bg_x_numerator = BG_prior * BG_conditional_prob(x);

        if p_fg_x_numerator > p_bg_x_numerator
            A(i, j) = 1;
        elseif p_fg_x_numerator < p_bg_x_numerator
            A(i, j) = 0;
        else
            % same probability random choose between 0 and 1
            A(i, j) = randi([0, 1]);
        end
    end
end

assert(isequal(size(A), size(mask)));

% save prediction
figure;
imagesc(A); 
colormap(gray(255));
axis image;
title('Predicted Mask');
imwrite(A, 'generated_images/predicted_mask.png');


% evaluate
num_diff = sum(A(:) ~= mask(:));
total_num_pixels = image_height * image_width;
error_rate = num_diff / total_num_pixels;
fprintf("Among %d pixels, %d were classified wrong\n", total_num_pixels, num_diff);
fprintf("Error Rate = %.6f\n", error_rate);