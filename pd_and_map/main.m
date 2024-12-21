clear ; 

datasetids = [1 2 3 4];
strategyids = [1 2];


for i = 1:numel(datasetids)
for j = 1:numel(strategyids)

    
    d = datasetids(1, i);
    s = strategyids(1, j);
    
    fprintf("\n========== Starting Dataset %d Strategy %d ==========\n", d, s);
    
    record = DRIVER(d, s);
    save(sprintf("records/D%d_S%d.mat", d, s), "record");

    fprintf("\n========== Finished Dataset %d Strategy %d ==========\n", d, s);

end
end