;;; chroma-faces.el --- Chroma face mappings  -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Chroma Theme contributors

;; Author: Chroma Theme contributors
;; Keywords: faces
;; Package-Requires: ((emacs "28.1"))

;; This file is part of Chroma Theme.

;; Chroma Theme is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;;; Commentary:

;; Each mapping below says only which semantic color a face uses.  Mapping
;; values never contain literal colors.  Chroma deliberately does not set
;; structural attributes such as weight, slant, height, inheritance, or box
;; geometry.
;;
;; Composite attributes such as `:underline' and `:box' may embed a color,
;; but a theme face spec cannot safely merge only that nested color with the
;; structural value owned by Emacs.  This release therefore leaves those
;; attributes entirely to their defining libraries.

;;; Code:

(require 'button)
(require 'font-lock)
(require 'chroma-core)
(require 'chroma-faces-external)

(defconst chroma-face-color-attributes '(:foreground :background)
  "Face attributes Chroma mappings are allowed to set.")

(defconst chroma-face-mappings-basic
  '((default :foreground fg-main :background bg-main)
    (cursor :background primary-emphasis)
    (region :background selection)
    (secondary-selection :background alternate-selection)
    (highlight :background primary-refinement)
    (shadow :foreground fg-muted)
    (link :foreground link)
    (link-visited :foreground visited-link)
    (button :foreground link)
    (error :foreground error)
    (warning :foreground warning)
    (success :foreground success)
    (escape-glyph :foreground secondary-polarity-strong)
    (homoglyph :foreground secondary-polarity-strong)
    (nobreak-hyphen :foreground secondary-polarity-strong)
    (nobreak-space :foreground secondary-polarity-strong)
    (trailing-whitespace :background error-alert))
  "Color mappings for fundamental Emacs faces.")

(defconst chroma-face-mappings-font-lock
  '((font-lock-builtin-face :foreground primary-emphasis)
    (font-lock-comment-face :foreground primary)
    (font-lock-constant-face :foreground secondary-vivid)
    (font-lock-function-name-face :foreground primary-emphasis)
    (font-lock-keyword-face :foreground primary-vivid)
    (font-lock-string-face :foreground secondary-emphasis)
    (font-lock-type-face :foreground primary-vivid)
    (font-lock-variable-name-face :foreground secondary-vivid))
  "Color mappings for Font Lock faces with explicit standard colors.")

(defconst chroma-face-mappings-ui
  '((mode-line :foreground fg-on-bright :background bg-mode-line)
    (mode-line-active :foreground fg-on-bright :background bg-mode-line)
    (mode-line-inactive :foreground fg-main :background bg-panel)
    (header-line :foreground fg-main :background bg-panel)
    (minibuffer-prompt :foreground primary-emphasis)
    (fringe :foreground fg-main :background bg-main)
    (window-divider :foreground window-divider)
    (window-divider-first-pixel :foreground border-leading)
    (window-divider-last-pixel :foreground border-trailing)
    (line-number :foreground fg-muted :background bg-main)
    (line-number-major-tick :background bg-mode-line)
    (line-number-minor-tick :background bg-ui-inactive)
    (hl-line :background primary-refinement)
    (fill-column-indicator :foreground fg-fill-column)
    (tab-bar :foreground fg-on-bright :background bg-ui)
    (tab-bar-tab-inactive
     :foreground fg-on-bright :background bg-ui-inactive)
    (tab-line :foreground fg-on-bright :background bg-ui)
    (tab-line-tab-inactive
     :foreground fg-on-bright :background bg-ui-inactive)
    (tab-line-highlight :foreground fg-on-bright :background bg-ui)
    (tab-line-close-highlight :foreground error))
  "Color mappings for built-in Emacs user-interface faces.")

(defconst chroma-face-mappings-search
  '((match :background match)
    (lazy-highlight :background alternate-selection)
    (isearch :foreground bg-main :background search)
    (isearch-fail :background error-muted)
    (isearch-group-1
     :foreground primary-search-group-1-foreground
     :background primary-search-group-1-background)
    (isearch-group-2
     :foreground secondary-search-group-2-foreground
     :background secondary-search-group-2-background)
    (query-replace :foreground bg-main :background search)
    (show-paren-match :background secondary-refinement)
    (show-paren-mismatch
     :foreground fg-fixed-light :background primary-fixed-dark))
  "Color mappings for search, match, and parenthesis faces.")

