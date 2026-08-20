;;; chroma-theme.el --- Color-only theme preserving standard face design  -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Chroma Theme contributors

;; Author: Chroma Theme contributors
;; Version: 0.1.0
;; URL: https://github.com/kn66/.emacs.d/tree/main/lisp/chroma-theme
;; Package-Requires: ((emacs "30.1"))
;; Keywords: faces, theme

;; This file is part of Chroma Theme.

;; Chroma Theme is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;;; Commentary:

;; Chroma replaces only the color layer of built-in Emacs faces.  Structural
;; styling remains owned by Emacs and the libraries that define each face.

;;; Code:

(require 'chroma-core)
(require 'chroma-faces)
(require 'seq)

;;;###autoload
(when load-file-name
  ;; `custom-theme-load-path' does not expand its `t' entry to the normal
  ;; `load-path'.  Register this directory so loading Chroma as a library,
  ;; including via use-package `:load-path', also makes it discoverable by
  ;; `load-theme' and `custom-available-themes'.  The autoload cookie makes
  ;; installed packages register their directory before this file is loaded.
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory
                (file-name-directory load-file-name))))

;;;###theme-autoload
(deftheme chroma
  "Preserve standard Emacs face design while replacing its color layer."
  :kind 'color-scheme
  :background-mode chroma-variant)

(defvar chroma-theme--refreshing nil
  "Non-nil while Chroma theme specs are being refreshed.")

(defun chroma-theme--registered-faces ()
  "Return faces currently recorded in Chroma's theme settings."
  (let (faces)
    (dolist (setting (get 'chroma 'theme-settings))
      (when (eq (car setting) 'theme-face)
        (push (cadr setting) faces)))
    faces))

(defun chroma-theme--set-faces (&optional immediate mappings)
  "Register Chroma face specs, applying them when IMMEDIATE is non-nil.

MAPPINGS may select an incremental subset.  A partial refresh never treats
faces outside that subset as stale."
  (let* ((settings (chroma-build-face-specs nil mappings))
         (new-faces (mapcar #'car settings))
         (stale-faces
          (unless mappings
            (seq-difference (chroma-theme--registered-faces) new-faces))))
    ;; Keep color-scheme metadata synchronized for callers that inspect theme
    ;; properties.  The actual frame mode follows the explicit `default'
    ;; foreground and background applied below.
    (put 'chroma 'theme-properties
         (plist-put (copy-sequence (get 'chroma 'theme-properties))
                    :background-mode chroma-variant))
    ;; Refresh can remove an obsolete direct mapping after an upstream audit.
    ;; Drop such settings so the face resumes inheriting its standard parent.
    (dolist (face stale-faces)
      (custom-theme-reset-faces 'chroma (list face nil)))
    (apply #'custom-theme-set-faces
           'chroma
           (mapcar
            (lambda (setting)
              (if immediate
                  (append setting '(t))
                setting))
            settings))
    (when immediate
      (mapc #'custom-theme-recalc-face stale-faces))))

(defun chroma-theme--mappings-needing-refresh ()
  "Return mappings whose face or upstream proxy changed since registration."
  (let ((registered (chroma-theme--registered-faces)) dirty)
    (dolist (mapping (chroma-face-mappings))
      (let ((face (car mapping)))
        (when (and (facep face)
                   (or (not (memq face registered))
                       (and
                        (not (eq face 'default))
                        (not
                         (equal
                          (get (chroma--base-face-symbol face)
                               'face-defface-spec)
                          (get face 'face-defface-spec))))))
          (push mapping dirty))))
    (nreverse dirty)))

;;;###autoload
(defun chroma-theme-refresh ()
  "Rebuild Chroma face colors from the current user options.

Call this after changing `chroma-primary', `chroma-secondary', or
`chroma-variant' with `setq' while the theme is enabled.  Customize
changes refresh the theme automatically."
  (interactive)
  (unless chroma-theme--refreshing
    (let ((chroma-theme--refreshing t)
          (enabled (memq 'chroma custom-enabled-themes)))
      (chroma-theme--set-faces enabled))))

(defun chroma-theme--after-enable (theme)
  "Refresh current color options after THEME is enabled."
  (when (and (eq theme 'chroma)
             (not chroma-theme--refreshing))
    ;; Do not infer immediacy from `custom-enabled-themes' here: Emacs runs
    ;; this abnormal hook while `enable-theme' is still completing its state
    ;; transition on some supported versions.
    (let ((chroma-theme--refreshing t))
      (chroma-theme--set-faces t))))

(defun chroma-theme--after-load (_file)
  "Refresh changed Chroma mappings after loading _FILE."
  (when (and (memq 'chroma custom-enabled-themes)
             (not chroma-theme--refreshing))
    ;; `custom-theme-set-faces' records settings for a face defined during a
    ;; load, but Custom normally inhibits attaching new theme properties
    ;; until that load finishes.  Chroma is already enabled and trusted at
    ;; this point, so locally lift that internal guard.  Reenabling Chroma
    ;; here would unexpectedly change the precedence of multiple themes.
    (let ((mappings (chroma-theme--mappings-needing-refresh)))
      (when mappings
        (let ((chroma-theme--refreshing t)
              (custom--inhibit-theme-enable nil))
          (chroma-theme--set-faces t mappings))))))

(defun chroma-theme-unload-function ()
  "Remove Chroma's global hooks before unloading its feature."
  (remove-hook 'after-load-functions #'chroma-theme--after-load)
  (remove-hook 'enable-theme-functions #'chroma-theme--after-enable)
  nil)

(chroma-theme--set-faces)
(add-hook 'after-load-functions #'chroma-theme--after-load)
(add-hook 'enable-theme-functions #'chroma-theme--after-enable)

(provide-theme 'chroma)

;;; chroma-theme.el ends here
