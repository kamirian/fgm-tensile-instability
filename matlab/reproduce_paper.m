%REPRODUCE_PAPER Reproduce the numerical results and figures of the paper.
%   Prints the instability point of each case next to the values reported in the
%   paper and writes the figures to figures/.

root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'matlab'));

cases = paper_cases();
paper = struct( ...
    'homogeneous', [NaN NaN 0.29 NaN], ...
    'A_550C',      [0.11 687 0.11 764], ...
    'B_650C',      [0.18 656 0.16 772]);

fprintf('%-12s %-10s %12s %12s %12s %18s\n', 'case', '', 'eng. strain', 'UTS (MPa)', ...
        'true strain', 'true stress (MPa)');
results = struct();
for c = 1:numel(cases)
    out = fgm_tensile(cases(c).K, cases(c).n, cases(c).opts);
    results.(cases(c).name) = out;
    s = out.instability;
    p = paper.(cases(c).name);
    fprintf('%-12s %-10s %12.3f %12.1f %12.3f %18.1f\n', cases(c).name, 'this code', ...
            s.eng_strain, s.uts, s.true_strain, s.true_stress);
    fprintf('%-12s %-10s %12g %12g %12g %18g\n', '', 'paper', p(1), p(2), p(3), p(4));
end

figdir = fullfile(root, 'figures');
if ~exist(figdir, 'dir')
    mkdir(figdir);
end
numerical = [42 120 214] / 255;
experiment = [235 104 52] / 255;

% Figs. 1 to 3: homogeneous bar, n = 0.3 and K = 100 MPa
h = results.homogeneous;
f = figure('Visible', 'off', 'Position', [100 100 1300 380]);
subplot(1, 3, 1); plot(h.displacement, h.force, 'Color', numerical, 'LineWidth', 2);
xlabel('Displacement (mm)'); ylabel('Force (N)'); grid on;
subplot(1, 3, 2); plot(h.eng_strain, h.eng_stress, 'Color', numerical, 'LineWidth', 2);
xlabel('Engineering strain'); ylabel('Engineering stress (MPa)'); grid on;
subplot(1, 3, 3); plot(h.true_strain, h.true_stress, 'Color', numerical, 'LineWidth', 2);
xlabel('True strain'); ylabel('True stress (MPa)'); grid on;
print(f, fullfile(figdir, 'homogeneous_check_matlab.png'), '-dpng', '-r150');
close(f);

% Figs. 6 and 7: samples A and B against the experimental curves of Wang et al. (2019)
fid = fopen(fullfile(root, 'data', 'wang2019_stress_strain.csv'));
raw = textscan(fid, '%s %f %f', 'Delimiter', ',', 'HeaderLines', 1);
fclose(fid);
f = figure('Visible', 'off', 'Position', [100 100 1100 420]);
names = {'A_550C', 'B_650C'};
titles = {'Sample A, annealed at 550 ^{\circ}C', 'Sample B, annealed at 650 ^{\circ}C'};
for k = 1:2
    subplot(1, 2, k); hold on;
    rows = strcmp(raw{1}, names{k});
    plot(raw{2}(rows), raw{3}(rows), '--', 'Color', experiment, 'LineWidth', 2);
    out = results.(names{k});
    plot(out.eng_strain, out.eng_stress, 'Color', numerical, 'LineWidth', 2);
    s = out.instability;
    plot(s.eng_strain, s.uts, 'o', 'MarkerFaceColor', numerical, 'MarkerEdgeColor', 'w', ...
         'MarkerSize', 8);
    xlim([0 0.3]); ylim([0 800]); grid on;
    xlabel('Engineering strain'); ylabel('Engineering stress (MPa)');
    title(titles{k});
    legend({'Experiment (Wang et al., 2019)', 'This model', 'Instability'}, 'Location', 'southeast');
end
print(f, fullfile(figdir, 'samples_vs_experiment_matlab.png'), '-dpng', '-r150');
close(f);
fprintf('\nFigures written to %s\n', figdir);
