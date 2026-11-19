---
name: wonderlab-frontend-design
description: Wonderlab UI/UX standards ('Clean Paper & Lab Editorial', math typography, anti-AI slop, and 1200x630 OG cards).
---

# Wonderlab Frontend Design ("Clean Paper & Lab Editorial")

Applies to `services/wonderlab/client/`.

## 1. Palette & Surface Tokens

- **Canvas**: `#f1f5f9` (`bg-slate-100`) with subtle coordinate dot/line grid (`rgba(148,163,184,0.22)`).
- **Cards**: Crisp white `#ffffff`, hairline technical borders (`border-slate-300/85`), soft layered shadows (`shadow-sm`, hover `hover:border-slate-400/80 hover:shadow-md`), radius `rounded-md`/`lg`/`xl` (max 2 nested bordered boxes).
- **Text**: Primary `#0f172a` (`slate-900`), Body `#334155` (`slate-700`), Muted `#64748b` (`slate-500`).
- **Domain Accents**:
  - **Physics / Quantum**: Cobalt Blue `#2563eb` (`bg: #eff6ff, border: #bfdbfe, text: #1d4ed8`)
  - **Probability & Stats**: Warm Amber `#d97706` (`bg: #fef3c7, border: #fde68a, text: #b45309`)
  - **Game Theory / Logic**: Emerald `#059669` (`bg: #ecfdf5, border: #a7f3d0, text: #047857`)
  - **Paradox & Philosophy**: Deep Violet `#7c3aed` (`bg: #f5f3ff, border: #ddd6fe, text: #6d28d9`)

## 2. Typography & Mathematical Expressions

- **Fonts**: `Space Grotesk` (headings; `h2` fixed at `text-[18px] font-bold`), `Be Vietnam Pro` (body `leading-relaxed max-w-prose`), `JetBrains Mono` (`font-mono tabular-nums` for counters/metrics).
- **Min Font Size**: `>= 12px` (`text-xs`). Never use `text-[11px]` or smaller.
- **Math Formatting**: Never render raw ASCII math with variables (`n/3`, `x^2`, `sqrt`, `sum`). Use `<MathFraction>`, `<sup>`/`<MathPower>`, `&radic;`/`<MathSqrt>`, `<sub>`/`<MathSub>`, or LaTeX `\frac{}{}`. Single exception: constant numeric ratios (`2/3`, `1/3`, `50/50`).

## 3. Anti-AI Slop & Layout Guardrails

- **Bans**: No purple-to-pink gradients on buttons/text; no stacked dark glassmorphism; no 3-equal-card SaaS marketing grids; no SaaS buzzwords; no fake metrics, localhost endpoints, or tech-stack boasting in public UI.
- **Layout & Affordance**: Use asymmetric Bento / split-pane layouts (simulation canvas left, live telemetry & controls right). Buttons use `active:scale-[0.98] transition-all duration-150` and `focus-visible:ring-2 focus-visible:ring-blue-600`.
- **Simulation Integrity**: Execute real random trials and mathematical equations in code — never hardcode fake convergence curves.

## 4. Dynamic Open Graph (`opengraph-image.tsx`, `1200x630`)

- Satori flexbox layout (`display: 'flex'`, no CSS grid) with `#f1f5f9` grid outer canvas and `#ffffff` inner plate (`borderRadius: 16px`, `1px solid rgba(203,213,225,0.9)`).
- Load local `BeVietnamPro-Bold.ttf` & `BeVietnamPro-Regular.ttf` from `client/src/assets/fonts/` via `fs.readFile` for full Vietnamese diacritics.
- Include domain semantic badge, `~N PHÚT TRẢI NGHIỆM`, `LAB #SLUG`, Wonderlab flask footer (`"PHÒNG THÍ NGHIỆM TRỰC QUAN"`), and `#10b981` `"INTERACTIVE SCIENCE SIMULATION"` stamp.
