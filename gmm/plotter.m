%% Problem (a)
mixtures = [1 2 3 4 5];
dim_ranges = [1 2 4 8 16 24 32 40 48 64];
errorMap = load("records/a_errorMap.mat");
errorMap = errorMap.errorMap;
legendLabels = {'BG Mixture 1', 'BG Mixture 2', ...
    'BG Mixture 3', 'BG Mixture 4', 'BG Mixture 5'};

for fg_mix_idx = mixtures

figure(1);
hold on;
for bg_mix_idx = mixtures
    error_rates = errorMap(sprintf("fg_%d_bg_%d", fg_mix_idx, bg_mix_idx));
    plot(dim_ranges, error_rates, 'LineWidth', 1)
end

hold off;

xlabel('Number of Dimension');
ylabel('Error Rate');
title(sprintf("FG Mixture %d", fg_mix_idx));
legend(legendLabels, 'Location', 'Best');
grid on;
print(gcf, sprintf("images/a_fg_%d", fg_mix_idx), '-dpng','-r300');
close(gcf);

end



%% Problem (b)
dim_ranges = [1 2 4 8 16 24 32 40 48 64];
Cs = [1 2 4 8 16 32];
errorMap = load("records/b_errorMap.mat");
errorMap = errorMap.errorMap;
legendLabels = {'C = 1', 'C = 2', 'C = 4', 'C = 8', 'C = 16', 'C = 32'};


figure(1);
hold on;
for C = Cs
    error_rates = errorMap(sprintf("fg_bg_C_%d", C));
    plot(dim_ranges, error_rates, 'LineWidth', 1)
end

hold off;

xlabel('Number of Dimension');
ylabel('Error Rate');
title("Performance with Different Number of Mixture Components");
legend(legendLabels, 'Location', 'Best');
grid on;
print(gcf, sprintf("images/b"), '-dpng','-r300');
close(gcf);