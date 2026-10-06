"""Reproduce the numerical results and figures of the paper.

    python python/reproduce_paper.py

Prints the instability point of each case next to the values reported in the paper
and writes the figures to figures/.
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

from fgm_tensile import CASES, run_case

ROOT = Path(__file__).resolve().parents[1]
FIG = ROOT / "figures"
NUMERICAL, EXPERIMENT = "#2a78d6", "#eb6834"
SAMPLE_COLORS = {"A_550C": "#4a3aa7", "B_650C": "#1baf7a"}

# Reference values: Considere's criterion for the homogeneous bar (true strain = n), and the
# "Numerical" rows of Tables 3 and 4 of the paper for samples A and B.
PAPER = {
    "homogeneous": {"true_strain": 0.3},
    "A_550C": {"eng_strain": 0.11, "uts": 687, "true_strain": 0.11, "true_stress": 764},
    "B_650C": {"eng_strain": 0.18, "uts": 656, "true_strain": 0.16, "true_stress": 772},
}
COLUMNS = [("eng_strain", "eng. strain", "{:.3f}"), ("uts", "UTS (MPa)", "{:.1f}"),
           ("true_strain", "true strain", "{:.3f}"), ("true_stress", "true stress (MPa)", "{:.1f}")]


def style(ax, xlabel, ylabel):
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.grid(True, color="#e4e4e0", linewidth=0.8)
    ax.set_axisbelow(True)
    for side in ("top", "right"):
        ax.spines[side].set_visible(False)


def mark_peak(ax, x, y, text):
    ax.plot(x, y, "o", ms=8, color=NUMERICAL, mec="white", mew=2, zorder=5)
    ax.annotate(text, (x, y), xytext=(8, 8), textcoords="offset points", fontsize=9, color="#3d3d3a")


def main():
    FIG.mkdir(exist_ok=True)
    results = {name: run_case(name) for name in CASES}

    print(f"{'case':12s}  {'':9s}" + "".join(f"{h:>19s}" for _, h, _ in COLUMNS))
    for name, res in results.items():
        got = res.instability()
        print(f"{name:12s}  {'model':9s}" + "".join(f"{f.format(got[k]):>19s}" for k, _, f in COLUMNS))
        print(f"{'':12s}  {'reference':9s}" + "".join(
            f"{(str(PAPER[name][k]) if k in PAPER[name] else '-'):>19s}" for k, _, _ in COLUMNS))

    # Figs. 1 to 3: homogeneous bar, n = 0.3 and K = 100 MPa
    h = results["homogeneous"]
    p = h.instability()
    i = int(np.argmax(h.force))
    fig, axes = plt.subplots(1, 3, figsize=(13, 3.8), constrained_layout=True)
    panels = [
        (h.displacement, h.force, "Displacement (mm)", "Force (N)"),
        (h.eng_strain, h.eng_stress, "Engineering strain", "Engineering stress (MPa)"),
        (h.true_strain, h.true_stress, "True strain", "True stress (MPa)"),
    ]
    for ax, (x, y, xl, yl) in zip(axes, panels):
        ax.plot(x, y, color=NUMERICAL, lw=2)
        style(ax, xl, yl)
        ax.set_xlim(left=0)
        ax.set_ylim(bottom=0)
    mark_peak(axes[0], h.displacement[i], h.force[i], f"max force, true strain {p['true_strain']:.3f}")
    fig.suptitle("Homogeneous check: n = 0.3, K = 100 MPa (instability expected at true strain n = 0.3)",
                 fontsize=11)
    fig.savefig(FIG / "homogeneous_check.png", dpi=200)
    plt.close(fig)

    # Figs. 6 and 7: samples A and B against the experimental curves of Wang et al. (2019)
    exp = np.genfromtxt(ROOT / "data" / "wang2019_stress_strain.csv", delimiter=",", names=True,
                        dtype=None, encoding="utf-8")
    fig, axes = plt.subplots(1, 2, figsize=(11, 4.2), constrained_layout=True, sharey=True)
    for ax, name, eqs in zip(axes, ("A_550C", "B_650C"),
                             ("n = 0.1796 - 0.021 r,  K = 6.67 r + 962.0 MPa",
                              "n = 0.2015 - 0.0108 r,  K = 3.13 r + 1042.8 MPa")):
        res = results[name]
        e = exp[exp["sample"] == name]
        ax.plot(e["eng_strain"], e["eng_stress_MPa"], color=EXPERIMENT, lw=2, ls=(0, (5, 3)),
                label="Experiment (Wang et al., 2019)")
        ax.plot(res.eng_strain, res.eng_stress, color=NUMERICAL, lw=2, label="This model")
        q = res.instability()
        mark_peak(ax, q["eng_strain"], q["uts"], f"instability: {q['eng_strain']:.3f}, {q['uts']:.0f} MPa")
        style(ax, "Engineering strain", "Engineering stress (MPa)" if name == "A_550C" else "")
        ax.set_title(f"{CASES[name]['label'].split(' (')[0]}\n{eqs}", fontsize=10)
        ax.set_xlim(0, 0.3)
        ax.set_ylim(0, 800)
        ax.legend(loc="lower right", frameon=False, fontsize=9)
    fig.savefig(FIG / "samples_vs_experiment.png", dpi=200)
    plt.close(fig)

    # Radial property profiles: n from the grain size (Qiu et al., 2012), and K(r)
    grains = np.genfromtxt(ROOT / "data" / "wang2019_grain_size.csv", delimiter=",", names=True,
                           dtype=None, encoding="utf-8")
    r = np.linspace(0, 5, 101)
    fig, axes = plt.subplots(1, 2, figsize=(11, 3.9), constrained_layout=True)
    for name in ("A_550C", "B_650C"):
        c = CASES[name]
        color = SAMPLE_COLORS[name]
        short = c["label"].split(",")[0] + " (" + c["label"].split("at ")[1].split(" (")[0] + ")"
        g = grains[grains["sample"] == name]
        n_points = 0.307 - 0.439 / np.sqrt(g["ferrite_grain_size_um"])
        axes[0].plot(5.0 * g["r_over_R"], n_points, "o", ms=4, color=color, alpha=0.45, mec="none")
        axes[0].plot(r, c["n"](r), color=color, lw=2, label=short)
        axes[1].plot(r, c["K"](r), color=color, lw=2, label=short)
    style(axes[0], "Radius r (mm)", "Strain-hardening exponent n")
    axes[0].set_title("n(r): grain size (points) and linear fit (lines)", fontsize=10)
    style(axes[1], "Radius r (mm)", "Strength coefficient K (MPa)")
    axes[1].set_title("K(r) used in the model", fontsize=10)
    for ax in axes:
        ax.set_xlim(0, 5)
    axes[0].legend(frameon=False, fontsize=9, loc="lower left")
    axes[1].legend(frameon=False, fontsize=9, loc="center right")
    fig.savefig(FIG / "property_profiles.png", dpi=200)
    plt.close(fig)
    print(f"\nFigures written to {FIG}")


if __name__ == "__main__":
    main()
