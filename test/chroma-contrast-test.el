;;; chroma-contrast-test.el --- Chroma contrast tests  -*- lexical-binding: t; -*-

;;; Code:

(require 'ert)
(require 'chroma-core)
(require 'chroma-faces)

(defconst chroma-test-minimum-text-contrast 4.5
  "Minimum WCAG contrast ratio for ordinary representative text.")

(defconst chroma-test-enhanced-text-contrast 7.0
  "Preferred WCAG contrast ratio for Chroma's main text.")

(defconst chroma-test--source-relative-token-references
  '((selection "#0000cd" "#eedc82")
    (standalone-selection "#4a708b" "#ffff00")
    (refinement "#556b2f" "#b4eeb4")
    (paren-match "#4f94cd" "#40e0d0")
    (pulse "#aaaa33" "#ffffaa")
    (diff-added "#335533" "#eeffee")
    (diff-removed "#553333" "#ffeeee")
    (diff-refine-added "#22aa22" "#bbffbb")
    (diff-refine-removed "#aa2222" "#ffcccc")
    (magit-base "#555522" "#ffffcc")
    (magit-removed-highlight "#663333" "#eecccc")
    (magit-added-highlight "#336633" "#cceecc")
    (magit-base-highlight "#666622" "#eeeebb")
    (fine-a "#aa2222" "#ffbbbb")
    (fine-ancestor "#009591" "#00c5c0")
    (fine-b "#22aa22" "#aaffaa")
    (fine-c "#aaaa22" "#ffff55")
    (current-a "#553333" "#ffdddd")
    (current-ancestor "#004151" "#cfdeee")
    (current-b "#335533" "#ddffdd")
    (current-c "#888833" "#ffffaa")
    (gnus-mail-1-empty "#e1ffe1" "#cd1076")
    (gnus-mail-2-empty "#c1ffc1" "#cd6090")
    (gnus-mail-3-empty "#7fffd4" "#8b008b")
    (gnus-mail-low-empty "#76eec6" "#8b0a50")
    (gnus-news-1-empty "#afeeee" "#228b22")
    (gnus-news-2-empty "#40e0d0" "#53868b")
    (gnus-news-low-empty "#00ced1" "#006400")
    (gnus-summary-ancient "#87ceeb" "#4169e1")
    (gnus-summary-read "#98fb98" "#006400")
    (gnus-summary-ticked "#ffc0cb" "#b22222")
    (gnus-summary-undownloaded "#d3d3d3" "#008b8b")
    (info-node "#ffffff" "#a52a2a")
    (message-cited-1 "#ffaeb9" "#ff0000")
    (message-cited-2 "#228b22" "#8b0000")
    (message-cited-3 "#cd9b1d" "#698b22")
    (message-cited-4 "#cd661d" "#36648b")
    (message-command-output "#228b22" "#cd0000")
    (ert-expected "#00cd00" "#00ff00")
    (ert-unexpected "#cd0000" "#ff0000")
    (visited-link "#ee82ee" "#8b008b")
    (pale-success "#98fb98" "#228b22")
    (message-header-cc "#7fff00" "#191970")
    (message-header-name "#00ff00" "#6495ed")
    (message-header-newsgroups "#ffff00" "#00008b")
    (message-header-other "#ff3e96" "#4682b4")
    (message-header-subject "#c0ff3e" "#000080")
    (message-header-to "#caff70" "#191970")
    (message-mml "#00fa9a" "#228b22")
    (org-scheduled "#98fb98" "#006400")
    (speedbar-highlight "#2e8b57" "#00ff00")
    (ansi-bright-green "#00ee00" "#00ee00")
    (blink-offscreen "#00ff00" "#00ff00")
    (custom-state-foreground "#32cd32" "#006400")
    (speedbar-button "#00cd00" "#008b00"))
  "Dark and light upstream colors for source-relative hue tokens.")

(defconst chroma-test--contrast-critical-token-references
  '((isearch-foreground "#8b2323" "#b0e2ff")
    (isearch-background "#ee799f" "#cd00cd")
    (paren-mismatch-background "#a020f0" "#a020f0")
    (contrast-red-1 "#ff0000" "#ff0000")
    (contrast-yellow-1 "#ffff00" "#ffff00")
    (custom-state-background "#0000ff" "#0000ff")
    (custom-rogue-foreground "#ffc0cb" "#ffc0cb")
    (org-clock-background "#4a708b" "#d3d3d3")
    (org-dispatcher-foreground "#ffd700" "#00008b")
    (org-dispatcher-background "#333333" "#c6e2ff")
    (help-key-foreground "#add8e6" "#00008b")
    (whitespace-space-background "#333333" "#ffffe0")
    (whitespace-hspace-background "#3d3d3d" "#cdc9a5")
    (whitespace-tab-background "#383838" "#f5f5dc")
    (contrast-firebrick "#b22222" "#b22222")
    (contrast-dark-orange "#ff8c00" "#ff8c00")
    (whitespace-line-foreground "#ee82ee" "#ee82ee")
    (whitespace-missing-background "#d0d040" "#d0d040")
    (search-group-1-background "#ff82ab" "#f000f0")
    (search-group-1-foreground "#8b2323" "#b0e2ff")
    (search-group-2-background "#cd6889" "#a000a0")
    (search-group-2-foreground "#8b2323" "#b0e2ff")
    (corfu-quick-1-background "#0050af" "#7feaff")
    (corfu-quick-2-background "#7f1f7f" "#ffaaff")
    (vundo-diff-highlight "#104e8b" "#1e90ff")
    (corfu-current-background "#00415e" "#c0efff")
    (diff-hl-change-foreground "#0000cd" "#0000cd")
    (diff-hl-change-background "#333355" "#ddddff")
    (tempel-field-foreground "#e5cfef" "#541f4f")
    (tempel-field-background "#230631" "#fdf0ff")
    (tempel-form-foreground "#b8e2b8" "#004000")
    (tempel-form-background "#001904" "#ecf7ed")
    (tempel-default-foreground "#a8e5e5" "#0f3360")
    (tempel-default-background "#041529" "#ebf6fa")
    (avy-lead-background "#e52b50" "#e52b50")
    (avy-lead-0-background "#4f57f9" "#4f57f9")
    (avy-lead-2-background "#f86bf3" "#f86bf3")
    (transient-disabled-background "#ff0000" "#ff0000")
    (transient-enabled-background "#00ff00" "#00ff00")
    (magit-lines-background "#8b4c39" "#cd8162")
    (magit-red-deep "#553333" "#ffdddd")
    (magit-red-pale "#ffdddd" "#aa2222")
    (magit-green-deep "#335533" "#ddffdd")
    (magit-green-pale "#ddffdd" "#22aa22")
    (magit-base-deep "#555522" "#ffffcc")
    (magit-base-pale "#ffffcc" "#aaaa11")
    (magit-red-highlight-foreground "#eecccc" "#aa2222")
    (magit-red-highlight-background "#663333" "#eecccc")
    (magit-green-highlight-foreground "#cceecc" "#22aa22")
    (magit-green-highlight-background "#336633" "#cceecc")
    (magit-base-highlight-foreground "#eeeebb" "#aaaa11")
    (magit-base-highlight-background "#666622" "#eeeebb")
    (ansi-magenta "#cd00cd" "#cd00cd")
    (ansi-bright-magenta "#ee00ee" "#ee00ee")
    (ansi-green "#00cd00" "#00cd00")
    (steady "#228b22" "#228b22")
    (special-glyph "#00ffff" "#a52a2a")
    (match "#3a5fcd" "#fff68f")
    (message-separator "#b0e2ff" "#a52a2a")
    (sh-quoted-exec "#fa8072" "#ff00ff"))
  "Dark and light sources for finite contrast-critical hue tokens.")

(defun chroma-test--hex-channel (color offset)
  "Read a normalized RGB channel from COLOR at OFFSET."
  (/ (string-to-number (substring color offset (+ offset 2)) 16) 255.0))

(defun chroma-test--linear-channel (channel)
  "Convert an sRGB CHANNEL to its linear value."
  (if (<= channel 0.04045)
      (/ channel 12.92)
    (expt (/ (+ channel 0.055) 1.055) 2.4)))

(defun chroma-test--relative-luminance (color)
  "Return WCAG relative luminance for hexadecimal COLOR."
  (+ (* 0.2126
        (chroma-test--linear-channel
         (chroma-test--hex-channel color 1)))
     (* 0.7152
        (chroma-test--linear-channel
         (chroma-test--hex-channel color 3)))
     (* 0.0722
        (chroma-test--linear-channel
         (chroma-test--hex-channel color 5)))))

(defun chroma-test--contrast-ratio (first second)
  "Return the WCAG contrast ratio between FIRST and SECOND."
  (let ((first-luminance (chroma-test--relative-luminance first))
        (second-luminance (chroma-test--relative-luminance second)))
    (/ (+ (max first-luminance second-luminance) 0.05)
       (+ (min first-luminance second-luminance) 0.05))))

(defun chroma-test--oklab (color)
  "Return the OKLab lightness and chroma of hexadecimal COLOR."
  (let* ((red (chroma-test--linear-channel
               (chroma-test--hex-channel color 1)))
         (green (chroma-test--linear-channel
                 (chroma-test--hex-channel color 3)))
         (blue (chroma-test--linear-channel
                (chroma-test--hex-channel color 5)))
         (ll (+ (* 0.4122214708 red) (* 0.5363325363 green)
                (* 0.0514459929 blue)))
         (mm (+ (* 0.2119034982 red) (* 0.6806995451 green)
                (* 0.1073969566 blue)))
         (ss (+ (* 0.0883024619 red) (* 0.2817188376 green)
                (* 0.6299787005 blue)))
         (l-root (expt ll (/ 1.0 3.0)))
         (m-root (expt mm (/ 1.0 3.0)))
         (s-root (expt ss (/ 1.0 3.0)))
         (lightness
          (+ (* 0.2104542553 l-root) (* 0.7936177850 m-root)
             (* -0.0040720468 s-root)))
         (aa (+ (* 1.9779984951 l-root) (* -2.4285922050 m-root)
                (* 0.4505937099 s-root)))
         (bb (+ (* 0.0259040371 l-root) (* 0.7827717662 m-root)
                (* -0.8086757660 s-root))))
    (list lightness
          (sqrt (+ (* aa aa) (* bb bb)))
          (mod (* 180.0 (/ (atan bb aa) float-pi)) 360.0))))

(defun chroma-test--oklab-lightness (color)
  "Return OKLab lightness for hexadecimal COLOR."
  (car (chroma-test--oklab color)))

(defun chroma-test--oklab-chroma (color)
  "Return OKLab chroma for hexadecimal COLOR."
  (cadr (chroma-test--oklab color)))

(defun chroma-test--oklab-hue (color)
  "Return the OKLab hue angle for hexadecimal COLOR."
  (nth 2 (chroma-test--oklab color)))

(defun chroma-test--hue-distance (first second)
  "Return the shortest distance in degrees between FIRST and SECOND."
  (abs (- (mod (+ (- first second) 180.0) 360.0) 180.0)))

(defun chroma-test--oklch-linear-srgb (lightness chroma hue)
  "Return linear sRGB for an OKLCH LIGHTNESS, CHROMA, and HUE."
  (let* ((radians (* float-pi (/ hue 180.0)))
         (aa (* chroma (cos radians)))
         (bb (* chroma (sin radians)))
         (ll (+ lightness (* 0.3963377774 aa) (* 0.2158037573 bb)))
         (mm (- lightness (* 0.1055613458 aa) (* 0.0638541728 bb)))
         (ss (- lightness (* 0.0894841775 aa) (* 1.2914855480 bb)))
         (l-cube (* ll ll ll))
         (m-cube (* mm mm mm))
         (s-cube (* ss ss ss)))
    (list (+ (* 4.0767416621 l-cube) (* -3.3077115913 m-cube)
             (* 0.2309699292 s-cube))
          (+ (* -1.2684380046 l-cube) (* 2.6097574011 m-cube)
             (* -0.3413193965 s-cube))
          (+ (* -0.0041960863 l-cube) (* -0.7034186147 m-cube)
             (* 1.7076147010 s-cube)))))

(defun chroma-test--oklch-in-srgb-p (lightness chroma hue)
  "Return non-nil when the OKLCH color LIGHTNESS CHROMA HUE is in sRGB."
  (catch 'outside
    (dolist (channel
             (chroma-test--oklch-linear-srgb lightness chroma hue))
      (unless (and (>= channel 0.0) (<= channel 1.0))
        (throw 'outside nil)))
    t))

(defun chroma-test--maximum-in-gamut-chroma (lightness chroma hue)
  "Return CHROMA, reduced only enough to fit LIGHTNESS and HUE in sRGB."
  (if (chroma-test--oklch-in-srgb-p lightness chroma hue)
      chroma
    (let ((low 0.0)
          (high chroma))
      (dotimes (_ 60)
        (let ((middle (/ (+ low high) 2.0)))
          (if (chroma-test--oklch-in-srgb-p lightness middle hue)
              (setq low middle)
            (setq high middle))))
      low)))

(defun chroma-test--should-meet-contrast (first second minimum)
  "Assert that FIRST and SECOND meet contrast ratio MINIMUM."
  (should (>= (chroma-test--contrast-ratio first second) minimum)))

(defun chroma-test--should-have-contrast-between
    (first second minimum maximum)
  "Assert that FIRST and SECOND have contrast within MINIMUM and MAXIMUM."
  (let ((ratio (chroma-test--contrast-ratio first second)))
    (should (>= ratio minimum))
    (should (<= ratio maximum))))

(defun chroma-test--contrast-level (ratio)
  "Return the WCAG prominence level met by RATIO."
  (cond
   ((>= ratio 7.0) 3)
   ((>= ratio 4.5) 2)
   ((>= ratio 3.0) 1)
   (t 0)))

(ert-deftest chroma-contrast-main-text-meets-enhanced-threshold ()
  "Both variants' main text meets the enhanced 7:1 threshold."
  (dolist (variant chroma-supported-variants)
    (let ((colors
           (chroma-resolve-semantic-colors 'blue 'auto variant)))
      (chroma-test--should-meet-contrast
       (alist-get 'fg-main colors)
       (alist-get 'bg-main colors)
       chroma-test-enhanced-text-contrast))))

(ert-deftest chroma-contrast-palettes-follow-complementary-hue-axes ()
  "Chromatic palette leaves follow canonical complementary OKLCH axes."
  (dolist (pair chroma-primary-secondary-pairs)
    (let ((primary-angle (alist-get (car pair) chroma-hue-angles))
          (secondary-angle (alist-get (cdr pair) chroma-hue-angles)))
      (should
       (< (abs (- (chroma-test--hue-distance
                   primary-angle secondary-angle)
                  180.0))
          0.001))))
  (dolist (variant chroma-supported-variants)
    (dolist (hue chroma-supported-hues)
      (let ((target (alist-get hue chroma-hue-angles)))
        (dolist (token chroma-palette-required-hue-tokens)
          (let ((color (chroma-palette-color hue token variant)))
            ;; Hue is not meaningful for nearly achromatic colors.  For
            ;; chromatic leaves, allow only the error introduced by 8-bit
            ;; hexadecimal quantization.
            (when (>= (chroma-test--oklab-chroma color) 0.02)
              (should
               (< (chroma-test--hue-distance
                   (chroma-test--oklab-hue color) target)
                  3.0)))))))))

(ert-deftest chroma-contrast-neutral-text-pairs-meet-threshold ()
  "Both variants' representative neutral pairs meet 4.5:1."
  (dolist (variant chroma-supported-variants)
    (let ((colors
           (chroma-resolve-semantic-colors 'blue 'auto variant)))
      (dolist (pair '((fg-secondary . bg-main)
                      (fg-dim . bg-main)
                      (fg-muted . bg-main)
                      (fg-main . bg-subtle)
                      (fg-main . bg-highlight)
                      (fg-main . bg-selection)))
        (chroma-test--should-meet-contrast
         (alist-get (car pair) colors)
         (alist-get (cdr pair) colors)
         chroma-test-minimum-text-contrast)))))

(ert-deftest chroma-contrast-every-hue-works-on-main-background ()
  "Every variant's base hues meet 4.5:1 on its main background."
  (dolist (variant chroma-supported-variants)
    (let ((background
           (chroma-palette-color 'neutral 'bg-main variant)))
      (dolist (hue chroma-supported-hues)
        (chroma-test--should-meet-contrast
         (chroma-palette-color hue 'base variant)
         background
         chroma-test-minimum-text-contrast)))))

(ert-deftest chroma-contrast-every-emphasis-works-on-main-background ()
  "Every variant's emphasis hues meet 4.5:1 on its main background."
  (dolist (variant chroma-supported-variants)
    (let ((background
           (chroma-palette-color 'neutral 'bg-main variant)))
      (dolist (hue chroma-supported-hues)
        (chroma-test--should-meet-contrast
         (chroma-palette-color hue 'emphasis variant)
         background
         chroma-test-minimum-text-contrast)))))

(ert-deftest chroma-contrast-main-text-works-on-every-muted-hue ()
  "Main text meets 4.5:1 on every selectable highlight background."
  (dolist (variant chroma-supported-variants)
    (let ((foreground
           (chroma-palette-color 'neutral 'fg-main variant)))
      (dolist (hue chroma-supported-hues)
        (chroma-test--should-meet-contrast
         foreground
         (chroma-palette-color hue 'muted variant)
         chroma-test-minimum-text-contrast)))))

(ert-deftest chroma-contrast-status-foregrounds-work-on-muted-backgrounds ()
  "Every selectable status tone meets 4.5:1 on its muted background."
  (dolist (variant chroma-supported-variants)
    (dolist (hue chroma-supported-hues)
      (dolist (token '(base emphasis))
        (chroma-test--should-meet-contrast
         (chroma-palette-color hue token variant)
         (chroma-palette-color hue 'muted variant)
         chroma-test-minimum-text-contrast)))))

(ert-deftest chroma-contrast-status-tones-retain-standard-prominence ()
  "Status text retains the standard dark/light contrast asymmetry."
  (dolist (hue chroma-supported-hues)
    (dolist (expectation
             '((status-error 15.3 15.5 4.2 4.3)
               (status-warning 10.1 10.3 2.4 2.5)
               (status-success 17.2 17.4 4.6 4.7)))
      (let ((token (nth 0 expectation)))
        (chroma-test--should-have-contrast-between
         (chroma-palette-color hue token 'dark)
         (chroma-palette-color 'neutral 'bg-main 'dark)
         (nth 1 expectation) (nth 2 expectation))
        (chroma-test--should-have-contrast-between
         (chroma-palette-color hue token 'light)
         (chroma-palette-color 'neutral 'bg-main 'light)
         (nth 3 expectation) (nth 4 expectation))))))

(ert-deftest chroma-contrast-whitespace-markers-retain-subtle-levels ()
  "Whitespace markers stay strong on dark and deliberately faint on light."
  (dolist (hue chroma-supported-hues)
    (chroma-test--should-have-contrast-between
     (chroma-palette-color 'neutral 'fg-fixed-gray 'dark)
     (chroma-palette-color hue 'muted 'dark)
     4.3 5.6)
    (chroma-test--should-have-contrast-between
     (chroma-palette-color 'neutral 'fg-fixed-gray 'light)
     (chroma-palette-color hue 'muted 'light)
     1.1 1.3)
    (chroma-test--should-have-contrast-between
     (chroma-palette-color hue 'whitespace-big-foreground 'dark)
     (chroma-palette-color hue 'alert 'dark)
     1.6 1.8)
    (chroma-test--should-have-contrast-between
     (chroma-palette-color hue 'whitespace-big-foreground 'light)
     (chroma-palette-color hue 'alert 'light)
     1.6 1.8)))

(ert-deftest chroma-contrast-diff-indicators-retain-source-levels ()
  "Diff indicators retain their distinct standard contrast levels."
  (dolist (hue chroma-supported-hues)
    (let ((dark-muted (chroma-palette-color hue 'muted 'dark))
          (light-muted (chroma-palette-color hue 'muted 'light)))
      (chroma-test--should-have-contrast-between
       (chroma-palette-color hue 'indicator-removed 'dark)
       dark-muted 1.5 1.6)
      (chroma-test--should-have-contrast-between
       (chroma-palette-color hue 'indicator-removed 'light)
       light-muted 6.2 6.5)
      (chroma-test--should-have-contrast-between
       (chroma-palette-color hue 'indicator-added 'dark)
       dark-muted 2.7 2.8)
      (chroma-test--should-have-contrast-between
       (chroma-palette-color hue 'indicator-added 'light)
       light-muted 2.9 3.0)
      (chroma-test--should-have-contrast-between
       (chroma-palette-color hue 'changed-indicator 'dark)
       (chroma-palette-color 'neutral 'bg-main 'dark)
       9.5 9.7)
      (chroma-test--should-have-contrast-between
       (chroma-palette-color hue 'changed-indicator 'light)
       (chroma-palette-color 'neutral 'bg-main 'light)
       2.6 2.7))))

(ert-deftest chroma-contrast-ediff-fine-levels-retain-source-order ()
  "Ediff's four fine backgrounds retain their variant-specific ordering."
  (dolist (hue chroma-supported-hues)
    (let ((dark-foreground
           (chroma-palette-color 'neutral 'fg-main 'dark))
          (light-foreground
           (chroma-palette-color 'neutral 'fg-main 'light)))
      (let ((a (chroma-test--contrast-ratio
                dark-foreground
                (chroma-palette-color hue 'fine-a 'dark)))
            (ancestor (chroma-test--contrast-ratio
                       dark-foreground
                       (chroma-palette-color hue 'fine-ancestor 'dark)))
            (b (chroma-test--contrast-ratio
                dark-foreground
                (chroma-palette-color hue 'fine-b 'dark)))
            (c (chroma-test--contrast-ratio
                dark-foreground
                (chroma-palette-color hue 'fine-c 'dark))))
        (should (> a ancestor b c)))
      (let ((a (chroma-test--contrast-ratio
                light-foreground
                (chroma-palette-color hue 'fine-a 'light)))
            (ancestor (chroma-test--contrast-ratio
                       light-foreground
                       (chroma-palette-color hue 'fine-ancestor 'light)))
            (b (chroma-test--contrast-ratio
                light-foreground
                (chroma-palette-color hue 'fine-b 'light)))
            (c (chroma-test--contrast-ratio
                light-foreground
                (chroma-palette-color hue 'fine-c 'light))))
        (should (> c b a ancestor))))))

(ert-deftest chroma-contrast-new-tones-preserve-visual-hierarchy ()
  "Selection, refinement, and alert tones remain perceptually ordered."
  (dolist (variant chroma-supported-variants)
    (let ((background
           (chroma-palette-color 'neutral 'bg-main variant)))
      (dolist (hue chroma-supported-hues)
        (let ((muted (chroma-palette-color hue 'muted variant))
              (selection (chroma-palette-color hue 'selection variant))
              (refinement
               (chroma-palette-color hue 'refinement variant))
              (alert (chroma-palette-color hue 'alert variant)))
          (should
           (> (chroma-test--contrast-ratio refinement background)
              (chroma-test--contrast-ratio muted background)))
          (should
           (> (chroma-test--contrast-ratio alert background)
              (chroma-test--contrast-ratio refinement background)))
          (should
           (> (chroma-test--oklab-chroma selection)
              (chroma-test--oklab-chroma muted)))
          (should
           (> (chroma-test--oklab-chroma refinement)
              (chroma-test--oklab-chroma muted))))))))

(ert-deftest chroma-contrast-source-relative-tokens-match-gamut-target ()
  "Source-relative tokens preserve the closest in-gamut OKLCH color."
  (dolist (expectation chroma-test--source-relative-token-references)
    (dolist (variant chroma-supported-variants)
      (let* ((reference
              (nth (if (eq variant 'dark) 1 2) expectation))
             (reference-lightness
              (chroma-test--oklab-lightness reference))
             (reference-chroma
              (chroma-test--oklab-chroma reference)))
        (dolist (hue chroma-supported-hues)
          (let* ((target-hue (alist-get hue chroma-hue-angles))
                 (target-radians (* float-pi (/ target-hue 180.0)))
                 (target-chroma
                  (chroma-test--maximum-in-gamut-chroma
                   reference-lightness reference-chroma target-hue))
                 (target-a (* target-chroma (cos target-radians)))
                 (target-b (* target-chroma (sin target-radians)))
                 (color
                  (chroma-palette-color hue (car expectation) variant))
                 (actual (chroma-test--oklab color))
                 (actual-radians
                  (* float-pi (/ (nth 2 actual) 180.0)))
                 (actual-a (* (nth 1 actual) (cos actual-radians)))
                 (actual-b (* (nth 1 actual) (sin actual-radians))))
            (should
             (< (abs (- (nth 0 actual) reference-lightness))
                0.004))
            (should
             (< (sqrt (+ (expt (- actual-a target-a) 2)
                         (expt (- actual-b target-b) 2)))
                0.004))))))))

(ert-deftest chroma-contrast-critical-tokens-preserve-source-luminance ()
  "Contrast-critical tokens retain source luminance on every hue axis."
  (dolist (expectation chroma-test--contrast-critical-token-references)
    (dolist (variant chroma-supported-variants)
      (let* ((reference
              (nth (if (eq variant 'dark) 1 2) expectation))
             (source-chroma (chroma-test--oklab-chroma reference))
             (source-luminance
              (chroma-test--relative-luminance reference)))
        (dolist (hue chroma-supported-hues)
          (let* ((target-hue (alist-get hue chroma-hue-angles))
                 (color
                  (chroma-palette-color hue (car expectation) variant))
                 (actual (chroma-test--oklab color))
                 (actual-lightness (nth 0 actual))
                 (actual-chroma (nth 1 actual))
                 (maximum-chroma
                  (chroma-test--maximum-in-gamut-chroma
                   actual-lightness source-chroma target-hue)))
            (should
             (< (abs (- (chroma-test--relative-luminance color)
                        source-luminance))
                0.004))
            (should (< (abs (- actual-chroma maximum-chroma)) 0.004))))))))

(ert-deftest chroma-contrast-reviewed-low-confidence-contexts-retain-levels ()
  "Reviewed ambiguous faces retain source contrast in their real context."
  (dolist (expectation
           (append chroma-test--source-relative-token-references
                   chroma-test--contrast-critical-token-references))
    (when (memq (car expectation)
                '(ansi-magenta ansi-bright-magenta ansi-green
                  ansi-bright-green steady visited-link
                  special-glyph pale-success match message-header-cc
                  message-header-name message-header-newsgroups
                  message-header-other message-header-subject
                  message-header-to message-mml message-separator
                  org-scheduled sh-quoted-exec speedbar-highlight
                  blink-offscreen custom-state-foreground
                  speedbar-button))
      (dolist (variant chroma-supported-variants)
        (let* ((token (car expectation))
               (source (nth (if (eq variant 'dark) 1 2) expectation))
               (background-p (memq token '(match speedbar-highlight)))
               (surround
                (chroma-palette-color
                 'neutral (if background-p 'fg-main 'bg-main) variant))
               (source-level
                (chroma-test--contrast-level
                 (chroma-test--contrast-ratio source surround))))
          (dolist (hue chroma-supported-hues)
            (should
             (>= (chroma-test--contrast-level
                  (chroma-test--contrast-ratio
                   (chroma-palette-color hue token variant) surround))
                 source-level)))))))
  ;; Compilation's successful exit indicator appears on the mode line, not
  ;; the main background.  Both neutral mode-line backgrounds retain their
  ;; upstream values, so equal luminance keeps this pair's contrast stable.
  (dolist (variant chroma-supported-variants)
    (let* ((source "#228b22")
           (background
            (chroma-palette-color
             'neutral 'mode-line-source-background variant))
           (source-ratio (chroma-test--contrast-ratio source background)))
      (dolist (hue chroma-supported-hues)
        (should
         (< (abs (- (chroma-test--contrast-ratio
                     (chroma-palette-color hue 'steady variant)
                     background)
                    source-ratio))
            0.08)))))
  ;; ANSI colors may be used as either member of a foreground/background pair.
  (dolist (variant chroma-supported-variants)
    (let ((foreground
           (chroma-palette-color 'neutral 'fg-main variant)))
      (dolist (token '(ansi-magenta ansi-bright-magenta ansi-green))
        (let* ((expectation
                (assq token
                      chroma-test--contrast-critical-token-references))
               (source (nth (if (eq variant 'dark) 1 2) expectation))
               (source-ratio
                (chroma-test--contrast-ratio source foreground)))
          (dolist (hue chroma-supported-hues)
            (should
             (< (abs (- (chroma-test--contrast-ratio
                         (chroma-palette-color hue token variant)
                         foreground)
                        source-ratio))
                0.08))))))))

(ert-deftest chroma-contrast-vivid-tone-preserves-standard-syntax-levels ()
  "Vivid syntax is very bright on dark and moderately dark on light."
  (dolist (variant chroma-supported-variants)
    (let ((minimum (if (eq variant 'dark) 15.5 5.0))
          (background
           (chroma-palette-color 'neutral 'bg-main variant)))
      (dolist (hue chroma-supported-hues)
        (chroma-test--should-meet-contrast
         (chroma-palette-color hue 'vivid variant)
         background minimum)))))

(ert-deftest chroma-contrast-ansi-tones-preserve-source-lightness-order ()
  "ANSI tones retain their source lightness order after hue replacement."
  (dolist (variant chroma-supported-variants)
    (dolist (hue chroma-supported-hues)
      (let ((tones
             (mapcar
              (lambda (token)
                (chroma-test--relative-luminance
                 (chroma-palette-color hue token variant)))
              '(ansi-low ansi-low-bright ansi-mid ansi-mid-bright
                ansi-upper ansi-upper-bright ansi-high ansi-vivid))))
        (while (cdr tones)
          (should (< (car tones) (cadr tones)))
          (setq tones (cdr tones)))))))

(ert-deftest chroma-contrast-source-relative-face-levels-are-preserved ()
  "High-risk face mappings retain their standard relative prominence."
  (dolist (hue chroma-supported-hues)
    (let* ((colors (chroma-resolve-semantic-colors hue 'auto 'dark))
           (background (alist-get 'bg-main colors))
           (comment
            (plist-get
             (chroma--resolve-face-attributes
              (chroma-face-mapping 'font-lock-comment-face) colors)
             :foreground))
           (keyword
            (plist-get
             (chroma--resolve-face-attributes
              (chroma-face-mapping 'font-lock-keyword-face) colors)
             :foreground)))
      (should
       (> (chroma-test--contrast-ratio keyword background)
          (chroma-test--contrast-ratio comment background)))))
  (dolist (variant chroma-supported-variants)
    (let* ((colors
            (chroma-resolve-semantic-colors 'blue 'orange variant))
           (background (alist-get 'bg-main colors))
           (added
            (plist-get
             (chroma--resolve-face-attributes
              (chroma-face-mapping 'diff-added) colors)
             :background))
           (refined
            (plist-get
             (chroma--resolve-face-attributes
              (chroma-face-mapping 'diff-refine-added) colors)
             :background)))
      (should-not (equal added refined))
      (should
       (> (chroma-test--contrast-ratio refined background)
          (chroma-test--contrast-ratio added background))))))

(ert-deftest chroma-contrast-neutral-ui-levels-follow-standard-order ()
  "Neutral UI roles keep standard leading/trailing and bar hierarchy."
  (dolist (variant chroma-supported-variants)
    (let* ((background
            (chroma-palette-color 'neutral 'bg-main variant))
           (leading
            (chroma-palette-color 'neutral 'border-leading variant))
           (trailing
            (chroma-palette-color 'neutral 'border-trailing variant)))
      (if (eq variant 'dark)
          (should (> (chroma-test--contrast-ratio leading background)
                     (chroma-test--contrast-ratio trailing background)))
        (should (< (chroma-test--contrast-ratio leading background)
                   (chroma-test--contrast-ratio trailing background))))))
  (chroma-test--should-meet-contrast
   (chroma-palette-color 'neutral 'bg-ui 'dark)
   (chroma-palette-color 'neutral 'bg-main 'dark)
   10.0)
  (chroma-test--should-meet-contrast
   (chroma-palette-color 'neutral 'fg-on-bright 'light)
   (chroma-palette-color 'neutral 'bg-ui 'light)
   10.0))

(defconst chroma-contrast-test--audited-built-in-libraries
  '(tab-bar tab-line hl-line display-line-numbers isearch replace
    paren compile diff-mode ediff ansi-color cus-edit wid-edit ert org
    pulse sh-script dired help-mode info calendar whitespace message
    smerge-mode bookmark edmacro epa em-prompt eww shr speedbar tmm)
  "Built-in libraries loaded by effective color-pair tests.")

(defun chroma-test--standard-color-hex (color)
  "Return standard six-digit hexadecimal RGB for COLOR."
  (if (string-match-p "\\`#[[:xdigit:]]\\{6\\}\\'" color)
      (downcase color)
    (let ((values
           (tty-color-standard-values
            (downcase
             (replace-regexp-in-string "[[:space:]]" "" color)))))
      (unless values
        (error "No standard RGB definition for %S" color))
      (apply #'format "#%02x%02x%02x"
             (mapcar (lambda (value) (round (/ value 257.0))) values)))))

(ert-deftest chroma-contrast-direct-face-pairs-retain-source-contrast ()
  "Every direct foreground/background pair retains upstream contrast."
  (dolist (library chroma-contrast-test--audited-built-in-libraries)
    (require library nil t))
  (let ((old-display-type (frame-parameter nil 'display-type))
        (old-background-mode (frame-parameter nil 'background-mode))
        (color-sets
         (cl-loop
          for variant in chroma-supported-variants append
          (cl-loop
           for primary in chroma-supported-hues append
           (cl-loop
            for secondary in chroma-supported-hues
            collect
            (list variant primary secondary
                  (chroma-resolve-semantic-colors
                   primary secondary variant))))))
        (pair-count 0))
    (unwind-protect
        (cl-letf (((symbol-function 'display-color-cells)
                   (lambda (&optional _frame) 16777216))
                  ((symbol-function 'window-system)
                   (lambda (&optional _frame) 'pgtk)))
          (dolist (mapping (chroma-face-mappings))
            (when (and (facep (car mapping))
                       (plist-member (cdr mapping) :foreground)
                       (plist-member (cdr mapping) :background))
              (dolist (variant chroma-supported-variants)
                (modify-frame-parameters
                 nil (list (cons 'display-type 'color)
                           (cons 'background-mode variant)))
                (let* ((source
                        (face-spec-choose
                         (get (car mapping) 'face-defface-spec)))
                       (source-foreground
                        (plist-get source :foreground))
                       (source-background
                        (plist-get source :background)))
                  (when (and (stringp source-foreground)
                             (stringp source-background))
                    (setq pair-count (1+ pair-count))
                    (let ((source-ratio
                           (chroma-test--contrast-ratio
                            (chroma-test--standard-color-hex
                             source-foreground)
                            (chroma-test--standard-color-hex
                             source-background))))
                      (dolist (entry color-sets)
                        (when (eq variant (nth 0 entry))
                          (let* ((attributes
                                  (chroma--resolve-face-attributes
                                   (cdr mapping) (nth 3 entry)))
                                 (candidate-ratio
                                  (chroma-test--contrast-ratio
                                   (plist-get attributes :foreground)
                                   (plist-get attributes :background))))
                            ;; Contrast-critical finite tokens hold source
                            ;; luminance.  This tolerance covers only 8-bit
                            ;; HEX quantization across the two selected hues.
                            (should
                             (< (abs (- candidate-ratio source-ratio))
                                0.12))))))))))))
      (modify-frame-parameters
       nil (list (cons 'display-type old-display-type)
                 (cons 'background-mode old-background-mode))))
    (should (> pair-count 60))))

(provide 'chroma-contrast-test)

;;; chroma-contrast-test.el ends here
