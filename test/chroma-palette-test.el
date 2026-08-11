;;; chroma-palette-test.el --- Chroma palette tests  -*- lexical-binding: t; -*-

;;; Code:

(require 'ert)
(require 'chroma-palette)

(ert-deftest chroma-palette-main-backgrounds-are-black-and-white ()
  "Main backgrounds use the canonical dark and light endpoints."
  (should (equal (chroma-palette-color 'neutral 'bg-main 'dark)
                 "#000000"))
  (should (equal (chroma-palette-color 'neutral 'bg-main 'light)
                 "#ffffff")))

(ert-deftest chroma-palette-is-complete ()
  "Every shipped palette contains all required finite tokens."
  (should (equal (mapcar #'car chroma-palettes)
                 chroma-supported-variants))
  (dolist (variant-entry chroma-palettes)
    (let ((variant (car variant-entry)))
      (dolist (class-entry (cdr variant-entry))
        (let* ((display-class (car class-entry))
               (palette (chroma-palette-get variant display-class))
               (neutral (alist-get 'neutral palette)))
          (dolist (token chroma-palette-required-neutral-tokens)
            (should (stringp (alist-get token neutral))))
          (dolist (hue chroma-supported-hues)
            (let ((hue-data (alist-get hue palette)))
              (should hue-data)
              (dolist (token chroma-palette-required-hue-tokens)
                (should (stringp (alist-get token hue-data)))))))))))

(ert-deftest chroma-palette-hue-metadata-is-complete ()
  "Every supported hue has one canonical angle and complement."
  (should (equal (mapcar #'car chroma-hue-angles)
                 chroma-supported-hues))
  (should (equal (mapcar #'car chroma-primary-secondary-pairs)
                 chroma-supported-hues))
  (dolist (hue chroma-supported-hues)
    (let ((angle (alist-get hue chroma-hue-angles))
          (complement (alist-get hue chroma-primary-secondary-pairs)))
      (should (numberp angle))
      (should (>= angle 0.0))
      (should (< angle 360.0))
      (should (memq complement chroma-supported-hues)))))

(ert-deftest chroma-palette-colors-are-literal-hex-values ()
  "Palette leaves contain explicit six-digit hexadecimal colors."
  (dolist (variant-entry chroma-palettes)
    (dolist (class-entry (cdr variant-entry))
      (dolist (hue-entry (cdr class-entry))
        (dolist (token-entry (cdr hue-entry))
          (should (string-match-p
                   "\\`#[[:xdigit:]]\\{6\\}\\'"
                   (cdr token-entry))))))))

(ert-deftest chroma-palette-rejects-unknown-keys ()
  "Unknown palette coordinates fail explicitly."
  (should-error (chroma-palette-get 'sepia 'true-color)
                :type 'user-error)
  (should-error (chroma-palette-get 'dark 'color-256)
                :type 'user-error)
  (should-error (chroma-palette-color 'ultraviolet 'base)
                :type 'user-error)
  (should-error (chroma-palette-color 'blue 'unknown-token)
                :type 'user-error))

(provide 'chroma-palette-test)

;;; chroma-palette-test.el ends here
