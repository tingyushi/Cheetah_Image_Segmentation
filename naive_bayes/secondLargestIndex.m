function output = secondLargestIndex(input)
    %SECONDLARGESTINDEX Summary of this function goes here
    %   Detailed explanation goes here
    [N, ~] = size(input) ; 
    indices = zeros(N, 1) ;
    for i = 1:N
        row = input(i, :);
        [~, sorted_indices] = sort(row, 'descend');
        indices(i) = sorted_indices(2);
    end
    output = indices ;
end