function [record] = DRIVER(d, s)
    %DRIVER Summary of this function goes here
    %   Detailed explanation goes here
    

    % load parameters priors
    if s == 1
        prior_data = load("../data/Prior_1.mat") ;
    else
        prior_data = load("../data/Prior_2.mat") ;
    end
    wi = prior_data.W0 ;
    mu0_FG = prior_data.mu0_FG ;
    mu0_BG = prior_data.mu0_BG ;
    


    % load data
    data = load("../data/TrainingSamplesDCT_subsets_8.mat") ;
    if d == 1
        train_FG = data.D1_FG ;
        train_BG = data.D1_BG ;
    elseif d == 2
        train_FG = data.D2_FG ;
        train_BG = data.D2_BG ;
    elseif d == 3
        train_FG = data.D3_FG ;
        train_BG = data.D3_BG ;
    else
        train_FG = data.D4_FG ;
        train_BG = data.D4_BG ;
    end


    % load alphas
    alphas = load("../data/Alpha.mat") ;
    alphas = alphas.alpha ;


    % calculate ML error rate
    [ml_error_rate, p_mask] = ML(train_FG, train_BG) ;
    imwrite(p_mask, sprintf("generated_images/ml_D%d_S%d.png", d, s)); %save image
    fprintf("\n---------- Maximum Likelihood Finished (Error = %.6f) ----------\n", ml_error_rate) ;
    fprintf("\n\n");
    
    
    number_of_alphas = numel(alphas) ;
    
    ml_errors = zeros(1, number_of_alphas);
    pd_errors = zeros(1, number_of_alphas);
    map_errors = zeros(1, number_of_alphas);
    
    for i = 1 : number_of_alphas
        
        alpha = alphas(1, i);
        cov_prior = diag(alpha * wi) ;
    
        [pd_error_rate, p_mask] = PD(train_FG, train_BG, mu0_FG, mu0_BG, cov_prior, cov_prior) ;
        imwrite(p_mask, sprintf("generated_images/pd_D%d_S%d_alpha_%f.png", d, s, alpha)); %save image

        [map_error_rate, p_mask] = MAP(train_FG, train_BG, mu0_FG, mu0_BG, cov_prior, cov_prior) ;
        imwrite(p_mask, sprintf("generated_images/map_D%d_S%d_alpha_%f.png", d, s, alpha)); %save image

        ml_errors(1, i) = ml_error_rate;
        pd_errors(1, i) = pd_error_rate;
        map_errors(1, i) = map_error_rate;

        fprintf("---------- Predictive Distribution Finished (Error = %.6f) ----------\n", pd_error_rate) ;
        fprintf("---------- MAP Finished (Error = %.6f) ----------\n", map_error_rate) ;
        fprintf("---------- alpha %d out of %d Finished ----------\n", i, number_of_alphas) ;
        fprintf("\n\n");
    
    end

    temp.ml_errors = ml_errors;
    temp.pd_errors = pd_errors;
    temp.map_errors = map_errors;

    record = temp ;
end