---
name: gitpulse-frontend-design
description: Git Pulse UI standards ('Precision Developer Dark' Cool Slate palette, InteractiveBackdrop, a11y dialogs, and vi/en i18n).
---

# Git Pulse Frontend Design ("Precision Developer Dark")

Applies to `services/git-pulse/client/`. Brand name is strictly **`Git Pulse`** (spaced, never `Git-Pulse`).

## 1. Cool Slate Elevated Palette & Typography

- **Canvas**: `#0F172A` (`slate-900`) backdrop and pinned header/footer chrome.
- **Surfaces**:
  - `.gp-card`: `rgba(30, 41, 59, 0.86)` / `#1E293B`
  - `.gp-modal-surface`: `rgba(30, 41, 59, 0.96)`
  - `.gp-glass-panel`: `rgba(34, 46, 66, 0.96)`
  - Nested elevated card: `rgba(39, 53, 73, 0.84)` / `#273549`
  - Recessed input well: `#152033`
- **Borders & Accents**: Hairline `#334155` (`white/[0.14]`), secondary text `>= #94A3B8` (`slate-400`, WCAG AA), primary accent `Sky-500` (`#0EA5E9`).
- **Typography**: `Plus Jakarta Sans` & `Inter` (`latin`, `vietnamese`), `JetBrains Mono` (`tabular-nums`). Strict min font size `>= 12px` (`text-xs`).

## 2. Backdrop, Motion & Anti-Slop Rules

- **`InteractiveBackdrop`**: Pointer-driven architectural grid, cursor halo, CSS-composited Git tiles/motes, and transient WAAPI pointer trails/click ripples. Must deactivate cleanly on pointer exit.
- **Motion Controls**: Pair with header Pause/Play ambient motion toggle (`useAmbientMotionPreference`) and session-gated `IntroScreen` (Replay button in header).
- **Strict Bans**: No continuous idle RAF starfields, scanlines, spinning logos, radar/sci-fi jargon, internal crypto boasting in public UI, or native `window.alert()` / `window.confirm()`.

## 3. Layout, Primitives & i18n

- **Primitives**: Reuse `ShowcaseCard`, `DropdownMenu`, `Select`, `Input`, `SegmentedControl`, and native `<dialog>` (`ModalDialog`) in `client/src/components/ui/`.
- **Viewport Shell**: `h-screen overflow-hidden` desktop shell with pinned header, inner `custom-scrollbar` container, and pinned footer.
- **AI Console & i18n**: Select-based AI provider console (`Groq Cloud`, `Google Gemini (<label>)` BYOK connections, `+ Add` modal trigger) with live model availability verification; 3-mode activity scanner ('Tất cả', 'Theo Task', 'Theo Repo') with dedicated Cockpit commit selection modal (`CommitSelectionModal`); full `vi`/`en` UI dictionary (`src/lib/i18n.ts`) decoupled from AI report language (`aiLanguage`).
