;;; chroma-generate.el --- Generate and audit Chroma colors  -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Chroma Theme contributors

;; Author: Chroma Theme contributors
;; Keywords: faces
;; Package-Requires: ((emacs "30.1"))

;; This file is part of Chroma Theme.

;; Chroma Theme is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;;; Commentary:

;; This development-only library derives finite Chroma color candidates from
;; upstream face colors and audits the reviewed static face mappings.  Theme
;; loading never requires this file and never generates or adjusts a color.
;;
;; Source-relative candidates retain upstream OKLab lightness and chroma,
;; reducing chroma only enough to enter sRGB.  Contrast-critical candidates
;; retain upstream WCAG relative luminance, then select the closest in-gamut
;; lightness and chroma on the requested canonical hue axis.  Both paths end
;; in a deterministic search of nearby literal 8-bit sRGB values.
;;
;; Selector auditing treats each face attribute across dark and light as one
;; observation group.  It fits a complementary source-hue axis to all audited
;; colors, classifies sufficiently chromatic groups as Primary or Secondary,
;; and reports low-confidence groups rather than silently forcing a semantic
;; decision.  Achromatic groups are classified as Neutral.

;;; Code:

(require 'cl-lib)
(require 'pp)
(require 'seq)
(require 'subr-x)
(require 'chroma-faces)

(defconst chroma-generate-neutral-chroma-threshold 0.02
  "Maximum OKLab chroma automatically classified as Neutral.")

(defconst chroma-generate-low-confidence-threshold 0.25
  "Selector confidence below which an automatic result needs review.")

(defconst chroma-generate-contrast-difference-threshold 0.12
  "Maximum WCAG ratio drift before generation becomes contrast-critical.")

(defconst chroma-generate-luminance-quantization-tolerance 0.004
  "Allowed relative-luminance error from literal 8-bit quantization.")

(defconst chroma-generate-audited-built-in-libraries
  '(tab-bar tab-line hl-line display-line-numbers isearch replace
    paren compile diff-mode ediff ansi-color cus-edit wid-edit org
    pulse sh-script dired help-mode info calendar whitespace message
    smerge-mode bookmark edmacro epa em-prompt eww shr speedbar tmm)
  "Built-in libraries included in the development-time selector audit.")

(defun chroma-generate-load-audited-built-ins ()
  "Load the built-in libraries included in Chroma's selector audit."
  (dolist (library chroma-generate-audited-built-in-libraries)
    (require library nil t)))

(defun chroma-generate--hex-channel (color offset)
  "Read a normalized RGB channel from hexadecimal COLOR at OFFSET."
  (/ (string-to-number (substring color offset (+ offset 2)) 16) 255.0))

(defun chroma-generate--linear-channel (channel)
  "Convert an sRGB CHANNEL to a linear-light value."
  (if (<= channel 0.04045)
      (/ channel 12.92)
    (expt (/ (+ channel 0.055) 1.055) 2.4)))

(defun chroma-generate--srgb-channel (channel)
  "Convert a linear-light CHANNEL to an sRGB value."
  (if (<= channel 0.0031308)
      (* 12.92 channel)
    (- (* 1.055 (expt channel (/ 1.0 2.4))) 0.055)))

(defun chroma-generate-color-hex (color)
  "Return COLOR as a normalized literal six-digit hexadecimal string."
  (cond
   ((and (stringp color)
         (string-match-p "\\`#[[:xdigit:]]\\{6\\}\\'" color))
    (downcase color))
   ((stringp color)
    (let ((values
           (tty-color-standard-values
            (downcase
             (replace-regexp-in-string "[[:space:]]" "" color)))))
      (unless values
        (user-error "No standard RGB definition for %S" color))
      (apply #'format "#%02x%02x%02x"
             (mapcar (lambda (value) (round (/ value 257.0))) values))))
   (t
    (user-error "Expected a color string, got %S" color))))

(defun chroma-generate--hex-linear-rgb (color)
  "Return hexadecimal COLOR as linear-light RGB."
  (let ((hex (chroma-generate-color-hex color)))
    (mapcar #'chroma-generate--linear-channel
            (list (chroma-generate--hex-channel hex 1)
                  (chroma-generate--hex-channel hex 3)
                  (chroma-generate--hex-channel hex 5)))))

(defun chroma-generate--linear-rgb-oklab (rgb)
  "Return linear RGB as an (L A B) OKLab list."
  (let* ((red (nth 0 rgb))
         (green (nth 1 rgb))
         (blue (nth 2 rgb))
         (ll (+ (* 0.4122214708 red) (* 0.5363325363 green)
                (* 0.0514459929 blue)))
         (mm (+ (* 0.2119034982 red) (* 0.6806995451 green)
                (* 0.1073969566 blue)))
         (ss (+ (* 0.0883024619 red) (* 0.2817188376 green)
                (* 0.6299787005 blue)))
         (l-root (expt ll (/ 1.0 3.0)))
         (m-root (expt mm (/ 1.0 3.0)))
         (s-root (expt ss (/ 1.0 3.0))))
    (list
     (+ (* 0.2104542553 l-root) (* 0.7936177850 m-root)
        (* -0.0040720468 s-root))
     (+ (* 1.9779984951 l-root) (* -2.4285922050 m-root)
        (* 0.4505937099 s-root))
     (+ (* 0.0259040371 l-root) (* 0.7827717662 m-root)
        (* -0.8086757660 s-root)))))

(defun chroma-generate-color-oklab (color)
  "Return hexadecimal or named COLOR as an (L A B) OKLab list."
  (chroma-generate--linear-rgb-oklab
   (chroma-generate--hex-linear-rgb color)))

(defun chroma-generate-color-oklch (color)
  "Return hexadecimal or named COLOR as an (L C H) OKLCH list."
  (pcase-let ((`(,lightness ,aa ,bb)
               (chroma-generate-color-oklab color)))
    (list lightness
          (sqrt (+ (* aa aa) (* bb bb)))
          (mod (* 180.0 (/ (atan bb aa) float-pi)) 360.0))))

(defun chroma-generate--oklch-linear-rgb (lightness chroma hue)
  "Return linear RGB for OKLCH LIGHTNESS, CHROMA, and HUE."
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

(defun chroma-generate--linear-rgb-in-gamut-p (rgb)
  "Return non-nil when every channel in linear RGB is inside sRGB."
  (seq-every-p (lambda (channel) (and (>= channel 0.0)
                                      (<= channel 1.0)))
               rgb))

(defun chroma-generate--maximum-chroma (lightness chroma hue)
  "Reduce CHROMA only enough to fit LIGHTNESS and HUE inside sRGB."
  (if (chroma-generate--linear-rgb-in-gamut-p
       (chroma-generate--oklch-linear-rgb lightness chroma hue))
      chroma
    (let ((low 0.0)
          (high chroma))
      (dotimes (_ 60)
        (let ((middle (/ (+ low high) 2.0)))
          (if (chroma-generate--linear-rgb-in-gamut-p
               (chroma-generate--oklch-linear-rgb
                lightness middle hue))
              (setq low middle)
            (setq high middle))))
      low)))

(defun chroma-generate--linear-luminance (rgb)
  "Return WCAG relative luminance for linear RGB."
  (+ (* 0.2126 (nth 0 rgb))
     (* 0.7152 (nth 1 rgb))
     (* 0.0722 (nth 2 rgb))))

(defun chroma-generate-relative-luminance (color)
  "Return WCAG relative luminance for hexadecimal or named COLOR."
  (chroma-generate--linear-luminance
   (chroma-generate--hex-linear-rgb color)))

(defun chroma-generate-contrast-ratio (first second)
  "Return the WCAG contrast ratio between FIRST and SECOND colors."
  (let ((first-luminance (chroma-generate-relative-luminance first))
        (second-luminance (chroma-generate-relative-luminance second)))
    (/ (+ (max first-luminance second-luminance) 0.05)
       (+ (min first-luminance second-luminance) 0.05))))

(defun chroma-generate--linear-rgb-bytes (rgb)
  "Return rounded 8-bit sRGB channels for linear RGB."
  (mapcar
   (lambda (channel)
     (max 0 (min 255
                 (round (* 255.0
                           (chroma-generate--srgb-channel channel))))))
   rgb))

(defun chroma-generate--bytes-hex (bytes)
  "Return three 8-bit RGB channel BYTES as a hexadecimal color."
  (apply #'format "#%02x%02x%02x" bytes))

(defun chroma-generate--oklab-distance (first second)
  "Return Euclidean OKLab distance between FIRST and SECOND triples."
  (sqrt (cl-loop for a in first
                 for b in second
                 sum (expt (- a b) 2))))

(defun chroma-generate--nearby-byte-colors (rgb &optional radius)
  "Return literal colors near linear RGB within byte RADIUS."
  (let* ((center (chroma-generate--linear-rgb-bytes rgb))
         (distance (or radius 1))
         result)
    (cl-loop for red from (max 0 (- (nth 0 center) distance))
             to (min 255 (+ (nth 0 center) distance)) do
             (cl-loop for green from (max 0 (- (nth 1 center) distance))
                      to (min 255 (+ (nth 1 center) distance)) do
                      (cl-loop for blue
                               from (max 0 (- (nth 2 center) distance))
                               to (min 255 (+ (nth 2 center) distance))
                               do (push (format "#%02x%02x%02x"
                                                red green blue)
                                        result))))
    (nreverse result)))

(defun chroma-generate--closest-oklab-hex (rgb target)
  "Return the nearby literal RGB color closest to OKLab TARGET."
  (car
   (sort (chroma-generate--nearby-byte-colors rgb)
         (lambda (first second)
           (let ((first-distance
                  (chroma-generate--oklab-distance
                   (chroma-generate-color-oklab first) target))
                 (second-distance
                  (chroma-generate--oklab-distance
                   (chroma-generate-color-oklab second) target)))
             (if (= first-distance second-distance)
                 (string< first second)
               (< first-distance second-distance)))))))

(defun chroma-generate-source-relative-color (source hue)
  "Generate a literal color from SOURCE on canonical HUE.

Preserve SOURCE's OKLab lightness and chroma.  If that point lies outside
sRGB, reduce only its chroma before deterministic 8-bit quantization."
  (pcase-let* ((`(,lightness ,source-chroma ,_source-hue)
                (chroma-generate-color-oklch source))
               (target-chroma
                (chroma-generate--maximum-chroma
                 lightness source-chroma hue))
               (radians (* float-pi (/ hue 180.0)))
               (target
                (list lightness
                      (* target-chroma (cos radians))
                      (* target-chroma (sin radians))))
               (rgb
                (chroma-generate--oklch-linear-rgb
                 lightness target-chroma hue)))
    (chroma-generate--closest-oklab-hex rgb target)))

(defun chroma-generate--contrast-target (source hue)
  "Return continuous in-gamut (L C RGB) data for SOURCE on HUE."
  (let* ((source-data (chroma-generate-color-oklch source))
         (source-chroma (nth 1 source-data))
         (source-luminance (chroma-generate-relative-luminance source))
         (low 0.0)
         (high 1.0)
         lightness chroma rgb)
    ;; Relative luminance is monotonic along the fixed-hue, maximum-available
    ;; chroma path between the black and white endpoints.
    (dotimes (_ 70)
      (setq lightness (/ (+ low high) 2.0)
            chroma (chroma-generate--maximum-chroma
                    lightness source-chroma hue)
            rgb (chroma-generate--oklch-linear-rgb
                 lightness chroma hue))
      (if (< (chroma-generate--linear-luminance rgb) source-luminance)
          (setq low lightness)
        (setq high lightness)))
    (setq lightness (/ (+ low high) 2.0)
          chroma (chroma-generate--maximum-chroma
                  lightness source-chroma hue)
          rgb (chroma-generate--oklch-linear-rgb lightness chroma hue))
    (list lightness chroma rgb)))

(defun chroma-generate-contrast-critical-color (source hue)
  "Generate a literal HUE color retaining SOURCE relative luminance."
  (pcase-let* ((`(,lightness ,chroma ,rgb)
                (chroma-generate--contrast-target source hue))
               (source-luminance
                (chroma-generate-relative-luminance source))
               (radians (* float-pi (/ hue 180.0)))
               (target-lab
                (list lightness
                      (* chroma (cos radians))
                      (* chroma (sin radians)))))
    (car
     (sort
      (chroma-generate--nearby-byte-colors rgb 2)
      (lambda (first second)
        (let ((first-luminance-error
               (abs (- (chroma-generate-relative-luminance first)
                       source-luminance)))
              (second-luminance-error
               (abs (- (chroma-generate-relative-luminance second)
                       source-luminance)))
              first-distance second-distance)
          (setq first-distance
                (chroma-generate--oklab-distance
                 (chroma-generate-color-oklab first) target-lab)
                second-distance
                (chroma-generate--oklab-distance
                 (chroma-generate-color-oklab second) target-lab))
          (cond
           ((and (< first-luminance-error
                    chroma-generate-luminance-quantization-tolerance)
                 (>= second-luminance-error
                     chroma-generate-luminance-quantization-tolerance))
            t)
           ((and (>= first-luminance-error
                     chroma-generate-luminance-quantization-tolerance)
                 (< second-luminance-error
                    chroma-generate-luminance-quantization-tolerance))
            nil)
           ((and (< first-luminance-error
                    chroma-generate-luminance-quantization-tolerance)
                 (< second-luminance-error
                    chroma-generate-luminance-quantization-tolerance)
                 (/= first-distance second-distance))
            (< first-distance second-distance))
           ((/= first-luminance-error second-luminance-error)
            (< first-luminance-error second-luminance-error))
           ((/= first-distance second-distance)
            (< first-distance second-distance))
           (t (string< first second)))))))))

(defun chroma-generate-palette-candidate (source method)
  "Generate all supported hue colors from SOURCE using METHOD.

METHOD is `source-relative' or `contrast-critical'.  The result is an
alist whose keys follow `chroma-supported-hues'."
  (let ((generator
         (pcase method
           ('source-relative #'chroma-generate-source-relative-color)
           ('contrast-critical
            #'chroma-generate-contrast-critical-color)
           (_ (user-error "Unknown Chroma generation method %S" method)))))
    (mapcar
     (lambda (hue)
       (cons hue
             (funcall generator source (alist-get hue chroma-hue-angles))))
     chroma-supported-hues)))

(defun chroma-generate--face-token (face attribute)
  "Return a dedicated generated token name for FACE and ATTRIBUTE."
  (intern (format "%s-%s"
                  face
                  (string-remove-prefix ":" (symbol-name attribute)))))

(defun chroma-generate--selector-angle (selector primary secondary)
  "Return the hue angle for SELECTOR under PRIMARY and SECONDARY."
  (alist-get (if (eq selector 'primary) primary secondary)
             chroma-hue-angles))

(defun chroma-generate--source-relative-selected-color
    (source selector primary secondary)
  "Transform SOURCE for SELECTOR under PRIMARY and SECONDARY."
  (if (eq selector 'neutral)
      source
    (chroma-generate-source-relative-color
     source
     (chroma-generate--selector-angle selector primary secondary))))

(defun chroma-generate--classification-observation
    (classification variant)
  "Return CLASSIFICATION's source observation for VARIANT."
  (seq-find
   (lambda (observation)
     (eq (plist-get observation :variant) variant))
   (plist-get classification :observations)))

(defun chroma-generate--pair-needs-critical-p (classifications)
  "Return non-nil when a direct color pair in CLASSIFICATIONS drifts."
  (let ((foreground
         (seq-find (lambda (entry)
                     (eq (plist-get entry :attribute) :foreground))
                   classifications))
        (background
         (seq-find (lambda (entry)
                     (eq (plist-get entry :attribute) :background))
                   classifications))
        needs-critical)
    (when (and foreground background)
      (dolist (variant chroma-supported-variants)
        (let ((source-foreground
               (chroma-generate--classification-observation
                foreground variant))
              (source-background
               (chroma-generate--classification-observation
                background variant)))
          (when (and source-foreground source-background)
            (let ((source-ratio
                   (chroma-generate-contrast-ratio
                    (plist-get source-foreground :color)
                    (plist-get source-background :color))))
              (dolist (primary chroma-supported-hues)
                (dolist (secondary chroma-supported-hues)
                  (let* ((candidate-foreground
                          (chroma-generate--source-relative-selected-color
                           (plist-get source-foreground :color)
                           (plist-get foreground :selector)
                           primary secondary))
                         (candidate-background
                          (chroma-generate--source-relative-selected-color
                           (plist-get source-background :color)
                           (plist-get background :selector)
                           primary secondary))
                         (candidate-ratio
                          (chroma-generate-contrast-ratio
                           candidate-foreground candidate-background)))
                    (when (>= (abs (- candidate-ratio source-ratio))
                              chroma-generate-contrast-difference-threshold)
                      (setq needs-critical t))))))))))
    needs-critical))

(defun chroma-generate--contrast-level (ratio)
  "Return the standard WCAG prominence level met by RATIO."
  (cond
   ((>= ratio 7.0) 3)
   ((>= ratio 4.5) 2)
   ((>= ratio 3.0) 1)
   (t 0)))

(defun chroma-generate--attribute-needs-critical-p (classification)
  "Return non-nil when CLASSIFICATION loses a main-surround contrast level."
  (let ((attribute (plist-get classification :attribute))
        (selector (plist-get classification :selector))
        needs-critical)
    (unless (eq selector 'neutral)
      (dolist (observation (plist-get classification :observations))
        (let* ((variant (plist-get observation :variant))
               (source (plist-get observation :color))
               (surround
                (chroma-palette-color
                 'neutral
                 (if (eq attribute :foreground) 'bg-main 'fg-main)
                 variant))
               (source-ratio
                (chroma-generate-contrast-ratio source surround)))
          (dolist (hue chroma-supported-hues)
            (let* ((candidate
                    (chroma-generate-source-relative-color
                     source (alist-get hue chroma-hue-angles)))
                   (candidate-ratio
                    (chroma-generate-contrast-ratio candidate surround)))
              (when (< (chroma-generate--contrast-level candidate-ratio)
                       (chroma-generate--contrast-level source-ratio))
                (setq needs-critical t)))))))
    needs-critical))

(defun chroma-generate--automatic-method
    (classification pair-needs-critical)
  "Choose a method for CLASSIFICATION and PAIR-NEEDS-CRITICAL state."
  (if (or pair-needs-critical
          (chroma-generate--attribute-needs-critical-p classification))
      'contrast-critical
    'source-relative))

(defun chroma-generate-face-plan (face &optional method)
  "Return a finite generated color plan for FACE.

METHOD defaults to `auto' and may be `source-relative' or
`contrast-critical'.  Automatic selection first tests a complete direct
foreground/background pair across all Primary and Secondary combinations.
For a lone attribute, it tests the source contrast against the corresponding
main neutral surround.  A paired candidate whose WCAG ratio drifts by
`chroma-generate-contrast-difference-threshold', or a lone candidate that
falls below an upstream WCAG 3.0, 4.5, or 7.0 level, becomes
contrast-critical.

The plan includes an automatic selector, confidence, a dedicated semantic
role and token for each directly colored attribute, and literal candidates
for every observed variant and supported hue.  It is a review artifact; it
does not mutate Chroma's runtime mappings or palette."
  (unless (facep face)
    (user-error "Unknown face %S" face))
  (unless (memq (or method 'auto)
                '(auto source-relative contrast-critical))
    (user-error "Unknown Chroma generation method %S" method))
  (let* ((requested-method (or method 'auto))
         (reference-faces
          (delete-dups (mapcar #'car (chroma-face-mappings))))
         (reference-observations
          (chroma-generate-source-observations reference-faces))
         (axis (chroma-generate-fit-source-axis reference-observations))
         (observations (chroma-generate-source-observations (list face)))
         (classifications
          (chroma-generate-classify-observations observations axis))
         (pair-needs-critical
          (chroma-generate--pair-needs-critical-p classifications))
         mapping semantic-roles attributes)
    (dolist (classification classifications)
      (let* ((attribute (plist-get classification :attribute))
             (selector (plist-get classification :selector))
             (token (chroma-generate--face-token face attribute))
             (role token)
             (generation-method
              (if (eq requested-method 'auto)
                  (chroma-generate--automatic-method
                   classification pair-needs-critical)
                requested-method))
             variants)
        (setq mapping (append mapping (list attribute role)))
        (push (list role selector token) semantic-roles)
        (dolist (observation (plist-get classification :observations))
          (let ((variant (plist-get observation :variant))
                (source (plist-get observation :color)))
            (push
             (cons variant
                   (if (eq selector 'neutral)
                       source
                     (chroma-generate-palette-candidate
                      source generation-method)))
             variants)))
        (push (list :attribute attribute
                    :selector selector
                    :confidence (plist-get classification :confidence)
                    :status (plist-get classification :status)
                    :token token
                    :method (unless (eq selector 'neutral)
                              generation-method)
                    :variants (nreverse variants))
              attributes)))
    (list :face face
          :source-axis axis
          :mapping (cons face mapping)
          :semantic-roles (nreverse semantic-roles)
          :attributes (nreverse attributes))))

(defun chroma-generate-print-face-plan (face &optional method)
  "Print the generated review plan for FACE using optional METHOD."
  (interactive
   (list (intern (completing-read "Face: " obarray #'facep t))
         (intern
          (completing-read
           "Method: " '("auto" "source-relative" "contrast-critical")
           nil t nil nil "auto"))))
  (chroma-generate-load-audited-built-ins)
  (let ((print-length nil)
        (print-level nil))
    (pp (chroma-generate-face-plan face method))))

(defun chroma-generate--source-attributes (face variant)
  "Return FACE's direct simple colors for display VARIANT."
  (modify-frame-parameters
   nil (list (cons 'display-type 'color)
             (cons 'background-mode variant)))
  (let ((attributes (face-spec-choose (get face 'face-defface-spec)))
        result)
    (dolist (attribute chroma-face-color-attributes)
      (let ((color (plist-get attributes attribute)))
        (when (stringp color)
          (push (cons attribute (chroma-generate-color-hex color)) result))))
    (nreverse result)))

(defun chroma-generate-source-observations (&optional faces)
  "Return direct upstream color observations for FACES.

FACES defaults to all currently defined faces.  Each observation records one
face, color attribute, display variant, literal source color, and its OKLCH
coordinates under Chroma's true-color display model."
  (let ((selected-faces (or faces (face-list)))
        (old-display-type (frame-parameter nil 'display-type))
        (old-background-mode (frame-parameter nil 'background-mode))
        observations)
    (unwind-protect
        (cl-letf (((symbol-function 'display-color-cells)
                   (lambda (&optional _frame) 16777216))
                  ((symbol-function 'window-system)
                   (lambda (&optional _frame) 'pgtk)))
          (dolist (face selected-faces)
            (when (and (facep face) (get face 'face-defface-spec))
              (dolist (variant chroma-supported-variants)
                (dolist (attribute-color
                         (chroma-generate--source-attributes face variant))
                  (pcase-let ((`(,lightness ,chroma ,hue)
                               (chroma-generate-color-oklch
                                (cdr attribute-color))))
                    (push (list :face face
                                :attribute (car attribute-color)
                                :variant variant
                                :color (cdr attribute-color)
                                :lightness lightness
                                :chroma chroma
                                :hue hue)
                          observations)))))))
      (modify-frame-parameters
       nil (list (cons 'display-type old-display-type)
                 (cons 'background-mode old-background-mode))))
    (sort observations
          (lambda (first second)
            (string< (format "%s/%s/%s"
                             (plist-get first :face)
                             (plist-get first :attribute)
                             (plist-get first :variant))
                     (format "%s/%s/%s"
                             (plist-get second :face)
                             (plist-get second :attribute)
                             (plist-get second :variant)))))))

(defun chroma-generate-fit-source-axis (observations)
  "Fit and return a Primary source hue axis for OBSERVATIONS.

The unoriented complementary axis is the principal circular axis obtained
from doubled hue angles.  Its more heavily chromatic half is oriented as
Primary, making the convention deterministic without interpreting names."
  (let ((sum-cos 0.0)
        (sum-sin 0.0))
    (dolist (observation observations)
      (let ((chroma (plist-get observation :chroma)))
        (when (> chroma chroma-generate-neutral-chroma-threshold)
          (let ((angle (* 2.0 float-pi
                          (/ (plist-get observation :hue) 180.0))))
            (setq sum-cos (+ sum-cos (* chroma (cos angle)))
                  sum-sin (+ sum-sin (* chroma (sin angle))))))))
    (when (and (= sum-cos 0.0) (= sum-sin 0.0))
      (user-error "No chromatic source observations to fit"))
    (let* ((axis
            (mod (* 0.5 180.0 (/ (atan sum-sin sum-cos) float-pi))
                 180.0))
           (positive 0.0)
           (negative 0.0))
      (dolist (observation observations)
        (let ((chroma (plist-get observation :chroma)))
          (when (> chroma chroma-generate-neutral-chroma-threshold)
            (let* ((difference
                    (* float-pi
                       (/ (- (plist-get observation :hue) axis) 180.0)))
                   (projection (* chroma (cos difference))))
              (if (>= projection 0.0)
                  (setq positive (+ positive projection))
                (setq negative (- negative projection)))))))
      (if (>= positive negative) axis (mod (+ axis 180.0) 360.0)))))

(defun chroma-generate--observation-groups (observations)
  "Group OBSERVATIONS by face and direct color attribute."
  (let (groups)
    (dolist (observation observations)
      (let ((key (cons (plist-get observation :face)
                       (plist-get observation :attribute))))
        (push observation (alist-get key groups nil nil #'equal))))
    (mapcar (lambda (group)
              (cons (car group) (nreverse (cdr group))))
            (nreverse groups))))

(defun chroma-generate-classify-observations (observations &optional axis)
  "Classify face color OBSERVATIONS along complementary source AXIS.

Return one plist per face and attribute.  Dark and light observations for the
same face attribute vote together.  Confidence is the absolute normalized
projection onto the fitted axis; opposing variant colors therefore surface
as low-confidence review cases rather than silently changing selector."
  (let ((source-axis (or axis
                         (chroma-generate-fit-source-axis observations)))
        results)
    (dolist (group (chroma-generate--observation-groups observations))
      (let ((projection 0.0)
            (weight 0.0)
            chromatic)
        (dolist (observation (cdr group))
          (let ((chroma (plist-get observation :chroma)))
            (when (> chroma chroma-generate-neutral-chroma-threshold)
              (setq chromatic t
                    weight (+ weight chroma)
                    projection
                    (+ projection
                       (* chroma
                          (cos (* float-pi
                                  (/ (- (plist-get observation :hue)
                                        source-axis)
                                     180.0)))))))))
        (let* ((selector
                (cond
                 ((not chromatic) 'neutral)
                 ((>= projection 0.0) 'primary)
                 (t 'secondary)))
               (confidence
                (if chromatic (/ (abs projection) weight) 1.0))
               (status
                (if (and chromatic
                         (< confidence
                            chroma-generate-low-confidence-threshold))
                    'needs-review
                  'automatic)))
          (push (list :face (car (car group))
                      :attribute (cdr (car group))
                      :selector selector
                      :confidence confidence
                      :status status
                      :axis source-axis
                      :observations (cdr group))
                results))))
    (nreverse results)))

(defun chroma-generate--mapping-role (source variant)
  "Return the semantic role in mapping SOURCE for VARIANT."
  (if (symbolp source) source (alist-get variant source)))

(defun chroma-generate--role-selector (role)
  "Return the palette selector for semantic ROLE."
  (nth 1 (assq role chroma-semantic-role-sources)))

(defun chroma-generate--mapped-selectors (mapping attribute)
  "Return MAPPING selectors used for ATTRIBUTE across supported variants."
  (let ((source (plist-get (cdr mapping) attribute)) selectors)
    (dolist (variant chroma-supported-variants)
      (let* ((role (chroma-generate--mapping-role source variant))
             (selector (and role
                            (chroma-generate--role-selector role))))
        (when selector (cl-pushnew selector selectors))))
    (nreverse selectors)))

(defun chroma-generate-audit-mappings (&optional mappings)
  "Audit reviewed face MAPPINGS against upstream color tendencies.

Return a plist containing the fitted `:axis' and one entry per directly
colored mapped attribute under `:entries'.  An entry is `accepted' when its
reviewed static selector agrees with the automatic classification,
`needs-review' when the source vote is ambiguous, and `differs' when the
reviewed semantic choice intentionally differs from the color tendency."
  (let* ((selected-mappings (or mappings (chroma-face-mappings)))
         (faces (delete-dups (mapcar #'car selected-mappings)))
         (observations (chroma-generate-source-observations faces))
         (axis (chroma-generate-fit-source-axis observations))
         (classifications
          (chroma-generate-classify-observations observations axis))
         entries)
    (dolist (classification classifications)
      (let* ((face (plist-get classification :face))
             (attribute (plist-get classification :attribute))
             (mapping (assq face selected-mappings))
             (mapped-selectors
              (chroma-generate--mapped-selectors mapping attribute))
             (automatic-selector
              (plist-get classification :selector))
             (classification-status
              (plist-get classification :status))
             (status
              (cond
               ((eq classification-status 'needs-review) 'needs-review)
               ((memq automatic-selector mapped-selectors) 'accepted)
               (t 'differs))))
        (push (append
               (list :status status :mapped-selectors mapped-selectors)
               classification)
              entries)))
    (list :axis axis :entries (nreverse entries))))

(defun chroma-generate-audit-loaded-faces (&optional mappings)
  "Audit MAPPINGS and report every unmapped loaded direct color.

Private Chroma proxy faces are excluded.  All other loaded faces with direct
simple upstream colors receive either the outcome from
`chroma-generate-audit-mappings' or an `unmapped' outcome suitable for a new
finite face plan."
  (let* ((selected-mappings (or mappings (chroma-face-mappings)))
         (reviewed (chroma-generate-audit-mappings selected-mappings))
         (axis (plist-get reviewed :axis))
         (faces
          (seq-remove
           (lambda (face)
             (string-prefix-p "chroma--base-" (symbol-name face)))
           (face-list)))
         (observations (chroma-generate-source-observations faces))
         (classifications
          (chroma-generate-classify-observations observations axis))
         (entries (copy-tree (plist-get reviewed :entries))))
    (dolist (classification classifications)
      (let ((face (plist-get classification :face))
            (attribute (plist-get classification :attribute)))
        (unless (seq-some
                 (lambda (entry)
                   (and (eq (plist-get entry :face) face)
                        (eq (plist-get entry :attribute) attribute)))
                 entries)
          (push (append (list :status 'unmapped :mapped-selectors nil)
                        classification)
                entries))))
    (list :axis axis
          :entries
          (sort entries
                (lambda (first second)
                  (string< (format "%s/%s"
                                   (plist-get first :face)
                                   (plist-get first :attribute))
                           (format "%s/%s"
                                   (plist-get second :face)
                                   (plist-get second :attribute))))))))

(defun chroma-generate-audit-summary (&optional audit)
  "Return status counts for mapping AUDIT."
  (let ((data (or audit (chroma-generate-audit-mappings))) counts)
    (dolist (entry (plist-get data :entries))
      (let ((status (plist-get entry :status)))
        (setf (alist-get status counts 0) (1+ (alist-get status counts 0)))))
    (nreverse counts)))

(defun chroma-generate--format-observations (observations)
  "Format source OBSERVATIONS for a selector audit line."
  (mapconcat
   (lambda (observation)
     (format "%s:%s"
             (plist-get observation :variant)
             (plist-get observation :color)))
   observations ","))

(defun chroma-generate-print-audit ()
  "Print the automatic selector audit and all review cases."
  (interactive)
  (chroma-generate-load-audited-built-ins)
  (let* ((audit (chroma-generate-audit-loaded-faces))
         (axis (plist-get audit :axis))
         (summary (chroma-generate-audit-summary audit)))
    (princ (format "Chroma source-color selector audit (Emacs %s)\n"
                   emacs-version))
    (princ (format "Primary source axis: %.2f degrees\n" axis))
    (princ (format "Summary: %S\n" summary))
    (dolist (entry (plist-get audit :entries))
      (unless (eq (plist-get entry :status) 'accepted)
        (princ
         (format "%s %s/%s auto=%s mapped=%S confidence=%.3f source=%s\n"
                 (upcase (symbol-name (plist-get entry :status)))
                 (plist-get entry :face)
                 (plist-get entry :attribute)
                 (plist-get entry :selector)
                 (plist-get entry :mapped-selectors)
                 (plist-get entry :confidence)
                 (chroma-generate--format-observations
                  (plist-get entry :observations))))))
    audit))

(provide 'chroma-generate)

;;; chroma-generate.el ends here
