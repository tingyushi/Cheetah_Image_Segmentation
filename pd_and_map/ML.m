function [error_rate, predicted_mask] = ML(train_FG, train_BG)
    %ML Summary of this function goes here
    %   Detailed explanation goes here

    % read original image
    img = imread("../data/cheetah.bmp") ;
    img = im2double(img);
    [image_height, image_width] = size(img);
    
    % read mask(true label)
    mask = imread("../data/cheetah_mask.bmp") ;
    mask = im2double(mask); 
    
    % calculate class prior
    [BG_num_rows, ~] = size(train_BG) ;
    [FG_num_rows, ~] = size(train_FG) ;
    total_num_pixels = BG_num_rows + FG_num_rows ;
    BG_prior = BG_num_rows / total_num_pixels ;
    FG_prior = FG_num_rows / total_num_pixels ;
    
    % define block size
    block_height = 8;
    block_width = 8;

    % define the features
    fg_features = train_FG;
    bg_features = train_BG;
    
    % compute mean
    fg_mean = mean(fg_features);
    bg_mean = mean(bg_features);
    
    % compute covariance matrix
    fg_cov = cov(fg_features, 1);
    bg_cov = cov(bg_features, 1);

    % load dct features
    temp = load("../data/dct_features.mat");
    dct_features = temp.dct_features;
    
    % calculate probabilities
    p0 = mvnpdf(dct_features, bg_mean, bg_cov) * BG_prior;
    p1 = mvnpdf(dct_features, fg_mean, fg_cov) * FG_prior;

    % make prediction
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