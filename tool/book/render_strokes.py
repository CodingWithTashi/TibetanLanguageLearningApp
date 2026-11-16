#!/usr/bin/env python3
"""Render numbered stroke-order diagrams from book/strokes/letters.json.

Usage: python3 -I tool/book/render_strokes.py [out_dir]
Writes <name>.svg and (if rsvg-convert exists) <name>.png (1200x1200, transparent).
Strokes are drawn as a grey skeleton, then each stroke in colour with an
arrowhead at its end and a numbered dot at its start.
"""
import json, math, os, shutil, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
SRC = os.path.join(ROOT, "book", "strokes", "letters.json")
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "book", "strokes", "out")
COLOURS = ["#E8505B", "#4A90E2", "#6BBF59", "#F2A63D", "#8E6BD1", "#3FB8AF"]
SIZE = 1200
PAD = 190


def smooth_path(pts):
    """Catmull-Rom through points -> cubic bezier path string."""
    if len(pts) == 2:
        (x0, y0), (x1, y1) = pts
        return f"M{x0:.1f},{y0:.1f} L{x1:.1f},{y1:.1f}"
    d = f"M{pts[0][0]:.1f},{pts[0][1]:.1f}"
    for i in range(len(pts) - 1):
        p0 = pts[i - 1] if i > 0 else pts[i]
        p1, p2 = pts[i], pts[i + 1]
        p3 = pts[i + 2] if i + 2 < len(pts) else pts[i + 1]
        c1 = (p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6)
        c2 = (p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6)
        d += f" C{c1[0]:.1f},{c1[1]:.1f} {c2[0]:.1f},{c2[1]:.1f} {p2[0]:.1f},{p2[1]:.1f}"
    return d


def build_svg(strokes):
    allp = [(p["x"], p["y"]) for s in strokes for p in s["points"]]
    minx, maxx = min(x for x, _ in allp), max(x for x, _ in allp)
    miny, maxy = min(y for _, y in allp), max(y for _, y in allp)
    scale = (SIZE - 2 * PAD) / max(maxx - minx, maxy - miny, 1e-6)
    offx = (SIZE - (maxx - minx) * scale) / 2
    offy = (SIZE - (maxy - miny) * scale) / 2
    def tx(p):
        return ((p["x"] - minx) * scale + offx, (p["y"] - miny) * scale + offy)
    parts = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{SIZE}" height="{SIZE}" viewBox="0 0 {SIZE} {SIZE}">']
    paths = [[tx(p) for p in s["points"]] for s in strokes]
    for pts in paths:  # grey skeleton
        parts.append(f'<path d="{smooth_path(pts)}" fill="none" stroke="#D9D9D9" stroke-width="44" stroke-linecap="round" stroke-linejoin="round"/>')
    for i, pts in enumerate(paths):
        col = COLOURS[i % len(COLOURS)]
        parts.append(f'<path d="{smooth_path(pts)}" fill="none" stroke="{col}" stroke-width="14" stroke-linecap="round" stroke-linejoin="round"/>')
        (xa, ya), (xb, yb) = pts[-2], pts[-1]
        ang = math.atan2(yb - ya, xb - xa)
        hs = 46
        tip = (xb + math.cos(ang) * 14, yb + math.sin(ang) * 14)
        l = (tip[0] - hs * math.cos(ang - 0.5), tip[1] - hs * math.sin(ang - 0.5))
        r = (tip[0] - hs * math.cos(ang + 0.5), tip[1] - hs * math.sin(ang + 0.5))
        parts.append(f'<polygon points="{tip[0]:.1f},{tip[1]:.1f} {l[0]:.1f},{l[1]:.1f} {r[0]:.1f},{r[1]:.1f}" fill="{col}"/>')
    for i, pts in enumerate(paths):  # numbered start dots on top
        col = COLOURS[i % len(COLOURS)]
        x, y = pts[0]
        parts.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="27" fill="{col}" stroke="#FFFFFF" stroke-width="6"/>')
        parts.append(f'<text x="{x:.1f}" y="{y + 13:.1f}" font-family="Helvetica, Arial, sans-serif" font-weight="700" font-size="36" fill="#FFFFFF" text-anchor="middle">{i + 1}</text>')
    parts.append("</svg>")
    return "\n".join(parts)


def main():
    os.makedirs(OUT, exist_ok=True)
    data = json.load(open(SRC, encoding="utf-8"))["letters"]
    rsvg = shutil.which("rsvg-convert")
    for ch, info in data.items():
        name = info["name"].lower()
        svg_path = os.path.join(OUT, f"stroke_{name}.svg")
        open(svg_path, "w", encoding="utf-8").write(build_svg(info["strokes"]))
        if rsvg:
            subprocess.run([rsvg, "-w", str(SIZE), "-h", str(SIZE), svg_path, "-o", svg_path[:-4] + ".png"], check=True)
        print("wrote", name, len(info["strokes"]), "strokes")


if __name__ == "__main__":
    main()
