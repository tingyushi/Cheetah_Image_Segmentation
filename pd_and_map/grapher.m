% load alphas
alphas = load("../data/Alpha.mat") ;
alphas = alphas.alpha ;


d = 4;
s = 2;

record = load(sprintf("records/D%d_S%d.mat", d, s)).record;

figure; 
plot(alphas, record.ml_errors, 'r-', 'LineWidth', 1); 
hold on;
plot(alphas, record.map_errors, 'g-', 'LineWidth', 1);
hold on;
plot(alphas, record.pd_errors, 'b-', 'LineWidth', 1); 

set(gca, 'XScale', 'log');

xlabel('Alpha');
ylabel('Error Rate');
title(sprintf("Dataset %d Strategy %d", d, s));


legend({'ML', 'MAP', 'Predictive'}, 'Location', 'northeast');

grid on;

hold off;

print(gcf, sprintf("generated_images/D%d_S%d", d, s), '-dpng','-r300');