(defconst chroma-face-mappings-completion
  '((completions-annotations :foreground fg-dim)
    (completions-common-part :foreground primary-emphasis)
    (minibuffer-completion-active :background primary-muted))
  "Color mappings for built-in completion faces.")

(defconst chroma-face-mappings-diagnostics
  '((compilation-error :foreground error)
    (compilation-warning :foreground warning)
    (compilation-info :foreground info)
    (compilation-mode-line-exit :foreground success)
    (compilation-mode-line-fail :foreground error))
  "Color mappings for built-in diagnostic faces.")

(defconst chroma-face-mappings-diff
  '((diff-added :background success-muted)
    (diff-removed :background error-muted)
    (diff-header :background bg-panel)
    (diff-file-header :background bg-ui-inactive)
    (diff-hunk-header :background bg-panel)
    (diff-indicator-added :foreground secondary-indicator-added)
    (diff-indicator-removed :foreground primary-indicator-removed)
    (diff-indicator-changed :foreground secondary-changed-indicator)
    (diff-refine-added :background success-refinement)
    (diff-refine-removed :background primary-fine-a)
    (diff-refine-changed :background secondary-fine-c)
    (diff-error :foreground primary-alert :background bg-main))
  "Color mappings for built-in Diff mode faces.")

(defconst chroma-face-mappings-ediff
  '((ediff-current-diff-A :background primary-current-a)
    (ediff-current-diff-Ancestor :background primary-current-ancestor)
    (ediff-current-diff-B :background secondary-current-b)
    (ediff-current-diff-C :background secondary-current-c)
    (ediff-fine-diff-A :background primary-fine-a)
    (ediff-fine-diff-Ancestor :background primary-fine-ancestor)
    (ediff-fine-diff-B :background secondary-fine-b)
    (ediff-fine-diff-C :background secondary-fine-c))
  "Color mappings for built-in Ediff faces.")

(defconst chroma-face-mappings-ansi
  '((ansi-color-red
     :foreground primary-ansi-mid :background primary-ansi-mid)
    (ansi-color-bright-red
     :foreground primary-ansi-mid-bright
     :background primary-ansi-mid-bright)
    (ansi-color-blue
     :foreground primary-ansi-low :background primary-ansi-low)
    (ansi-color-bright-blue
     :foreground primary-ansi-low-bright
     :background primary-ansi-low-bright)
    (ansi-color-cyan
     :foreground primary-ansi-high :background primary-ansi-high)
    (ansi-color-bright-cyan
     :foreground primary-ansi-vivid :background primary-ansi-vivid)
    (ansi-color-green
     :foreground secondary-ansi-upper :background secondary-ansi-upper)
    (ansi-color-bright-green
     :foreground secondary-ansi-high :background secondary-ansi-high)
    (ansi-color-yellow
     :foreground secondary-ansi-upper-bright
     :background secondary-ansi-upper-bright)
    (ansi-color-bright-yellow
     :foreground secondary-ansi-vivid
     :background secondary-ansi-vivid)
    (ansi-color-magenta
     :foreground secondary-ansi-mid :background secondary-ansi-mid)
    (ansi-color-bright-magenta
     :foreground secondary-ansi-mid-bright
     :background secondary-ansi-mid-bright))
  "Color mappings for built-in ANSI color faces.")

(defconst chroma-face-mappings-custom
  '((custom-button-pressed-unraised :foreground secondary)
    (custom-changed :foreground bg-main :background primary)
    (custom-comment-tag :foreground primary-strong)
    (custom-group-tag :foreground primary-emphasis)
    (custom-group-tag-1 :foreground secondary-status-error)
    (custom-invalid
     :foreground secondary-ansi-vivid :background primary-alert)
    (custom-modified :foreground bg-main :background primary)
    (custom-rogue
     :foreground secondary-ansi-high :background bg-fixed-dark)
    (custom-set :foreground primary :background bg-main)
    (custom-state :foreground secondary)
    (custom-themed :foreground bg-main :background primary)
    (custom-variable-obsolete :foreground primary-emphasis)
    (custom-variable-tag :foreground primary-emphasis)
    (widget-button-pressed :foreground primary-alert)
    (widget-documentation :foreground secondary))
  "Color mappings for built-in Customize and Widget faces.")

