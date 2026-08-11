;;; chroma-core.el --- Chroma semantic colors  -*- lexical-binding: t; -*-

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

;; This library validates user options, resolves automatic secondary colors,
;; and translates finite palette tokens into semantic color roles.

;;; Code:

(require 'cus-theme)
(require 'chroma-palette)

(defgroup chroma nil
  "Preserve Emacs face design while replacing its color layer."
  :group 'faces
  :prefix "chroma-")

(defun chroma--custom-set-and-refresh (symbol value)
  "Set SYMBOL to VALUE and refresh an enabled Chroma theme."
  (set-default symbol value)
  (when (and (boundp 'custom-enabled-themes)
             (memq 'chroma custom-enabled-themes)
             (fboundp 'chroma-theme-refresh))
    (chroma-theme-refresh)))

(defcustom chroma-primary 'blue
  "Primary hue used by the Chroma semantic color roles."
  :type '(choice (const blue)
                 (const azure)
                 (const cyan)
                 (const green)
                 (const chartreuse)
                 (const yellow)
                 (const orange)
                 (const red)
                 (const magenta)
                 (const purple))
  :set #'chroma--custom-set-and-refresh
  :group 'chroma)

(defcustom chroma-secondary 'auto
  "Secondary hue, or `auto' to use the complementary pairing."
  :type '(choice (const :tag "Automatic" auto)
                 (const blue)
                 (const azure)
                 (const cyan)
                 (const green)
                 (const chartreuse)
                 (const yellow)
                 (const orange)
                 (const red)
                 (const magenta)
                 (const purple))
  :set #'chroma--custom-set-and-refresh
  :group 'chroma)

(defcustom chroma-variant 'dark
  "Palette variant used by Chroma."
  :type '(choice (const :tag "Dark" dark)
                 (const :tag "Light" light))
  :set #'chroma--custom-set-and-refresh
  :group 'chroma)

(defconst chroma--display-class 'true-color
  "Palette display class used by the initial Chroma release.")

(defconst chroma-semantic-role-sources
  '((bg-main neutral bg-main)
    (bg-subtle neutral bg-subtle)
    (bg-highlight neutral bg-highlight)
    (bg-selection neutral bg-selection)
    (bg-mode-line neutral bg-mode-line)
    (bg-panel neutral bg-panel)
    (bg-ui neutral bg-ui)
    (bg-ui-inactive neutral bg-ui-inactive)
    (bg-fixed-dark neutral bg-fixed-dark)
    (fg-main neutral fg-main)
    (fg-secondary neutral fg-secondary)
    (fg-dim neutral fg-dim)
    (fg-muted neutral fg-muted)
    (fg-faint neutral fg-faint)
    (fg-on-bright neutral fg-on-bright)
    (fg-fixed-light neutral fg-fixed-light)
    (fg-fixed-light-gray neutral fg-fixed-light-gray)
    (fg-fixed-gray neutral fg-fixed-gray)
    (fg-fill-column neutral fg-fill-column)
    (primary primary base)
    (primary-emphasis primary emphasis)
    (primary-muted primary muted)
    (primary-vivid primary vivid)
    (primary-selection primary selection)
    (primary-refinement primary refinement)
    (pulse primary pulse)
    (primary-alert primary alert)
    (primary-ansi-low primary ansi-low)
    (primary-ansi-low-bright primary ansi-low-bright)
    (primary-ansi-mid primary ansi-mid)
    (primary-ansi-mid-bright primary ansi-mid-bright)
    (primary-ansi-upper primary ansi-upper)
    (primary-ansi-upper-bright primary ansi-upper-bright)
    (primary-ansi-high primary ansi-high)
    (primary-ansi-vivid primary ansi-vivid)
    (primary-strong primary strong)
    (primary-polarity primary polarity)
    (primary-polarity-strong primary polarity-strong)
    (primary-steady primary steady)
    (primary-dark-only primary dark-only)
    (primary-dark-only-emphasis primary dark-only-emphasis)
    (primary-fixed-dark primary fixed-dark)
    (primary-changed-indicator primary changed-indicator)
    (primary-fine-a primary fine-a)
    (primary-fine-ancestor primary fine-ancestor)
    (primary-fine-b primary fine-b)
    (primary-fine-c primary fine-c)
    (primary-current-a primary current-a)
    (primary-current-ancestor primary current-ancestor)
    (primary-current-b primary current-b)
    (primary-current-c primary current-c)
    (primary-search-group-1-background primary search-group-1-background)
    (primary-search-group-1-foreground primary search-group-1-foreground)
    (primary-search-group-2-background primary search-group-2-background)
    (primary-search-group-2-foreground primary search-group-2-foreground)
    (primary-indicator-removed primary indicator-removed)
    (primary-indicator-added primary indicator-added)
    (primary-whitespace-big-foreground
     primary whitespace-big-foreground)
    (primary-selected-link primary selected-link)
    (primary-status-error primary status-error)
    (primary-status-warning primary status-warning)
    (primary-status-success primary status-success)
    (secondary secondary base)
    (secondary-emphasis secondary emphasis)
    (secondary-muted secondary muted)
    (secondary-vivid secondary vivid)
    (secondary-selection secondary selection)
    (alternate-selection secondary standalone-selection)
    (secondary-refinement secondary refinement)
    (paren-match secondary paren-match)
    (secondary-alert secondary alert)
    (secondary-ansi-low secondary ansi-low)
    (secondary-ansi-low-bright secondary ansi-low-bright)
    (secondary-ansi-mid secondary ansi-mid)
    (secondary-ansi-mid-bright secondary ansi-mid-bright)
    (secondary-ansi-upper secondary ansi-upper)
    (secondary-ansi-upper-bright secondary ansi-upper-bright)
    (secondary-ansi-high secondary ansi-high)
    (secondary-ansi-vivid secondary ansi-vivid)
    (secondary-strong secondary strong)
    (secondary-polarity secondary polarity)
    (secondary-polarity-strong secondary polarity-strong)
    (secondary-steady secondary steady)
    (secondary-dark-only secondary dark-only)
    (secondary-dark-only-emphasis secondary dark-only-emphasis)
    (secondary-fixed-dark secondary fixed-dark)
    (secondary-changed-indicator secondary changed-indicator)
    (secondary-fine-a secondary fine-a)
    (secondary-fine-ancestor secondary fine-ancestor)
    (secondary-fine-b secondary fine-b)
    (secondary-fine-c secondary fine-c)
    (secondary-current-a secondary current-a)
    (secondary-current-ancestor secondary current-ancestor)
    (secondary-current-b secondary current-b)
    (secondary-current-c secondary current-c)
    (secondary-search-group-1-background secondary search-group-1-background)
    (secondary-search-group-1-foreground secondary search-group-1-foreground)
    (secondary-search-group-2-background secondary search-group-2-background)
    (secondary-search-group-2-foreground secondary search-group-2-foreground)
    (secondary-indicator-removed secondary indicator-removed)
    (secondary-indicator-added secondary indicator-added)
    (secondary-whitespace-big-foreground
     secondary whitespace-big-foreground)
    (secondary-selected-link secondary selected-link)
    (secondary-status-error secondary status-error)
    (secondary-status-warning secondary status-warning)
    (secondary-status-success secondary status-success)
    (error primary status-error)
    (error-emphasis primary emphasis)
    (error-muted primary muted)
    (error-refinement primary refinement)
    (error-alert primary alert)
    (warning secondary status-warning)
    (warning-emphasis secondary emphasis)
    (warning-muted secondary muted)
    (warning-refinement secondary refinement)
    (warning-alert secondary alert)
    (success secondary status-success)
    (success-emphasis secondary emphasis)
    (success-muted secondary muted)
    (success-refinement secondary refinement)
    (success-alert secondary alert)
    (info primary emphasis)
    (info-emphasis primary emphasis)
    (info-muted primary muted)
    (diff-removed primary diff-removed)
    (diff-added secondary diff-added)
    (diff-refine-removed primary diff-refine-removed)
    (diff-refine-added secondary diff-refine-added)
    (magit-diff-base secondary magit-base)
    (magit-diff-removed-highlight primary magit-removed-highlight)
    (magit-diff-added-highlight secondary magit-added-highlight)
    (magit-diff-base-highlight secondary magit-base-highlight)
    (border neutral border)
    (border-subtle neutral border-subtle)
    (border-leading neutral border-leading)
    (border-trailing neutral border-trailing)
    (window-divider neutral window-divider)
    (scrollbar neutral scrollbar)
    (link primary vivid)
    (visited-link secondary emphasis)
    (match secondary muted)
    (search primary alert)
    (selection secondary selection))
  "Map semantic roles to a palette selector and token.

Each entry has the form (ROLE SELECTOR TOKEN).  SELECTOR is `neutral',
`primary', or `secondary'.  Concrete hue symbols are intentionally not
accepted here, so all chromatic roles follow the user's two selected hues.")

(defun chroma--validate-hue (hue option)
  "Return HUE when it is valid, or report invalid OPTION."
  (unless (memq hue chroma-supported-hues)
    (user-error "Invalid %s hue %S; expected one of %S"
                option hue chroma-supported-hues))
  hue)

(defun chroma-resolve-secondary (&optional primary secondary)
  "Resolve a secondary hue for PRIMARY and SECONDARY.

Nil PRIMARY and SECONDARY use `chroma-primary' and
`chroma-secondary', respectively.  When SECONDARY is `auto', return the
author-defined partner for PRIMARY.  Signal `user-error' for invalid
values."
  (let* ((selected-primary
          (chroma--validate-hue (or primary chroma-primary) "primary"))
         (selected-secondary
          (if (null secondary) chroma-secondary secondary)))
    (if (eq selected-secondary 'auto)
        (or (alist-get selected-primary chroma-primary-secondary-pairs)
            (user-error "No automatic secondary hue for %S"
                        selected-primary))
      (chroma--validate-hue selected-secondary "secondary"))))

(defun chroma--selector-hue (selector primary secondary)
  "Resolve SELECTOR to a palette hue using PRIMARY and SECONDARY."
  (cond
   ((eq selector 'neutral) 'neutral)
   ((eq selector 'primary) primary)
   ((eq selector 'secondary) secondary)
   (t (error "Invalid Chroma semantic palette selector: %S" selector))))

(defun chroma-resolve-semantic-colors
    (&optional primary secondary variant display-class)
  "Return an alist mapping semantic roles to finite palette colors.

PRIMARY, SECONDARY, VARIANT, and DISPLAY-CLASS default to the current
Chroma options.  SECONDARY may be `auto'.  This function only performs
lookups; it never generates or adjusts a color."
  (let* ((selected-primary
          (chroma--validate-hue (or primary chroma-primary) "primary"))
         (selected-secondary
          (chroma-resolve-secondary selected-primary
                                    (if (null secondary)
                                        chroma-secondary
                                      secondary)))
         (selected-variant (or variant chroma-variant))
         (selected-class (or display-class chroma--display-class)))
    ;; Validate the outer palette selection even if role data is empty.
    (chroma-palette-get selected-variant selected-class)
    (mapcar
     (lambda (source)
       (let ((role (nth 0 source))
             (selector (nth 1 source))
             (token (nth 2 source)))
         (cons role
               (chroma-palette-color
                (chroma--selector-hue selector
                                      selected-primary
                                      selected-secondary)
                token selected-variant selected-class))))
     chroma-semantic-role-sources)))

(provide 'chroma-core)

;;; chroma-core.el ends here
