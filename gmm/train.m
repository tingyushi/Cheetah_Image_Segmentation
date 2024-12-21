clear;

data = load('../data/TrainingSamplesDCT_8_new.mat');

fg_data = data.TrainsampleDCT_FG;
bg_data = data.TrainsampleDCT_BG;

%% Problem (a) 
[~, num_dim] = size(fg_data);
max_iter = 500;
rng(1);
print_every = 100;
C = 8;
for i=1:5

    % train bg data    
    fprintf("Training BG Mixture %d -- C = %d\n", i, C);
    [mus, sigmas, pis] = EM(bg_data, C, max_iter, print_every);
    assert(isequal(size(mus) , [C, num_dim]) , 'mus has wrong shape');
    assert(isequal(size(sigmas) , [C, num_dim]) , 'sigmas has wrong shape');
    assert(isequal(size(pis) , [C, 1]) , 'pis has wrong shape');
    assert(abs(sum(pis) - 1) <= 1e-6);
    fprintf("\n");

    % save records
    temp.mus = mus;
    temp.sigmas = sigmas;
    temp.pis = pis;
    record = temp;
    save(sprintf("records/a_bg_mixture_%d_C_%d.mat", i, C), "record");


    % train fg data
    fprintf("Training FG Mixture %d -- C = %d\n", i, C);
    [mus, sigmas, pis] = EM(fg_data, C, max_iter, print_every);
    assert(isequal(size(mus) , [C, num_dim]) , 'mus has wrong shape');
    assert(isequal(size(sigmas) , [C, num_dim]) , 'sigmas has wrong shape');
    assert(isequal(size(pis) , [C, 1]) , 'pis has wrong shape');
    assert(abs(sum(pis) - 1) <= 1e-6);
    fprintf("\n");

    % save records
    temp.mus = mus;
    temp.sigmas = sigmas;
    temp.pis = pis;
    record = temp;
    save(sprintf("records/a_fg_mixture_%d_C_%d.mat", i, C), "record");

end





%% Problem (b)
[~, num_dim] = size(fg_data);
max_iter = 500;
print_every = 100;
Cs = [1 2 4 8 16 32];

for i=1:numel(Cs)
    C = Cs(i);
    rng(2);

    % train BG data
    fprintf("Training BG Mixture -- C = %d\n", C);
    [mus, sigmas, pis] = EM(bg_data, C, max_iter, print_every);
    assert(isequal(size(mus) , [C, num_dim]) , 'mus has wrong shape');
    assert(isequal(size(sigmas) , [C, num_dim]) , 'sigmas has wrong shape');
    assert(isequal(size(pis) , [C, 1]) , 'pis has wrong shape');
    assert(abs(sum(pis) - 1) <= 1e-6);
    fprintf("\n");

    % save records
    temp.mus = mus;
    temp.sigmas = sigmas;
    temp.pis = pis;
    record = temp;
    save(sprintf("records/b_bg_C_%d.mat", C), "record");

    % train FG data
    fprintf("Training FG Mixture -- C = %d\n", C);
    [mus, sigmas, pis] = EM(fg_data, C, max_iter, print_every);
    assert(isequal(size(mus) , [C, num_dim]) , 'mus has wrong shape');
    assert(isequal(size(sigmas) , [C, num_dim]) , 'sigmas has wrong shape');
    assert(isequal(size(pis) , [C, 1]) , 'pis has wrong shape');
    assert(abs(sum(pis) - 1) <= 1e-6);
    fprintf("\n");

    % save records
    temp.mus = mus;
    temp.sigmas = sigmas;
    temp.pis = pis;
    record = temp;
    save(sprintf("records/b_fg_C_%d.mat", C), "record");
end