% read original image
img = imread("data/cheetah.bmp") ;
img = im2double(img);
[image_height, image_width] = size(img);

% define block size
block_height = 8;
block_width = 8;

flag = 1;

dct_coef = zeros( (image_height - block_height + 1) * ...
    ( image_width - block_width + 1 ) , ...
    block_width * block_height );


counter = 1;

for i = 1 : image_height - block_height + 1
    for j = 1 : image_width - block_width + 1

        x = img(i : i + block_height - 1 , j : j + block_width - 1);
        x = dct2(x);
        x = zigzagSort(x);
        
        dct_coef(counter, :) = x;

        counter = counter + 1;
       
    end
end

[N, ~] = size(dct_coef);

assert(N == counter - 1);

dct_features = dct_coef;

save("data/dct_features.mat", "dct_features");
