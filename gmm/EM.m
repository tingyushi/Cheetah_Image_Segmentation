function [mus, sigmas, pis] = EM(X, C, max_iter, print_every)
%EM Summary of this function goes here
%   Detailed explanation goes here

%   ========== Input Parameters ==========
%   X: data
%   C: number of mixtures
%   max_iter: max number of iterations for EM

%   ========== Output Parameters ==========
%   mus: in the shape of C x 64
%   sigmas: in the sampe of C x 64 (only record diagonal values)
%   pis: in the shape of C x 1



% init parameters
[~ , num_dim] = size(X);
[mus, sigmas, pis] = INITPARAM(X, C, num_dim);

for iter_counter=1:max_iter
    
    % E step
    [h] = E_STEP(X, mus, sigmas, pis);

    % M step
    [mus, sigmas, pis] = M_STEP(X, h);

    % print results every iteration
    if mod(iter_counter, print_every) == 0
        fprintf("Iter %d\n", iter_counter);
    end

end


end



function [h] = E_STEP(X, mus, sigmas, pis)
%E_STEP of EM

[N, ~] = size(X);
[C, ~] = size(mus);

h = zeros(N, C);

for i=1:C
    mu = mus(i, :);
    sigma = diag( sigmas(i, :) );
    pi = pis(i);
    h(:, i)  = multivariateGaussianPDF(X, mu, sigma) * pi;
end

h = h ./ sum(h, 2);

end



function [new_mus, new_sigmas, new_pis] = M_STEP(X, h)
%M_STEP of EM

[~, C] = size(h);
[~, num_dim] = size(X);

new_pis = mean(h, 1);
new_pis = new_pis(:);
new_mus = zeros(C, num_dim);
new_sigmas = zeros(C, num_dim);

for j=1:C
    new_mus(j, :) = sum( h(:, j) .* X , 1) / sum(h(:, j));
    diff = X - new_mus(j, :);
    sigma_temp = sum( h(:, j) .* (diff .* diff) , 1) / sum(h(:, j));
    sigma_temp = max(sigma_temp, 1e-4) ; % ensure non-singular matrix
    new_sigmas(j, :) = sigma_temp;
end

end




function [mus, sigmas, pis] = INITPARAM(X, C, num_dim)

pis = rand(C, 1);
pis = pis / sum(pis);
mus = 0.5 * rand(C, num_dim) + mean(X, 1);
sigmas = rand(C, num_dim);
sigmas = max(sigmas, 1e-4);

end