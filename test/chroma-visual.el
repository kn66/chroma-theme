;;; chroma-visual.el --- Reproducible Chroma visual review  -*- lexical-binding: t; -*-

;;; Commentary:

;; Build representative real Emacs Lisp, Org, and Diff buffers, then export
;; the visible GUI frame through Cairo.  Run with `make visuals'.

;;; Code:

(require 'chroma-theme)
(require 'completion-preview)
(require 'diff-mode)
(require 'org)

(defconst chroma-visual--elisp-sample
  ";; Primary syntax, comments, strings, warning, and completion preview\n\
(defun chroma-preview (items)\n\
  \"Return visible ITEMS after a small transformation.\"\n\
  (let ((threshold 3))\n\
    (seq-filter (lambda (item) (> (length item) threshold)) items)))\n\n\
(chroma-preview '(\"azure\" \"red\" \"chartreuse\"))\n"
  "Emacs Lisp shown in the visual review frame.")

(defconst chroma-visual--org-sample
  "* TODO Audit package faces\n\
  DEADLINE: <2026-08-21 Fri>\n\
  - [X] Preserve upstream structure\n\
  - [ ] Inspect active and refined states\n\
** DONE Verify contrast\n\
   #+begin_src emacs-lisp\n\
   (setq chroma-primary 'blue)\n\
   #+end_src\n"
  "Org text shown in the visual review frame.")

(defconst chroma-visual--diff-sample
  "diff --git a/theme.el b/theme.el\n\
index 1111111..2222222 100644\n\
--- a/theme.el\n\
+++ b/theme.el\n\
@@ -1,4 +1,4 @@\n\
-(setq accent 'upstream-red)\n\
+(setq accent chroma-primary)\n\
 (message \"structure remains upstream-owned\")\n"
  "Unified diff shown in the visual review frame.")

(defun chroma-visual--buffer (name mode contents)
  "Return buffer NAME initialized with MODE and CONTENTS."
  (let ((buffer (get-buffer-create name)))
    (with-current-buffer buffer
      (erase-buffer)
      (insert contents)
      (funcall mode)
      (font-lock-ensure)
      (goto-char (point-min)))
    buffer))

(defun chroma-visual--arrange-frame ()
  "Arrange representative real buffers in the selected frame."
  (set-frame-size nil 118 42)
  (delete-other-windows)
  (let* ((code
          (chroma-visual--buffer
           "*Chroma Emacs Lisp*" #'emacs-lisp-mode
           chroma-visual--elisp-sample))
         (org
          (chroma-visual--buffer
           "*Chroma Org*" #'org-mode chroma-visual--org-sample))
         (diff
          (chroma-visual--buffer
           "*Chroma Diff*" #'diff-mode chroma-visual--diff-sample))
         (left (selected-window))
         (right (split-window-right))
         (lower-right (split-window right nil 'below)))
    (set-window-buffer left code)
    (set-window-buffer right org)
    (set-window-buffer lower-right diff)
    (with-current-buffer code
      (goto-char (point-max))
      (insert "\n")
      (insert (propertize "completion-preview-common"
                          'face 'completion-preview-common)))
    (select-window left)))

(defun chroma-visual-export (directory)
  "Export dark and light review frames as PNG files in DIRECTORY."
  (unless (display-graphic-p)
    (user-error "Chroma visual export requires a graphical Emacs frame"))
  (make-directory directory t)
  (chroma-visual--arrange-frame)
  (setq chroma-primary 'blue
        chroma-secondary 'auto)
  (dolist (variant chroma-supported-variants)
    (setq chroma-variant variant)
    (load-theme 'chroma t)
    (chroma-theme-refresh)
    (redisplay t)
    (let ((file (expand-file-name
                 (format "chroma-%s.png" variant) directory))
          (coding-system-for-write 'binary))
      ;; PNG also works with Emacs builds using the X font backend, whose
      ;; Cairo vector exports otherwise contain hollow or missing glyphs.
      (write-region (x-export-frames nil 'png) nil file nil 'silent)))
  (kill-emacs 0))

(provide 'chroma-visual)

;;; chroma-visual.el ends here
