function [error_rate, predicted_mask] = PD(train_FG, train_BG, mu0_FG, mu0_BG, sigma0_FG, sigma0_BG)
    %BAYES Summary of this function goes here
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
    BG_class_prior = BG_num_rows / total_num_pixels ;
    FG_class_prior = FG_num_rows / total_num_pixels ;
    
    % define block size
    block_height = 8;
    block_width = 8;
    
    % calcuate mu_n and sigma_n for FG
    feats = train_FG ;
    mu0 = mu0_FG;
    sigma0 = sigma0_FG ;

    [n, ~] = size(feats);
    sigma = cov(feats, 1) ;
    mu_ml = mean(feats) ;
    mu0 = mu0' ; mu_ml = mu_ml' ;
    mu_n = ( ( sigma0 * inv(sigma0 + (sigma / n)) ) * mu_ml) + ( (1/n) * ( sigma * inv(sigma0 + (sigma / n)) ) * mu0 );
    sigma_n = sigma0 * inv(sigma0 + (sigma / n)) * (1/n) * sigma ;
    mu_n_FG = reshape(mu_n, 1, []);
    sigma_n_FG = sigma_n + sigma;


    % calcuate mu_n and sigma_n for BG
    feats = train_BG ;
    mu0 = mu0_BG;
    sigma0 = sigma0_BG ;

    [n, ~] = size(feats);
    sigma = cov(feats, 1) ;
    mu_ml = mean(feats) ;
    mu0 = mu0' ; mu_ml = mu_ml' ;
    mu_n = ( ( sigma0 * inv(sigma0 + (sigma / n)) ) * mu_ml) + ( (1/n) * ( sigma * inv(sigma0 + (sigma / n)) ) * mu0 );
    sigma_n = sigma0 * inv(sigma0 + (sigma / n)) * (1/n) * sigma ;
    mu_n_BG = reshape(mu_n, 1, []);
    sigma_n_BG = sigma_n + sigma;


    % load dct features
    temp = load("../data/dct_features.mat");
    dct_features = temp.dct_features;
    
    % calculate probabilities
    p0 = mvnpdf(dct_features, mu_n_BG, sigma_n_BG) * BG_class_prior;
    p1 = mvnpdf(dct_features, mu_n_FG, sigma_n_FG) * FG_class_prior;

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