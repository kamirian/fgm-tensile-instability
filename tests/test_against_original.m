%TEST_AGAINST_ORIGINAL Check matlab/fgm_tensile.m against the original 2022 scripts.
%   tests/reference/*.csv hold the full output of the original scripts in
%   original_2022/, run unchanged in GNU Octave.

root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'matlab'));
cases = paper_cases();
columns = {'time', 'force', 'true_stress', 'eng_stress', 'true_strain', 'eng_strain', ...
           'displacement', 'radius'};
ok = true;
for c = 1:numel(cases)
    out = fgm_tensile(cases(c).K, cases(c).n, cases(c).opts);
    ref = dlmread(fullfile(root, 'tests', 'reference', [cases(c).name '.csv']), ',', 1, 0);
    worst = 0;
    for j = 1:numel(columns)
        v = out.(columns{j})(:);
        worst = max(worst, max(abs(v - ref(:, j)) ./ max(abs(ref(:, j)), realmin)));
    end
    good = worst < 1e-10;
    ok = ok && good;
    fprintf('%-12s matches original script: %s (largest relative difference %.1e)\n', ...
            cases(c).name, mat2str(good), worst);
end
if ok
    fprintf('\nAll checks passed.\n');
else
    error('Some checks FAILED.');
end
