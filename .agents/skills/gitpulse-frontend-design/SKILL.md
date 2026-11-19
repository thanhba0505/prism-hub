---
name: gitpulse-frontend-design
description: Design principles, styling tokens, and UI implementation patterns for Git Pulse (services/git-pulse). Enforces the 'Precision Developer Dark' (Tailwind Cool Slate Elevated) aesthetic, interactive architectural backdrop, WCAG AA contrast, bilingual vi/en support, and accessible native dialog controls.
---

# Git Pulse Frontend Design Standards ("Precision Developer Dark")

This skill governs all UI/UX implementation inside `services/git-pulse/client/`. Strictly preserve brand naming **`Git Pulse`** (spaced, never hyphenated as `Git-Pulse`).

---

## 1. Visual Language & Elevated Slate Palette

- **Canvas**: `#0F172A` (`slate-900`) primary backdrop, frosted header/footer chrome (`#0F172A`).
- **Surface Hierarchy (Tailwind Cool Slate Elevated)**:
  - Primary card surface (`.gp-card`): `rgba(30, 41, 59, 0.86)` / `#1E293B`
  - Modal surface (`.gp-modal-surface`): `rgba(30, 41, 59, 0.96)`
  - Glass panel (`.gp-glass-panel`): `rgba(34, 46, 66, 0.96)`
  - Elevated nested surface: `rgba(39, 53, 73, 0.84)` / `#273549`
  - Recessed input wells: `#152033`
- **Borders & Contrast**:
  - Crisp hairline borders: `#334155` / `white/[0.14]`
  - Muted secondary text minimum: `#94A3B8` (`slate-400`, WCAG AA compliant)
  - Primary monochromatic accent: `Sky-500` (`#0EA5E9`)
- **Typography & Minimum Font Size**:
  - Sans / Headings / Body: `Plus Jakarta Sans` & `Inter` (`subsets: ['latin', 'vietnamese']`)
  - Code / Git identifiers / Counters: `JetBrains Mono` with `tabular-nums`
  - **Strict Min Font Size (`>= 12px`)**: Forbid text smaller than `text-xs` (`12px`). Never use `text-[10px]` or `text-[11px]`.

---

## 2. Backdrop, Motion & Anti-Slop Rules

- **Interactive Backdrop (`InteractiveBackdrop`)**:
  - Multi-layered pointer-driven interactive architectural grid, velvet cursor halo, CSS-composited floating geometric Git tiles & motes (with independent CSS `translate` pointer parallax and spotlight-masked illumination), and transient WAAPI pointer trails & click ripples.
  - Must deactivate cleanly when the pointer leaves the viewport (`pointerout`, `pointerleave`, `blur`).
  - Paired with an accessible ambient-motion Pause/Play toggle (`useAmbientMotionPreference`) and Gateway-style initial progress `IntroScreen`.
- **Forbidden Visual Tropes**:
  - Strictly forbid continuous idle `requestAnimationFrame` starfields, scanline overlays, spinning ambient logos, radar HUDs, continuous rotating border beams, or decorative `animate-ping`/`animate-pulse` dots.
  - `Loader2` / `RefreshCw` may spin ONLY during active asynchronous operations.
  - Strictly forbid decorative status tags (`RADAR ONLINE`, `AI CORE READY`, `0 PULSES`), sci-fi terminology (_"quỹ đạo"_, _"chòm sao"_, _"radar"_, _"Warp-Drive"_, _"Sub-Light"_), or internal tech boasting (`HKDF`, `AES-256-GCM`, `Gateway SSO`, `PAT`, `v0.1`).
- **GPU-Composited Motion**:
  - Animate strictly via GPU properties (`transform`, `translate`, `opacity`, `clip-path`, `mask-image`), `linear()` physics spring easing (`--ease-spring`), `@starting-style` + `allow-discrete` dialog transitions (with cross-browser exit fallback), and `prefers-reduced-motion`.

---

## 3. UI Primitives, Viewport Shell & Workspace Modules

- **Standard Primitives (`client/src/components/ui/`)**:
  - `ShowcaseCard` (hover-gated 1px perimeter border spotlight, surface sheen, optional 3D perspective `tiltStrength`)
  - `DropdownMenu` (keyboard arrow / `Home` / `End` / `Escape` navigation)
  - `Skeleton`, `Toast`, `CommandPalette` (`⌘K`), `Select` (WAI-ARIA combobox + listbox), `Input`, gliding-pill `SegmentedControl`, and native `<dialog>`-backed `ModalDialog` (`showModal()`, scroll containment, light-dismiss).
  - Strictly forbid native `window.alert()` / `window.confirm()`; render inline errors and inline 2-step destructive confirmations.
- **Viewport Scroll Shell**:
  - `max-w-[1440px]` desktop container locking `html`/`body` (`height: 100%; overflow: hidden`) inside `h-screen h-[100dvh] flex flex-col overflow-hidden`.
  - Pinned `<Header />` (`shrink-0`) at top; dedicated inner `custom-scrollbar` container wraps `<main className="flex-1 flex flex-col">` + frosted `<Footer />` (displaying live `NEXT_PUBLIC_APP_VERSION` badge at `text-xs`).
  - Standard `scrollbar-width: thin` / `scrollbar-color` with >= 3:1 contrast and `@supports not (scrollbar-color: auto)` WebKit fallbacks.
- **Performance & Dynamic Imports**:
  - Dynamically import `@mlc-ai/web-llm` (`import('../../lib/webllm')`) on hover/focus/execution, and load secondary modals via `next/dynamic`.
  - Use per-account `sessionStorage` stale-while-revalidate caching with `WorkspaceSkeleton` / `ActivityListSkeleton`.
  - Complete `vi` and `en` UI dictionaries (`client/src/i18n/`) decoupled cleanly from AI standup report output language.
