---
name: gateway-frontend-design
description: Central Gateway UI standards ('Cosmic Violet & Frosted Glass', starfield canvas, silhouettes, and glass controls).
---

# Central Gateway Frontend Design ("Cosmic Violet & Frosted Glass")

Applies to `services/central-gateway/client/`.

## 1. Palette & Surface Tokens

- **Sky Gradient**: `--sky-top: #130624` -> `--sky-mid-1: #250d42` -> `--sky-mid-2: #43146b` -> `--sky-bottom: #631f8f`.
- **Silhouettes**: Distant mountains `#220d3f`, evergreen pines `#150626` layered at viewport bottom.
- **Frosted Glass**:
  - Surface: `bg-white/[0.08]` (hover `bg-white/[0.14]`), `backdrop-blur-2xl`
  - Border: `border border-white/20` (focus `border-white/45`)
  - Ambient Glow: `shadow-[0_8px_32px_0_rgba(140,56,201,0.25)]`
- **Min Font Size**: `>= 12px` (`text-xs`).

## 2. Core UI Primitives

- **Glass Card (`<GlassCard />`)**: `rounded-3xl border border-white/20 bg-white/[0.08] p-8 shadow-[0_8px_32px_0_rgba(140,56,201,0.25)] backdrop-blur-2xl`.
- **Capsule Input (`<GlassInput />`)**: `w-full rounded-full border border-white/25 bg-white/[0.12] px-5 py-3 text-sm text-white placeholder-white/60 focus:border-white/50 focus:bg-white/[0.2] focus:outline-none focus:ring-4 focus:ring-violet-400/20`.
- **Glowing Action Button (`<GlassButton />`)**: `w-full rounded-full bg-white py-3.5 text-sm font-bold text-[#2a0e4e] shadow-[0_0_20px_rgba(255,255,255,0.4)] hover:bg-white/95 hover:shadow-[0_0_28px_rgba(255,255,255,0.6)] active:scale-[0.98]`.

## 3. Starfield & Motion Discipline

- **Canvas Starfield**: 150–200 stars with `Math.sin(tick * speed)` twinkle + subtle shooting stars every 8–15s.
- **Performance & A11y**: Store RAF handles/canvas state in `useRef`, throttle when backgrounded, and honor `prefers-reduced-motion` (static stars when enabled).
