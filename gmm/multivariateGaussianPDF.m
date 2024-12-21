function pdf = multivariateGaussianPDF(X, meanVec, covMatrix) 
    
    % meanVec: row vector
    % pdf: column  vector

    [~, C] = size(X);
    
    covDet = det(covMatrix);
    covInv = inv(covMatrix);
    
    normFactor = 1 / sqrt((2 * pi) ^ C * covDet);
    
    diff = X - meanVec; % Shape: (N, C)
    exponent = -0.5 * sum((diff * covInv) .* diff, 2);
    
    pdf = normFactor * exp(exponent);
end
