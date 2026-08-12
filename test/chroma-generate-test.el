;;; chroma-generate-test.el --- Chroma generation tests  -*- lexical-binding: t; -*-

;;; Code:

(require 'ert)
(require 'cl-lib)
(require 'chroma-generate)

(defconst chroma-generate-test--project-directory
  (expand-file-name ".." (file-name-directory
                           (or load-file-name buffer-file-name)))
  "Chroma project directory used by generator tests.")

(defun chroma-generate-test--hue-distance (first second)
  "Return the shortest hue distance between FIRST and SECOND."
  (abs (- (mod (+ (- first second) 180.0) 360.0) 180.0)))

(ert-deftest chroma-generate-normalizes-upstream-color-names ()
  "Named upstream colors become deterministic literal palette leaves."
  (should (equal (chroma-generate-color-hex "dark cyan") "#008b8b"))
  (should (equal (chroma-generate-color-hex "#Aa22Ff") "#aa22ff"))
  (should-error (chroma-generate-color-hex 'red) :type 'user-error))

(ert-deftest chroma-generate-source-relative-candidates-preserve-oklch ()
  "Source-relative candidates keep lightness and maximum available chroma."
  (let* ((source "#aa2222")
         (source-data (chroma-generate-color-oklch source))
         (source-lightness (nth 0 source-data))
         (source-chroma (nth 1 source-data)))
    (dolist (hue chroma-supported-hues)
      (let* ((angle (alist-get hue chroma-hue-angles))
             (candidate
              (chroma-generate-source-relative-color source angle))
             (actual (chroma-generate-color-oklch candidate))
             (maximum-chroma
              (chroma-generate--maximum-chroma
               source-lightness source-chroma angle)))
        (should (string-match-p
                 "\\`#[[:xdigit:]]\\{6\\}\\'" candidate))
        (should (< (abs (- (nth 0 actual) source-lightness)) 0.004))
        (should (< (abs (- (nth 1 actual) maximum-chroma)) 0.004))
        (when (>= (nth 1 actual) chroma-generate-neutral-chroma-threshold)
          (should (< (chroma-generate-test--hue-distance
                      (nth 2 actual) angle)
                     2.0)))))))

(ert-deftest chroma-generate-contrast-candidates-preserve-luminance ()
  "Contrast-critical candidates retain source luminance on every hue axis."
  (dolist (source '("#ff0000" "#ff8c00" "#0000cd"))
    (let* ((source-data (chroma-generate-color-oklch source))
           (source-chroma (nth 1 source-data))
           (source-luminance
            (chroma-generate-relative-luminance source)))
      (dolist (hue chroma-supported-hues)
        (let* ((angle (alist-get hue chroma-hue-angles))
               (candidate
                (chroma-generate-contrast-critical-color source angle))
               (actual (chroma-generate-color-oklch candidate))
               (maximum-chroma
                (chroma-generate--maximum-chroma
                 (nth 0 actual) source-chroma angle)))
          (should (< (abs (- (chroma-generate-relative-luminance candidate)
                             source-luminance))
                     chroma-generate-luminance-quantization-tolerance))
          (should (< (abs (- (nth 1 actual) maximum-chroma)) 0.008))
          (when (>= (nth 1 actual) chroma-generate-neutral-chroma-threshold)
            (should (< (chroma-generate-test--hue-distance
                        (nth 2 actual) angle)
                       2.0))))))))

(ert-deftest chroma-generate-palette-candidates-are-complete ()
  "A generated finite row covers every supported hue exactly once."
  (dolist (method '(source-relative contrast-critical))
    (let ((candidate
           (chroma-generate-palette-candidate "#b22222" method)))
      (should (equal (mapcar #'car candidate) chroma-supported-hues))
      (dolist (entry candidate)
        (should (string-match-p
                 "\\`#[[:xdigit:]]\\{6\\}\\'" (cdr entry)))))))

(ert-deftest chroma-generate-classifier-joins-variants-and-surfaces-conflict ()
  "Variant votes are joined and opposing source hues require review."
  (let* ((observations
          '((:face warm :attribute :foreground :variant dark
             :color "#ff0000" :lightness 0.6 :chroma 0.2 :hue 20.0)
            (:face warm :attribute :foreground :variant light
             :color "#ff8800" :lightness 0.7 :chroma 0.2 :hue 30.0)
            (:face cool :attribute :foreground :variant dark
             :color "#00ffff" :lightness 0.8 :chroma 0.2 :hue 200.0)
            (:face cool :attribute :foreground :variant light
             :color "#008888" :lightness 0.5 :chroma 0.2 :hue 200.0)
            (:face crossing :attribute :background :variant dark
             :color "#ff0000" :lightness 0.6 :chroma 0.2 :hue 20.0)
            (:face crossing :attribute :background :variant light
             :color "#00ffff" :lightness 0.8 :chroma 0.2 :hue 200.0)
            (:face gray :attribute :foreground :variant dark
             :color "#777777" :lightness 0.5 :chroma 0.0 :hue 0.0)))
         (results
          (chroma-generate-classify-observations observations 20.0))
         (warm (seq-find (lambda (entry)
                           (eq (plist-get entry :face) 'warm))
                         results))
         (cool (seq-find (lambda (entry)
                           (eq (plist-get entry :face) 'cool))
                         results))
         (crossing (seq-find (lambda (entry)
                               (eq (plist-get entry :face) 'crossing))
                             results))
         (gray (seq-find (lambda (entry)
                           (eq (plist-get entry :face) 'gray))
                         results)))
    (should (eq (plist-get warm :selector) 'primary))
    (should (eq (plist-get cool :selector) 'secondary))
    (should (eq (plist-get crossing :status) 'needs-review))
    (should (eq (plist-get gray :selector) 'neutral))
    (should (= (length (plist-get crossing :observations)) 2))))

(ert-deftest chroma-generate-extracts-only-direct-simple-colors ()
  "Upstream extraction records simple colors and ignores structure."
  (require 'diff-mode)
  (let ((observations
         (chroma-generate-source-observations
          '(diff-added diff-hunk-header))))
    (should
     (seq-some
      (lambda (entry)
        (and (eq (plist-get entry :face) 'diff-added)
             (eq (plist-get entry :attribute) :background)))
      observations))
    (should-not
     (seq-some
      (lambda (entry)
        (eq (plist-get entry :face) 'diff-hunk-header))
      observations))
    (dolist (entry observations)
      (should (memq (plist-get entry :attribute)
                    chroma-face-color-attributes))
      (should (string-match-p
               "\\`#[[:xdigit:]]\\{6\\}\\'"
               (plist-get entry :color))))))

(ert-deftest chroma-generate-face-plan-is-finite-and-non-mutating ()
  "Face plans contain reviewable finite data without changing runtime data."
  (require 'diff-mode)
  (let* ((before-mapping (copy-tree (chroma-face-mapping 'diff-added)))
         (before-palettes (copy-tree chroma-palettes))
         (plan (chroma-generate-face-plan 'diff-added))
         (attribute (car (plist-get plan :attributes))))
    (should (equal (plist-get plan :mapping)
                   '(diff-added :background diff-added-background)))
    (should (equal (plist-get plan :semantic-roles)
                   '((diff-added-background primary
                      diff-added-background))))
    (should (eq (plist-get attribute :status) 'needs-review))
    (should (eq (plist-get attribute :method) 'source-relative))
    (dolist (variant (plist-get attribute :variants))
      (should (memq (car variant) chroma-supported-variants))
      (should (equal (mapcar #'car (cdr variant))
                     chroma-supported-hues)))
    (should (equal before-mapping (chroma-face-mapping 'diff-added)))
    (should (equal before-palettes chroma-palettes))))

(ert-deftest chroma-generate-auto-method-protects-direct-color-pairs ()
  "Automatic plans make a drifting direct foreground/background pair critical."
  (require 'isearch)
  (let ((attributes
         (plist-get (chroma-generate-face-plan 'isearch) :attributes)))
    (should (= (length attributes) 2))
    (dolist (attribute attributes)
      (should (eq (plist-get attribute :method) 'contrast-critical)))))

(ert-deftest chroma-generate-audit-covers-reviewed-direct-mappings ()
  "The audit gives every extracted mapped color an explicit outcome."
  (chroma-generate-load-audited-built-ins)
  (let* ((audit (chroma-generate-audit-loaded-faces))
         (entries (plist-get audit :entries))
         (summary (chroma-generate-audit-summary audit)))
    (should (numberp (plist-get audit :axis)))
    (should (> (length entries) 250))
    (should (= (length entries)
               (apply #'+ (mapcar #'cdr summary))))
    (dolist (entry entries)
      (should (memq (plist-get entry :status)
                    '(accepted reviewed differs needs-review unmapped)))
      (should (memq (plist-get entry :selector)
                    '(neutral primary secondary)))
      (should (plist-get entry :mapped-selectors)))
    ;; One recorded decision is just above the confidence boundary after ERT
    ;; joins the fitted source axis; all decisions remain explicit.
    (should (= (length chroma-generate-reviewed-low-confidence-selectors)
               57))
    (should (= (alist-get 'reviewed summary 0) 56))
    (should-not (alist-get 'needs-review summary))
    (should-not (alist-get 'unmapped summary))))

(ert-deftest chroma-generate-reviewed-selectors-match-static-mappings ()
  "Every recorded low-confidence decision matches its face mapping."
  (let (seen)
    (dolist (decision chroma-generate-reviewed-low-confidence-selectors)
      (let* ((key (car decision))
             (face (car key))
             (attribute (cdr key))
             (selector (cdr decision))
             (mapping (cons face (chroma-face-mapping face))))
        (should-not (member key seen))
        (push key seen)
        (should (memq selector
                      (chroma-generate--mapped-selectors
                       mapping attribute)))))))

(ert-deftest chroma-runtime-does-not-load-generator ()
  "The theme runtime remains independent from development-time generation."
  (with-temp-buffer
    (insert-file-contents
     (expand-file-name "chroma-theme.el"
                       chroma-generate-test--project-directory))
    (should-not (re-search-forward
                 "(require 'chroma-generate)" nil t))))

(provide 'chroma-generate-test)

;;; chroma-generate-test.el ends here