(defconst chroma-face-mappings-org
  '((org-agenda-done :foreground success)
    (org-agenda-restriction-lock :background bg-subtle)
    (org-agenda-structure :foreground primary-emphasis)
    (org-clock-overlay :foreground fg-main :background alternate-selection)
    (org-date :foreground primary-status-success)
    (org-date-selected :foreground error)
    (org-dispatcher-highlight
     :foreground primary-emphasis :background primary-muted)
    (org-document-info :foreground primary-strong)
    (org-document-title :foreground primary-strong)
    (org-done :foreground success)
    (org-drawer :foreground secondary)
    (org-ellipsis :foreground secondary-polarity)
    (org-footnote :foreground primary-status-success)
    (org-formula :foreground primary)
    (org-headline-done :foreground secondary-polarity)
    (org-headline-todo :foreground primary)
    (org-latex-and-related :foreground secondary)
    (org-mode-line-clock-overrun :background error-alert)
    (org-scheduled :foreground success)
    (org-scheduled-previously :foreground primary)
    (org-scheduled-today :foreground success)
    (org-sexp-date :foreground primary-status-success)
    (org-table :foreground secondary)
    (org-time-grid :foreground secondary-polarity)
    (org-todo :foreground error)
    (org-upcoming-deadline :foreground primary))
  "Color mappings for Org faces with explicit standard colors.")

(defconst chroma-face-mappings-misc
  '((blink-matching-paren-offscreen :foreground secondary-ansi-vivid)
    (elisp-shorthand-font-lock-face :foreground primary-ansi-vivid)
    (pulse-highlight-face :background primary-refinement)
    (pulse-highlight-start-face :background primary-refinement)
    (sh-heredoc :foreground secondary-ansi-vivid)
    (sh-quoted-exec :foreground primary-alert))
  "Color mappings for miscellaneous built-in chromatic faces.")

(defconst chroma-face-mappings-tools
  '((dired-broken-symlink
     :foreground secondary-ansi-vivid :background primary-alert)
    (dired-directory :foreground primary-emphasis)
    (dired-flagged :foreground error)
    (dired-header :foreground primary-status-success)
    (dired-ignored :foreground fg-muted)
    (dired-mark :foreground secondary-status-success)
    (dired-marked :foreground primary-status-warning)
    (dired-perm-write :foreground secondary)
    (dired-set-id :foreground secondary-status-error)
    (dired-special :foreground secondary-emphasis)
    (dired-symlink :foreground primary-polarity-strong)
    (help-key-binding :foreground primary-emphasis :background bg-subtle)
    (info-menu-star :foreground primary-alert)
    (diary :foreground secondary-status-success)
    (holiday :background warning-muted)
    (whitespace-space :foreground fg-fixed-gray
                      :background secondary-muted)
    (whitespace-hspace :foreground fg-fixed-gray
                       :background secondary-muted)
    (whitespace-tab :foreground fg-fixed-gray
                    :background secondary-muted)
    (whitespace-newline :foreground fg-fixed-gray)
    (whitespace-trailing
     :foreground secondary-ansi-vivid :background primary-alert)
    (whitespace-empty
     :foreground primary-fixed-dark :background secondary-ansi-vivid)
    (whitespace-indentation :foreground primary
                            :background primary-muted)
    (whitespace-space-after-tab
     :foreground primary-fixed-dark :background secondary-ansi-vivid)
    (whitespace-space-before-tab
     :foreground primary-fixed-dark :background warning)
    (whitespace-big-indent
     :foreground primary-whitespace-big-foreground
     :background primary-alert)
    (whitespace-line :foreground secondary :background bg-subtle)
    (whitespace-missing-newline-at-eof
     :foreground fg-main :background secondary-muted))
  "Color mappings for selected built-in tool faces.")

(defconst chroma-face-mappings-message
  '((message-header-cc :foreground primary-strong)
    (message-header-name :foreground primary-polarity)
    (message-header-newsgroups :foreground primary-strong)
    (message-header-other :foreground primary)
    (message-header-subject :foreground primary-strong)
    (message-header-to :foreground primary-strong)
    (message-header-xheader :foreground secondary-emphasis)
    (message-mml :foreground secondary-status-success)
    (message-separator :foreground primary-emphasis))
  "Color mappings for Message mode faces with explicit colors.")

