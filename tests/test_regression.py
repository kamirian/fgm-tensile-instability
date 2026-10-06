"""Regression test: the Python model against reference outputs and the paper.

    python tests/test_regression.py

tests/reference/*.csv hold the full output of the original 2022 MATLAB implementation
(one file per case).
"""

import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python"))
from fgm_tensile import run_case  # noqa: E402

COLUMNS = ["time", "force", "true_stress", "eng_stress", "true_strain", "eng_strain",
           "displacement", "radius"]

# Values the paper reports for the simulation, to the precision printed there.
PAPER = {
    "A_550C": {"eng_strain": (0.11, 0.005), "uts": (687, 0.5), "true_strain": (0.11, 0.005),
               "true_stress": (764, 0.5)},
    "B_650C": {"eng_strain": (0.18, 0.005), "uts": (656, 0.5), "true_strain": (0.16, 0.005),
               "true_stress": (772, 0.5)},
}


def main():
    ok = True
    for case in ("homogeneous", "A_550C", "B_650C"):
        ref = np.genfromtxt(ROOT / "tests" / "reference" / f"{case}.csv", delimiter=",", names=True)
        res = run_case(case)
        worst = max(np.max(np.abs(getattr(res, c) - ref[c]) / np.maximum(np.abs(ref[c]), 1e-300))
                    for c in COLUMNS)
        good = worst < 1e-10
        ok &= good
        print(f"{case:12s} matches reference output: {'yes' if good else 'NO'} "
              f"(largest relative difference {worst:.1e})")
        for key, (value, tol) in PAPER.get(case, {}).items():
            got = res.instability()[key]
            good = abs(got - value) <= tol
            ok &= good
            print(f"{'':12s} {key:12s} {got:9.4f}  paper {value}  {'ok' if good else 'MISMATCH'}")
    print("\nAll checks passed." if ok else "\nSome checks FAILED.")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
