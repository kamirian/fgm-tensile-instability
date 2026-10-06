function out = fgm_tensile(K, n, opts)
%FGM_TENSILE Simulated tensile test of a round bar whose Hollomon K and n vary with radius.
%
%   out = fgm_tensile(K, n, opts) evaluates the force integral of Amirian, Abbasi and
%   Ebrahimi (2023), Eq. (6), with each ring keeping the K and n of the radius it had
%   before the test:
%
%       F(t) = integral from r_min to R(t) of K(rho) * eps(t)^n(rho) * 2*pi*r dr
%       eps(t) = ln(1 + rate*t),  R(t) = R0 / sqrt(1 + rate*t),  rho = r*R0/R(t)
%
%   rho is the radius a material point had before the test, so each ring keeps its own
%   K and n while the bar thins. The integral uses composite Simpson's rule. The
%   instability (necking) point is the maximum force.
%
%   K, n    function handles of the undeformed radius rho in mm (K in MPa); must accept vectors
%   opts    struct with any of these fields (defaults in brackets):
%             R0               initial radius, mm [5]
%             v, L0            crosshead speed mm/s [0.2] and gauge length mm [100]
%             rate             strain rate for eps(t) and R(t), 1/s [v/L0]
%             dt, t_end        time step and end time, s [0.5, 400]
%             r_min            lower limit of the force integral, mm [0]
%             panels_per_step  Simpson uses 2*m sub-intervals, m = panels_per_step * step [10]
%
%   out     struct with time, displacement, force, eng_strain, eng_stress, true_strain,
%           true_stress, radius (row vectors) and instability (values at maximum force).

if nargin < 3
    opts = struct();
end
defaults = struct('R0', 5, 'v', 0.2, 'L0', 100, 'rate', [], 'dt', 0.5, 't_end', 400, ...
                  'r_min', 0, 'panels_per_step', 10);
names = fieldnames(defaults);
for i = 1:numel(names)
    if ~isfield(opts, names{i})
        opts.(names{i}) = defaults.(names{i});
    end
end
if isempty(opts.rate)
    opts.rate = opts.v / opts.L0;
end

steps = 1:round(opts.t_end / opts.dt);
t = steps * opts.dt;
force = zeros(size(t));
radius = zeros(size(t));
for i = steps
    R = opts.R0 / sqrt(1 + opts.rate * t(i));
    eps = log(1 + opts.rate * t(i));
    integrand = @(r) K(r * opts.R0 / R) .* eps .^ n(r * opts.R0 / R) .* 2 .* pi .* r;
    force(i) = simpson(integrand, opts.r_min, R, opts.panels_per_step * i);
    radius(i) = R;
end

out.time = t;
out.displacement = opts.v * t;
out.force = force;
out.eng_strain = opts.v * t / opts.L0;
out.eng_stress = force / (pi * opts.R0^2);
out.true_strain = log(1 + opts.rate * t);
out.true_stress = force ./ (pi * radius.^2);
out.radius = radius;

[~, k] = max(force);
out.instability = struct('time', t(k), 'eng_strain', out.eng_strain(k), ...
    'uts', out.eng_stress(k), 'true_strain', out.true_strain(k), ...
    'true_stress', out.true_stress(k));
end

function s = simpson(f, a, b, m)
% Composite Simpson's rule on [a, b] with 2*m sub-intervals.
h = (b - a) / (2 * m);
k = 1:m;
s1 = sum(f(a + h * (2 * k - 1)));
s2 = sum(f(a + h * 2 * k(1:end-1)));
s = h * (f(a) + f(b) + 4 * s1 + 2 * s2) / 3;
end