(defconst chroma-face-mappings-merge
  '((smerge-base :background secondary-current-c)
    (smerge-lower :background success-muted)
    (smerge-markers :background bg-highlight)
    (smerge-refined-added :background secondary-fine-b)
    (smerge-refined-removed :background primary-fine-a)
    (smerge-upper :background error-muted))
  "Color mappings for Smerge conflict faces.")

(defconst chroma-face-mappings-applications
  '((bookmark-face :foreground warning)
    (edmacro-label :foreground primary-emphasis)
    (epa-field-body :foreground primary-dark-only)
    (epa-field-name :foreground primary-dark-only-emphasis)
    (epa-mark :foreground error)
    (epa-string :foreground primary-strong)
    (epa-validity-high :foreground secondary-dark-only-emphasis)
    (epa-validity-medium :foreground secondary-dark-only-emphasis)
    (eshell-prompt :foreground primary-emphasis)
    (eww-invalid-certificate :foreground primary-alert)
    (eww-valid-certificate :foreground secondary-steady)
    (shr-mark :foreground fg-on-bright
              :background secondary-ansi-vivid)
    (shr-selected-link
     :foreground primary-selected-link :background error-alert)
    (speedbar-button-face :foreground secondary)
    (speedbar-directory-face :foreground primary-emphasis)
    (speedbar-file-face :foreground primary-status-success)
    (speedbar-highlight-face :background alternate-selection)
    (speedbar-selected-face :foreground primary-alert)
    (speedbar-separator-face :foreground bg-main :background primary)
    (speedbar-tag-face :foreground secondary-polarity-strong)
    (tty-menu-disabled-face
     :foreground fg-fixed-light-gray :background primary-ansi-low)
    (tty-menu-enabled-face :foreground bg-main :background primary)
    (tty-menu-selected-face
     :foreground fg-main :background secondary-alert))
  "Color mappings for selected built-in application faces.")

(defconst chroma--true-color-display
  '((class color) (min-colors 16777216))
  "Face display condition supported by the initial release.")

(defun chroma-face-mappings ()
  "Return all Chroma face-to-semantic-role mappings."
  (append chroma-face-mappings-basic
          chroma-face-mappings-font-lock
          chroma-face-mappings-ui
          chroma-face-mappings-search
          chroma-face-mappings-completion
          chroma-face-mappings-diagnostics
          chroma-face-mappings-diff
          chroma-face-mappings-ediff
          chroma-face-mappings-ansi
          chroma-face-mappings-custom
          chroma-face-mappings-org
          chroma-face-mappings-misc
          chroma-face-mappings-tools
          chroma-face-mappings-message
          chroma-face-mappings-merge
          chroma-face-mappings-applications
          (chroma-external-face-mappings)))

(defun chroma-face-mapping (face)
  "Return the semantic color mapping for FACE, or nil if absent."
  (cdr (assq face (chroma-face-mappings))))

(defun chroma--resolve-face-attributes (mapping colors)
  "Resolve a face MAPPING using semantic role alist COLORS."
  (let (attributes)
    (while mapping
      (let* ((attribute (pop mapping))
             (role (pop mapping))
             (color (alist-get role colors)))
        (unless (memq attribute chroma-face-color-attributes)
          (error "Chroma mapping uses non-color attribute %S" attribute))
        (unless color
          (error "Chroma mapping refers to unknown semantic role %S" role))
        (setq attributes (append attributes (list attribute color)))))
    attributes))

(defun chroma-build-face-specs (&optional colors)
  "Build theme face specs from semantic COLORS.

COLORS defaults to `chroma-resolve-semantic-colors'.  Only faces that
exist in the running Emacs are returned.  This avoids manufacturing
newer-version faces on older Emacs releases; `chroma-theme-refresh'
adds mappings for built-in faces that are defined later."
  (let ((resolved-colors (or colors (chroma-resolve-semantic-colors))))
    (delq nil
          (mapcar
           (lambda (mapping)
             (let ((face (car mapping)))
               (when (facep face)
                 (list face
                       (list
                        (list chroma--true-color-display
                              (chroma--resolve-face-attributes
                               (cdr mapping) resolved-colors)))))))
           (chroma-face-mappings)))))

(provide 'chroma-faces)

;;; chroma-faces.el ends here
