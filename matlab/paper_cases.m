function cases = paper_cases()
%PAPER_CASES The three cases in the paper, with the coefficients used to make its figures.
%   The paper prints the n(r) and K(r) fits rounded (Eqs. 8 to 11).

cases = struct('name', {}, 'label', {}, 'K', {}, 'n', {}, 'opts', {});

cases(1).name = 'homogeneous';
cases(1).label = 'Homogeneous check, n = 0.3, K = 100 MPa (Figs. 1 to 3)';
cases(1).K = @(rho) 100 + 0 * rho;
cases(1).n = @(rho) 0.3 + 0 * rho;
cases(1).opts = struct('v', 0.2, 'L0', 100, 'rate', 0.002, 't_end', 400, 'r_min', 0);

cases(2).name = 'A_550C';
cases(2).label = 'Sample A, annealed at 550 C (Fig. 6)';
cases(2).K = @(rho) 6.67 * rho + 962.023;
cases(2).n = @(rho) 0.1796 - 0.021 * rho;
cases(2).opts = struct('v', 0.025, 'L0', 70, 'rate', 0.000357, 't_end', 800, 'r_min', 0.5);

cases(3).name = 'B_650C';
cases(3).label = 'Sample B, annealed at 650 C (Fig. 7)';
cases(3).K = @(rho) 3.13 * rho + 1042.7868;
cases(3).n = @(rho) 0.2015 - 0.0108 * rho;
cases(3).opts = struct('v', 0.025, 'L0', 70, 'rate', 0.000357, 't_end', 800, 'r_min', 0.5);
end
