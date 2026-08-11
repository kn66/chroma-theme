;;; chroma-faces-external.el --- External package face mappings  -*- lexical-binding: t; -*-

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

;; These mappings cover external package faces whose upstream defaults set
;; concrete colors.  Faces which only inherit standard Emacs faces are left
;; alone and receive Chroma colors through that inheritance.
;;
;; This library intentionally does not require any supported package.  The
;; theme applies mappings for faces which already exist, and its after-load
;; hook applies the remaining mappings when a package is loaded later.
;;
;; Definitions were audited against Avy 0.5.0, Corfu 2.10, diff-hl 1.10.0,
;; Magit and magit-section 4.6.0, Tempel 1.14, Transient 0.13.5, and
;; Vundo 2.4.0.

;;; Code:

(defconst chroma-supported-external-packages
  '(avy corfu diff-hl magit tempel transient vundo)
  "External packages with explicit Chroma face mappings.")

(defconst chroma-face-mappings-corfu
  '((corfu-default :background bg-subtle)
    (corfu-current
     :foreground corfu-current-foreground
     :background corfu-current-background)
    (corfu-bar :background scrollbar)
    (corfu-border :background border-subtle)
    (corfu-indexed
     :foreground corfu-indexed-foreground
     :background corfu-indexed-background)
    (corfu-quick1
     :foreground corfu-quick-foreground
     :background corfu-quick-1-background)
    (corfu-quick2
     :foreground corfu-quick-foreground
     :background corfu-quick-2-background))
  "Color mappings for Corfu faces with explicit default colors.")

(defconst chroma-face-mappings-diff-hl
  '((diff-hl-insert :foreground success-emphasis)
    (diff-hl-delete :foreground error-emphasis)
    (diff-hl-change
     :foreground diff-hl-change-foreground
     :background diff-hl-change-background))
  "Color mappings for diff-hl change indicator faces.")

(defconst chroma-face-mappings-tempel
  '((tempel-field
     :foreground tempel-field-foreground
     :background tempel-field-background)
    (tempel-form
     :foreground tempel-form-foreground
     :background tempel-form-background)
    (tempel-default
     :foreground tempel-default-foreground
     :background tempel-default-background))
  "Color mappings for Tempel field faces.")

(defconst chroma-face-mappings-avy
  '((avy-lead-face
     :foreground fixed-white :background avy-lead-background)
    (avy-lead-face-0
     :foreground fixed-white :background avy-lead-0-background)
    (avy-lead-face-1
     :foreground fixed-white :background avy-lead-1-background)
    (avy-lead-face-2
     :foreground fixed-white :background avy-lead-2-background)
    (avy-background-face :foreground fg-muted))
  "Color mappings for Avy selection faces.")

(defconst chroma-face-mappings-vundo
  '((vundo-highlight :foreground primary-emphasis)
    (vundo-saved :foreground secondary)
    (vundo-diff-highlight :foreground vundo-diff-highlight))
  "Color mappings for Vundo state faces.")

(defconst chroma-face-mappings-transient
  '((transient-disabled-suffix
     :foreground fixed-black :background transient-disabled-background)
    (transient-enabled-suffix
     :foreground fixed-black :background transient-enabled-background)
    (transient-key-noop :foreground transient-key-noop)
    (transient-key-exit :foreground error-emphasis)
    (transient-key-recurse :foreground primary-emphasis)
    (transient-key-return :foreground secondary-polarity)
    (transient-key-stack :foreground primary)
    (transient-key-stay :foreground secondary-polarity))
  "Color mappings for Transient faces with explicit default colors.")

