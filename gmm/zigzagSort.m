function output = zigzagSort(input)
    %ZIGZAGSORT Summary of this function goes here
    %   Detailed explanation goes here
    
    zigzag = [0   1   5   6  14  15  27  28;
        2   4   7  13  16  26  29  42;
        3   8  12  17  25  30  41  43;
        9  11  18  24  31  40  44  53;
        10  19  23  32  39  45  52  54;
        20  22  33  38  46  51  55  60;
        21  34  37  47  50  56  59  61;
        35  36  48  49  57  58  62  63] ;

    zigzag = zigzag + 1 ;

    output = zeros(1, 64);

   [N, M] = size(zigzag);

   for i = 1:N
       for j = 1:M
           output(zigzag(i, j)) = input(i, j);
       end
   end

end