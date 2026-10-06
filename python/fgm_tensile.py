"""Simulated tensile test of a round bar whose Hollomon parameters vary with radius.

Implements the force integral of Amirian, Abbasi and Ebrahimi (2023), Eq. (6), with each
ring keeping the K and n of the radius it had before the test:

    F(t) = integral from r_min to R(t) of  K(rho) * eps(t)**n(rho) * 2*pi*r dr

    eps(t) = ln(1 + rate*t)            true strain (uniform deformation)
    R(t)   = R0 / sqrt(1 + rate*t)     current radius (volume constancy)
    rho    = r * R0 / R(t)             radius of the same material point before the test

Each ring of material keeps its own K and n while the bar thins. The integral is
evaluated with composite Simpson's rule.
The instability point (onset of necking) is the maximum of the force.
"""

from dataclasses import dataclass

import numpy as np


def simpson(f, a, b, m):
    """Composite Simpson's rule on [a, b] with 2*m sub-intervals."""
    h = (b - a) / (2 * m)
    k = np.arange(1, m + 1)
    s1 = np.sum(f(a + h * (2 * k - 1)))
    s2 = np.sum(f(a + h * 2 * k[:-1]))
    return h * (f(a) + f(b) + 4 * s1 + 2 * s2) / 3


@dataclass
class TensileResult:
    time: np.ndarray            # s
    displacement: np.ndarray    # mm
    force: np.ndarray           # N
    eng_strain: np.ndarray      # -
    eng_stress: np.ndarray      # MPa
    true_strain: np.ndarray     # -
    true_stress: np.ndarray     # MPa
    radius: np.ndarray          # mm

    def instability(self):
        """Values at maximum force: the instability (necking) point."""
        i = int(np.argmax(self.force))
        return {
            "time": self.time[i],
            "eng_strain": self.eng_strain[i],
            "uts": self.eng_stress[i],
            "true_strain": self.true_strain[i],
            "true_stress": self.true_stress[i],
        }


def tensile_test(K, n, *, R0=5.0, v=0.2, L0=100.0, rate=None, dt=0.5, t_end=400.0,
                 r_min=0.0, panels_per_step=10):
    """Run the simulated tensile test.

    K, n            functions of the undeformed radius rho in mm (K in MPa); must accept arrays
    R0              initial radius of the bar, mm
    v, L0           crosshead speed (mm/s) and gauge length (mm); give engineering strain v*t/L0
    rate            strain rate used for eps(t) and R(t), 1/s; defaults to v/L0
    dt, t_end       time step and end time, s; the steps are t = dt, 2*dt, ..., t_end
    r_min           lower limit of the force integral, mm (0 in Eq. 6)
    panels_per_step Simpson uses 2*m sub-intervals with m = panels_per_step * step number,
                    the rule used for the paper
    """
    if rate is None:
        rate = v / L0
    steps = np.arange(1, int(round(t_end / dt)) + 1)
    t = steps * dt
    force = np.empty_like(t)
    radius = np.empty_like(t)
    for i, (k, ti) in enumerate(zip(steps, t)):
        R = R0 / np.sqrt(1 + rate * ti)
        eps = np.log(1 + rate * ti)

        def integrand(r):
            rho = r * R0 / R
            return K(rho) * eps ** n(rho) * 2 * np.pi * r

        force[i] = simpson(integrand, r_min, R, panels_per_step * k)
        radius[i] = R
    return TensileResult(
        time=t,
        displacement=v * t,
        force=force,
        eng_strain=v * t / L0,
        eng_stress=force / (np.pi * R0 ** 2),
        true_strain=np.log(1 + rate * t),
        true_stress=force / (np.pi * radius ** 2),
        radius=radius,
    )


# The three cases in the paper, with the coefficients used to make its figures.
# The paper prints the n(r) and K(r) fits rounded (Eqs. 8 to 11).
CASES = {
    "homogeneous": dict(
        label="Homogeneous check, n = 0.3, K = 100 MPa (Figs. 1 to 3)",
        K=lambda rho: 100.0 + 0 * rho,
        n=lambda rho: 0.3 + 0 * rho,
        v=0.2, L0=100.0, rate=0.002, t_end=400.0, r_min=0.0,
    ),
    "A_550C": dict(
        label="Sample A, annealed at 550 °C (Fig. 6)",
        K=lambda rho: 6.67 * rho + 962.023,
        n=lambda rho: 0.1796 - 0.021 * rho,
        v=0.025, L0=70.0, rate=0.000357, t_end=800.0, r_min=0.5,
    ),
    "B_650C": dict(
        label="Sample B, annealed at 650 °C (Fig. 7)",
        K=lambda rho: 3.13 * rho + 1042.7868,
        n=lambda rho: 0.2015 - 0.0108 * rho,
        v=0.025, L0=70.0, rate=0.000357, t_end=800.0, r_min=0.5,
    ),
}


def run_case(name):
    c = {k: v for k, v in CASES[name].items() if k != "label"}
    return tensile_test(**c)