(defconst chroma-face-mappings-magit
  '(
    ;; Magit Section and general labels.
    (magit-section-highlight :background bg-highlight)
    (magit-section-heading :foreground primary-emphasis)
    (magit-section-heading-selection :foreground primary)
    (magit-dimmed :foreground fg-muted)
    (magit-hash :foreground fg-faint)
    (magit-tag :foreground primary-emphasis)
    (magit-branch-remote :foreground secondary)
    (magit-branch-local :foreground primary-emphasis)
    (magit-refname :foreground fg-secondary)
    (magit-signature-good :foreground success)
    (magit-signature-bad :foreground error)
    (magit-signature-untrusted :foreground success-emphasis)
    (magit-signature-expired :foreground warning)
    (magit-signature-revoked :foreground error-emphasis)
    (magit-signature-error :foreground info)
    (magit-cherry-unmatched :foreground primary)
    (magit-cherry-equivalent :foreground primary-emphasis)
    (magit-log-graph :foreground fg-secondary)
    (magit-log-author :foreground primary)
    (magit-log-date :foreground fg-secondary)
    (magit-blame-highlight
     :foreground magit-blame-foreground
     :background magit-blame-background)

    ;; Diff headings and line states.  Geometry and `:extend' remain Magit's.
    (magit-diff-file-heading-selection :foreground primary)
    (magit-diff-hunk-heading
     :foreground magit-hunk-foreground :background magit-hunk-background)
    (magit-diff-hunk-heading-highlight
     :foreground magit-hunk-foreground
     :background magit-hunk-highlight-background)
    (magit-diff-hunk-heading-selection :foreground primary)
    (magit-diff-lines-heading
     :foreground ((dark . magit-lines-foreground))
     :background magit-lines-background)
    (magit-diff-our-heading
     :foreground magit-red-deep :background magit-red-pale)
    (magit-diff-base-heading
     :foreground magit-base-deep :background magit-base-pale)
    (magit-diff-their-heading
     :foreground magit-green-deep :background magit-green-pale)
    (magit-diff-context :foreground fg-secondary)
    (magit-diff-removed
     :foreground magit-red-pale :background magit-red-deep)
    (magit-diff-added
     :foreground magit-green-pale :background magit-green-deep)
    (magit-diff-base
     :foreground magit-base-pale :background magit-base-deep)
    (magit-diff-context-highlight
     :foreground magit-context-highlight-foreground
     :background magit-context-highlight-background)
    (magit-diff-removed-highlight
     :foreground magit-red-highlight-foreground
     :background magit-red-highlight-background)
    (magit-diff-added-highlight
     :foreground magit-green-highlight-foreground
     :background magit-green-highlight-background)
    (magit-diff-base-highlight
     :foreground magit-base-highlight-foreground
     :background magit-base-highlight-background)
    (magit-diff-removed-indicator :foreground primary-vivid)
    (magit-diff-added-indicator :foreground secondary-vivid)
    (magit-diff-base-indicator :foreground secondary-vivid)
    (magit-diffstat-removed :foreground error)
    (magit-diffstat-added :foreground success)

    ;; Process, reflog, bisect, and sequence state.
    (magit-process-ok :foreground success-emphasis)
    (magit-process-ng :foreground error-emphasis)
    (magit-reflog-commit :foreground success)
    (magit-reflog-amend :foreground primary)
    (magit-reflog-merge :foreground success)
    (magit-reflog-checkout :foreground primary)
    (magit-reflog-reset :foreground error)
    (magit-reflog-rebase :foreground primary-emphasis)
    (magit-reflog-cherry-pick :foreground success-emphasis)
    (magit-reflog-remote :foreground primary)
    (magit-reflog-other :foreground primary)
    (magit-bisect-good :foreground success)
    (magit-bisect-skip :foreground warning)
    (magit-bisect-bad :foreground error)
    (magit-sequence-stop :foreground success)
    (magit-sequence-part :foreground warning)
    (magit-sequence-head :foreground primary)
    (magit-sequence-drop :foreground error))
  "Color mappings for Magit faces with explicit default colors.")

(defun chroma-external-face-mappings ()
  "Return all external package face-to-semantic-role mappings."
  (append chroma-face-mappings-corfu
          chroma-face-mappings-diff-hl
          chroma-face-mappings-tempel
          chroma-face-mappings-avy
          chroma-face-mappings-vundo
          chroma-face-mappings-transient
          chroma-face-mappings-magit))

(provide 'chroma-faces-external)

;;; chroma-faces-external.el ends here
