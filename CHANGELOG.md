# Changelog

Notable changes to Chroma Theme are documented in this file.

## Unreleased

- Add a development-only source-color generator and selector audit.  It
  extracts direct true-color `defface` colors, jointly classifies dark/light
  observations as Neutral, Primary, or Secondary with an explicit confidence
  score, and reports ambiguous or differing reviewed mappings.  It also emits
  complete finite ten-hue palette candidates that either retain upstream
  OKLab lightness/chroma or WCAG relative luminance; runtime theme loading
  remains lookup-only.
- Raise the minimum supported Emacs version to 30.1 and reverse-audit Emacs 30
  built-in faces under a true-color display model.  Add the omitted direct
  colors for UI, ANSI, Customize, Widget, Org, Info, Message, Gnus, EWW, Ediff,
  Diff, and ERT faces while leaving inherited-only faces package-owned.
- Test the real, commit-pinned face definitions from Avy 0.5.0, Corfu 2.10,
  diff-hl 1.10.0, Magit 4.6.0, Tempel 1.14, Transient 0.13.5, and Vundo 2.4.0.
  Complete the previously omitted Corfu indexed/quick, Transient no-op, and
  Vundo diff-highlight mappings without adding runtime dependencies.
- Verify every direct foreground/background pair for all 10×10 Primary and
  Secondary choices in both variants.  Add source-specific finite tones for
  search, Customize, Org, Help, Whitespace, Avy, Corfu, diff-hl, Tempel,
  Transient, and Magit so their WCAG ratios remain within 0.12 of upstream.
- Fix source-relative backgrounds whose gamut handling could reuse the
  complementary hue or discard more chroma than sRGB requires.
  Purple with automatic Chartreuse now renders Magit additions as Chartreuse,
  and every affected hue is checked against its closest in-gamut OKLCH target.
- Replace the directional automatic Secondary choices with five reciprocal
  OKLCH complementary axes.  Add complete Azure and Chartreuse palettes and
  retune chromatic leaves to canonical hue angles while retaining their
  source-relative lightness and chroma.  Contrast-critical status and Diff
  indicator tones retain their WCAG relative luminance when an exact hue
  change cannot preserve every metric simultaneously.
- Match the perceptual strength of chromatic backgrounds to their upstream
  faces.  Standard Diff, Ediff/Smerge, Pulse, matching parentheses, and
  Magit's regular/current diff states now use source-specific finite tones
  instead of sharing a more saturated generic refinement color.
- Preserve complete upstream face structure through runtime proxy faces,
  restoring Org Calendar's inverse-video selection, link underlines, mode-line
  boxes, and other non-color attributes replaced by ordinary theme specs.
- Remove individual color mappings from inherited-only standard faces across
  mode/header-line children, the current line, completion, compilation, Diff,
  Dired, SHR, and TTY menu; let their upstream parents remain authoritative.
- Match the main dark and light backgrounds to the canonical Emacs default
  colors, black and white.
- Preserve source-relative contrast for Whitespace markers, Diff indicators,
  Ediff fine/current regions, status faces, fixed-lightness text, and neutral
  UI indicators across every selectable hue and both variants.
- Stop coloring standard faces whose defaults are structural-only, and replace
  `org-mode-line-clock-overrun`'s background instead of adding a foreground
  while leaving its standard red background active.
- Add source-relative `selection`, `standalone-selection`, `refinement`,
  `alert`, and `vivid` hue tones, reducing chroma only when the target
  OKLCH lightness would otherwise leave sRGB.
- Restore the standard prominence hierarchy for Font Lock keywords and
  comments, Diff/Smerge refinements, trailing whitespace, mode/tab UI,
  window dividers, and Magit diff highlights.
- Preserve the standard ANSI normal/bright lightness ordering while still
  restricting chromatic output to the selected primary and secondary hues.
- Stop adding colors to inherited-only current line, completion difference,
  compilation location, and tab faces; let their standard parent or
  structural emphasis remain authoritative.
- Add source-relative contrast, OKLab chroma, and related-face ordering
  regression tests across both variants and all selectable hues.
- Register the library directory in `custom-theme-load-path`, including
  through generated autoloads, so a local use-package `:load-path` makes
  Chroma appear in `load-theme` completion.
- Add an independently designed finite light palette selectable with
  `chroma-variant`.
- Validate palette completeness, face specs, semantic role resolution, and
  WCAG contrast thresholds for both dark and light variants.
- Derive error, warning, success, and info roles from the selected primary
  and secondary hues instead of fixed red, yellow, green, and cyan hues.
- Verify Diff added/removed and changed indicator/refinement colors, plus
  status contrast, across every selectable hue in both variants.
- Map `secondary-selection`, `highlight`, region, comments, and inherited
  completion highlights to selected hues, fixing Org source-edit and
  minibuffer completion colors inherited from Emacs defaults.
- Use a primary refinement tone for `hl-line` and ordinary UI highlights, and
  enforce a primary-dominant chromatic mapping ratio with ERT coverage.
- Add color-only external face mappings for Avy, Corfu, diff-hl, Magit,
  Tempel, Transient, and Vundo without introducing runtime dependencies.
- Preserve package-owned inheritance and structural attributes while applying
  external mappings to packages loaded after the theme is enabled.
- Strengthen Magit's selected diff-range boundary with the primary base tone
  while leaving `magit-diff-hunk-region` structural and transparent.
- Separate current-line and region selection backgrounds: `hl-line` uses the
  primary refinement tone and `region` uses the secondary selection tone.
- Complete foreground/background replacement for ANSI, Whitespace, Dired,
  Help, line-number tick, tab-line, and Holiday faces.
- Restore standard inheritance for Font Lock, completion, mode/header-line,
  and paren child faces, leaving standard colorless faces colorless.
- Add selected-hue coverage for Message, Smerge, EPA, EWW/SHR, Bookmark,
  Eshell, Speedbar, TTY menu, and Edmacro faces.
- Add selected-hue mappings for audited built-in Org, Ediff, Compilation,
  Customize, Widget, ANSI, and Whitespace chromatic faces.

## 0.1.0 - 2026-08-09

- Added a loadable dark true-color theme.
- Added finite neutral and eight-hue palettes.
- Added customizable primary and automatic/explicit secondary selection.
- Separated palette data, semantic roles, and categorized face mappings.
- Added color-only mappings for major built-in Emacs faces.
- Added ERT coverage for palette completeness, option resolution, face invariants, and WCAG contrast thresholds.
