# Chroma Theme agent instructions

These are project invariants. Apply them to every face, palette, semantic-role,
test, and documentation change in this repository.

## Product invariant

Chroma changes the hue of upstream default-theme colors; it does not redesign
the upstream face.

- Treat the standard Emacs default face, or the package's default `defface`, as
  the source of truth for each supported Emacs/package version and for both
  light and dark displays.
- Intentionally change hue only. Reproduce all other color characteristics as
  closely as sRGB permits, including OKLab/OKLCH lightness and chroma, effective
  foreground/background contrast, and the relative prominence of related
  states.
- Preserve distinctions such as normal, selected, highlighted, current,
  refined, warning, and inactive. Do not collapse source-distinct levels into
  one generic tone.
- Compare colors against the effective surrounding background, not only against
  `default`, and inspect the complete foreground/background pair.
- Use dedicated finite palette tokens when upstream faces have materially
  different lightness, chroma, contrast, or prominence.
- If a target hue cannot reproduce the source in sRGB, preserve source
  lightness and contrast hierarchy and reduce chroma only as much as necessary.
  Document and test the exception; do not silently substitute an arbitrary
  stronger or weaker color.

## Structural preservation

Never redesign non-color face information.

- Authored mappings may replace only `:foreground` and `:background`.
- Preserve upstream `:inherit`, `:weight`, `:slant`, `:underline`, `:overline`,
  `:strike-through`, `:box`, `:height`, `:width`, `:family`, `:foundry`,
  `:inverse-video`, `:stipple`, and `:extend` behavior.
- Do not hard-code upstream structural attributes into Chroma mappings.
- Preserve compound attributes such as underlines and boxes through the
  upstream proxy. Do not replace only their embedded color unless Emacs offers
  a safe, structure-preserving mechanism and tests prove it.

## Face-by-face ownership

Audit every built-in and supported-package face individually. "Managed" does
not mean every face receives a direct mapping; it means every face has an
explicitly reviewed outcome.

- Directly map a face when its upstream definition directly specifies a
  concrete foreground or background color.
- Deliberately leave a face unmapped when its upstream definition is colorless
  or receives color only through inheritance. Let the audited upstream parent
  remain authoritative.
- Do not add a new color to an upstream-colorless face.
- Replace all and only the direct simple color attributes owned by the upstream
  face. Avoid partial coverage of a multi-color face.
- Keep inherited-only children unmapped so package and Emacs inheritance
  changes continue to propagate.
- Audit version differences rather than assuming one Emacs or package version's
  face definitions apply universally.

## Palette and semantic roles

- Keep palette leaves finite, author-reviewed, literal six-digit hexadecimal
  values. Never generate or adjust theme colors at runtime.
- Support every hue in `chroma-supported-hues` and every variant in
  `chroma-supported-variants` for each required hue token.
- Add a semantic role for every new use-specific palette token. Face mappings
  must reference roles, never literal colors.
- Keep Primary/Secondary hue selection authoritative; status, diff, search, and
  package faces must not introduce an unrelated fixed hue.
- Keep `chroma-hue-angles` and `chroma-primary-secondary-pairs` complete and
  symmetric.  Automatic Secondary selection must be reciprocal, and each pair
  of canonical OKLCH hue angles must differ by exactly 180 degrees.
- Aim every chromatic palette leaf at its canonical hue angle.  Permit only
  finite HEX quantization error; exempt nearly achromatic leaves, whose hue
  angle has no perceptual meaning.
- When a canonical hue changes WCAG relative luminance enough to violate an
  upstream contrast level, hold source relative luminance fixed and choose the
  closest in-gamut OKLab lightness and chroma.  Keep this exception limited to
  contrast-critical tokens and cover it with face-specific range tests.
- Measure source and candidate colors with the repository's OKLab and WCAG
  helpers. Do not judge equivalence from hexadecimal values or screenshots
  alone.

## Built-in and package coverage

- Work toward complete face-by-face coverage of built-in Emacs libraries in
  the supported Emacs versions.
- Maintain and expand support for widely used packages. Prioritize packages
  requested by users or present in the development environment.
- Do not claim package support until all of its directly colored faces have
  been audited, inheritance-only faces have explicit no-mapping decisions, and
  representative behavior has regression tests.
- Keep external packages optional. Do not `require` them as runtime theme
  dependencies; apply their mappings only when their faces exist.
- Record the audited package version in source comments and update
  `chroma-supported-external-packages`, README coverage, and tests together.

## Required verification

For every face, semantic-role, or palette change:

1. Add or update tests for the exact face mapping and semantic role.
2. Test every supported hue and both variants when palette data changes.
3. Test source-relative OKLab lightness/chroma and effective WCAG contrast or
   contrast ordering. Use face-specific reference colors and tolerances.
4. Test that structural and inherited attributes remain unchanged.
5. Visually inspect representative real buffers when the change is visible;
   inspect normal and active/refined states, not only one screenshot.
6. Run `make compile`, `make test`, `make checkdoc`, and `git diff --check`.
7. Remove generated bytecode with `make clean-elc` before handoff.

Update README and CHANGELOG when supported faces/packages, semantics, or visible
behavior changes.
