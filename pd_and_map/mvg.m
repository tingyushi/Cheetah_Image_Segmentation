function p = mvg(x, mu, Sigma)
    d = numel(mu);
    normalize_term = 1 / sqrt( ((2*pi)^d) * det(Sigma) );
    expo = (-1/2) * (x(:)' - mu(:)') * (Sigma^-1) * (x(:) - mu(:));
    p = normalize_term * exp(expo);
end