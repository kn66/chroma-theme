;;; chroma-contrast-test.el --- Chroma contrast tests  -*- lexical-binding: t; -*-

;;; Code:

(require 'ert)
(require 'chroma-core)
(require 'chroma-faces)

(defconst chroma-test-minimum-text-contrast 4.5
  "Minimum WCAG contrast ratio for ordinary representative text.")

(defconst chroma-test-enhanced-text-contrast 7.0
  "Preferred WCAG contrast ratio for Chroma's main text.")

(defconst chroma-test--source-relative-background-references
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
    (current-c "#888833" "#ffffaa"))
  "Dark and light upstream colors for source-relative backgrounds.")

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

(ert-deftest chroma-contrast-background-tones-match-source-gamut-target ()
  "Source-relative backgrounds preserve the closest in-gamut OKLCH color."
  (dolist (expectation chroma-test--source-relative-background-references)
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

(provide 'chroma-contrast-test)

;;; chroma-contrast-test.el ends here
