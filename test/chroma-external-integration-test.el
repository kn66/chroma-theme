;;; chroma-external-integration-test.el --- External face integration  -*- lexical-binding: t; -*-

;;; Code:

(require 'ert)
(require 'cl-lib)
(require 'chroma-faces)

(defconst chroma-external-test--packages
  '((avy "0.5.0" "avy/avy.el")
    (corfu "2.10" "corfu/corfu.el")
    (diff-hl "1.10.0" "diff-hl/diff-hl.el")
    (magit "4.6.0" "magit/lisp/magit.el")
    (tempel "1.14" "tempel/tempel.el")
    (transient "0.13.5" "transient/lisp/transient.el")
    (vundo "2.4.0" "vundo/vundo.el"))
  "Audited package versions and their main source files.")

(defun chroma-external-test--root ()
  "Return the directory containing audited package checkouts."
  (let ((root (getenv "CHROMA_EXTERNAL_PACKAGES_DIR")))
    (unless (and root (file-directory-p root))
      (error "Set CHROMA_EXTERNAL_PACKAGES_DIR to audited checkouts"))
    (file-name-as-directory (expand-file-name root))))

(defun chroma-external-test--version (file)
  "Return the package version declared by FILE."
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (unless (re-search-forward
             "^;; \\(?:Package-\\)?Version:[ \t]+\\([^ \t\n]+\\)" nil t)
      (error "No version header in %s" file))
    (match-string 1)))

(defun chroma-external-test--source-files (directory)
  "Return package source files below DIRECTORY, excluding tests."
  (cl-remove-if
   (lambda (file)
     (or (string-match-p "/test/" file)
         (string-match-p "-test\\.el\\'" file)
         (string-prefix-p "." (file-name-nondirectory file))))
   (directory-files-recursively directory "\\.el\\'")))

(defun chroma-external-test--load-face-forms (file)
  "Evaluate top-level `defface' forms in FILE and return their names.
Initialize simple package variables first because a face specification may
splice a user option's default value into a backquoted specification."
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (let (faces forms form)
      (condition-case nil
          (while t
            (setq form (read (current-buffer)))
            (push form forms))
        (end-of-file))
      (setq forms (nreverse forms))
      (dolist (candidate forms)
        (when (and (memq (car-safe candidate)
                         '(defconst defcustom defvar))
                   (nthcdr 2 candidate)
                   (not (boundp (nth 1 candidate))))
          (condition-case nil
              (set (nth 1 candidate) (eval (nth 2 candidate) t))
            (error))))
      (dolist (candidate forms)
        (when (eq (car-safe candidate) 'defface)
          (eval candidate t)
          (push (nth 1 candidate) faces)))
      (nreverse faces))))

(defun chroma-external-test--direct-color-attributes (face mode)
  "Return FACE's direct simple color attributes for background MODE."
  (modify-frame-parameters
   nil (list (cons 'display-type 'color) (cons 'background-mode mode)))
  (let ((attributes (face-spec-choose (get face 'face-defface-spec)))
        result)
    (dolist (attribute chroma-face-color-attributes)
      (when (stringp (plist-get attributes attribute))
        (push attribute result)))
    result))

(defun chroma-external-test--load-package-faces ()
  "Load audited package face forms and return their unique names."
  (let ((root (chroma-external-test--root)) faces)
    (dolist (package chroma-external-test--packages)
      (let ((directory
             (expand-file-name (symbol-name (car package)) root)))
        (dolist (file (chroma-external-test--source-files directory))
          (dolist (face (chroma-external-test--load-face-forms file))
            (cl-pushnew face faces)))))
    faces))

(defun chroma-external-test--standard-color-hex (color)
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

(defun chroma-external-test--hex-channel (color offset)
  "Read a normalized RGB channel from COLOR at OFFSET."
  (/ (string-to-number (substring color offset (+ offset 2)) 16) 255.0))

(defun chroma-external-test--linear-channel (channel)
  "Convert an sRGB CHANNEL to its linear value."
  (if (<= channel 0.04045)
      (/ channel 12.92)
    (expt (/ (+ channel 0.055) 1.055) 2.4)))

(defun chroma-external-test--relative-luminance (color)
  "Return WCAG relative luminance for hexadecimal COLOR."
  (+ (* 0.2126
        (chroma-external-test--linear-channel
         (chroma-external-test--hex-channel color 1)))
     (* 0.7152
        (chroma-external-test--linear-channel
         (chroma-external-test--hex-channel color 3)))
     (* 0.0722
        (chroma-external-test--linear-channel
         (chroma-external-test--hex-channel color 5)))))

(defun chroma-external-test--contrast-ratio (first second)
  "Return the WCAG contrast ratio between FIRST and SECOND."
  (let ((first-luminance
         (chroma-external-test--relative-luminance first))
        (second-luminance
         (chroma-external-test--relative-luminance second)))
    (/ (+ (max first-luminance second-luminance) 0.05)
       (+ (min first-luminance second-luminance) 0.05))))

(ert-deftest chroma-external-audited-versions-are-exact ()
  "External integration fixtures are the documented audited versions."
  (let ((root (chroma-external-test--root)))
    (dolist (package chroma-external-test--packages)
      (should
       (equal (chroma-external-test--version
               (expand-file-name (nth 2 package) root))
              (nth 1 package))))))

(ert-deftest chroma-external-real-face-definitions-are-complete ()
  "Actual package faces have an explicit mapped or inherited outcome."
  (let* ((old-display-type (frame-parameter nil 'display-type))
         (old-background-mode (frame-parameter nil 'background-mode))
         (package-faces (chroma-external-test--load-package-faces))
         missing wrong-attributes wrongly-mapped bad-proxies)
    (unwind-protect
        (cl-letf (((symbol-function 'display-color-cells)
                   (lambda (&optional _frame) 16777216))
                  ((symbol-function 'window-system)
                   (lambda (&optional _frame) 'pgtk))
                  ((symbol-function 'display-supports-face-attributes-p)
                   (lambda (_attributes &optional _frame) t)))
          (chroma-build-face-specs)
          (dolist (face package-faces)
            (let ((mapping (chroma-face-mapping face))
                  direct-in-any-variant)
              (dolist (variant chroma-supported-variants)
                (let* ((direct-attributes
                        (chroma-external-test--direct-color-attributes
                         face variant))
                       (mapped
                        (and mapping
                             (chroma--resolve-face-attributes
                              mapping
                              (chroma-resolve-semantic-colors
                               'blue 'yellow variant)
                              variant)))
                       (mapped-attributes
                        (cl-loop for (attribute _color) on mapped
                                 by #'cddr collect attribute)))
                  (when direct-attributes
                    (setq direct-in-any-variant t))
                  (cond
                   ((and direct-attributes (null mapping))
                    (push (list face variant direct-attributes) missing))
                   ((not
                     (equal (sort mapped-attributes
                                  (lambda (a b)
                                    (string< (symbol-name a)
                                             (symbol-name b))))
                            (sort direct-attributes
                                  (lambda (a b)
                                    (string< (symbol-name a)
                                             (symbol-name b))))))
                    (push (list face variant mapped-attributes
                                direct-attributes)
                          wrong-attributes)))))
              (when (and mapping (null direct-in-any-variant))
                (push face wrongly-mapped))
              (when mapping
                (let ((proxy (chroma--base-face-symbol face)))
                  (unless (equal (get proxy 'face-defface-spec)
                                 (get face 'face-defface-spec))
                    (push face bad-proxies))))))
          (dolist (mapping (chroma-external-face-mappings))
            (should (memq (car mapping) package-faces))))
      (modify-frame-parameters
       nil (list (cons 'display-type old-display-type)
                 (cons 'background-mode old-background-mode))))
    (should-not missing)
    (should-not wrong-attributes)
    (should-not wrongly-mapped)
    (should-not bad-proxies)
    (should (= (length package-faces) 193))))

(ert-deftest chroma-external-direct-face-pairs-retain-source-contrast ()
  "Every external direct color pair retains upstream contrast."
  (chroma-external-test--load-package-faces)
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
        failures
        (pair-count 0))
    (unwind-protect
        (cl-letf (((symbol-function 'display-color-cells)
                   (lambda (&optional _frame) 16777216))
                  ((symbol-function 'window-system)
                   (lambda (&optional _frame) 'pgtk))
                  ((symbol-function 'display-supports-face-attributes-p)
                   (lambda (_attributes &optional _frame) t)))
          (dolist (mapping (chroma-external-face-mappings))
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
                       (source-foreground (plist-get source :foreground))
                       (source-background (plist-get source :background)))
                  (when (and (stringp source-foreground)
                             (stringp source-background))
                    (setq pair-count (1+ pair-count))
                    (let ((source-ratio
                           (chroma-external-test--contrast-ratio
                            (chroma-external-test--standard-color-hex
                             source-foreground)
                            (chroma-external-test--standard-color-hex
                             source-background))))
                      (dolist (entry color-sets)
                        (when (eq variant (nth 0 entry))
                          (let* ((attributes
                                  (chroma--resolve-face-attributes
                                   (cdr mapping) (nth 3 entry) variant))
                                 (candidate-ratio
                                  (chroma-external-test--contrast-ratio
                                   (plist-get attributes :foreground)
                                   (plist-get attributes :background)))
                                 (difference
                                  (abs (- candidate-ratio source-ratio))))
                            (when (>= difference 0.12)
                              (let* ((key (list (car mapping) variant))
                                     (existing
                                      (alist-get key failures nil nil
                                                 #'equal)))
                                (when (or (null existing)
                                          (> difference (nth 4 existing)))
                                  (setf (alist-get key failures nil nil
                                                   #'equal)
                                        (list (nth 1 entry) (nth 2 entry)
                                              source-ratio candidate-ratio
                                              difference))))))))))))))
      (modify-frame-parameters
       nil (list (cons 'display-type old-display-type)
                 (cons 'background-mode old-background-mode))))
    (when failures
      (message "External contrast failures: %S" failures))
    (should-not failures)
    (should (> pair-count 20)))))

(provide 'chroma-external-integration-test)

;;; chroma-external-integration-test.el ends here
