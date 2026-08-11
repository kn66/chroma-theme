;;; chroma-faces-external.el --- External package face mappings  -*- lexical-binding: t; -*-

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
    (corfu-current :foreground fg-main :background primary-muted)
    (corfu-bar :background scrollbar)
    (corfu-border :background border-subtle))
  "Color mappings for Corfu faces with explicit default colors.")

(defconst chroma-face-mappings-diff-hl
  '((diff-hl-insert :foreground success-emphasis)
    (diff-hl-delete :foreground error-emphasis)
    (diff-hl-change :foreground warning-emphasis
                    :background warning-muted))
  "Color mappings for diff-hl change indicator faces.")

(defconst chroma-face-mappings-tempel
  '((tempel-field :foreground fg-main
                  :background primary-muted)
    (tempel-form :foreground fg-main
                 :background secondary-muted)
    (tempel-default :foreground fg-main
                    :background primary-muted))
  "Color mappings for Tempel field faces.")

(defconst chroma-face-mappings-avy
  '((avy-lead-face :foreground bg-main :background primary)
    (avy-lead-face-0 :foreground bg-main :background primary-emphasis)
    (avy-lead-face-1 :foreground fg-main :background bg-selection)
    (avy-lead-face-2 :foreground bg-main :background secondary)
    (avy-background-face :foreground fg-muted))
  "Color mappings for Avy selection faces.")

(defconst chroma-face-mappings-vundo
  '((vundo-highlight :foreground primary-emphasis)
    (vundo-saved :foreground secondary))
  "Color mappings for Vundo state faces.")

(defconst chroma-face-mappings-transient
  '((transient-disabled-suffix
     :foreground fg-on-bright :background error-alert)
    (transient-enabled-suffix
     :foreground fg-on-bright :background secondary-ansi-vivid)
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
    (magit-blame-highlight :foreground fg-main :background bg-selection)

    ;; Diff headings and line states.  Geometry and `:extend' remain Magit's.
    (magit-diff-file-heading-selection :foreground primary)
    (magit-diff-hunk-heading :foreground fg-main :background bg-subtle)
    (magit-diff-hunk-heading-highlight
     :foreground fg-main :background bg-highlight)
    (magit-diff-hunk-heading-selection :foreground primary)
    (magit-diff-lines-heading
     :foreground bg-main :background primary)
    (magit-diff-our-heading :foreground bg-main :background error)
    (magit-diff-base-heading :foreground bg-main :background warning)
    (magit-diff-their-heading :foreground bg-main :background success)
    (magit-diff-context :foreground fg-secondary)
    (magit-diff-removed
     :foreground primary-vivid :background primary-current-a)
    (magit-diff-added
     :foreground secondary-vivid :background secondary-current-b)
    (magit-diff-base
     :foreground secondary-vivid :background magit-diff-base)
    (magit-diff-context-highlight
     :foreground fg-secondary :background bg-highlight)
    (magit-diff-removed-highlight
     :foreground primary-vivid :background magit-diff-removed-highlight)
    (magit-diff-added-highlight
     :foreground secondary-vivid :background magit-diff-added-highlight)
    (magit-diff-base-highlight
     :foreground secondary-vivid :background magit-diff-base-highlight)
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
