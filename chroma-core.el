;;; chroma-core.el --- Chroma semantic colors  -*- lexical-binding: t; -*-

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
    (fixed-black neutral ansi-black)
    (fixed-white neutral ansi-bright-white)
    (fg-fixed-gray neutral fg-fixed-gray)
    (fg-fixed-gray-50 neutral fg-fixed-gray-50)
    (fg-fill-column neutral fg-fill-column)
    (ansi-black neutral ansi-black)
    (ansi-bright-black neutral ansi-bright-black)
    (ansi-white neutral ansi-white)
    (ansi-bright-white neutral ansi-bright-white)
    (bg-fixed-light-gray neutral bg-fixed-light-gray)
    (bg-fixed-gray-90 neutral bg-fixed-gray-90)
    (bg-fixed-gray-80 neutral bg-fixed-gray-80)
    (bg-fixed-gray-50 neutral bg-fixed-gray-50)
    (bg-fixed-gray-192 neutral bg-fixed-gray-192)
    (bg-input neutral bg-input)
    (bg-diff-changed-unspecified neutral bg-diff-changed-unspecified)
    (bg-ediff-light neutral bg-ediff-light)
    (bg-ediff-mid neutral bg-ediff-mid)
    (bg-fixed-gray-40 neutral bg-fixed-gray-40)
    (bg-org-column neutral bg-org-column)
    (bg-separator neutral bg-separator)
    (fg-gnus-splash neutral fg-gnus-splash)
    (bg-tab-current neutral bg-tab-current)
    (bg-tab-inactive-alternate neutral bg-tab-inactive-alternate)
    (bg-tool-bar neutral bg-tool-bar)
    (bg-tooltip neutral bg-tooltip)
    (mode-line-source-foreground neutral mode-line-source-foreground)
    (mode-line-source-background neutral mode-line-source-background)
    (mode-line-inactive-foreground neutral mode-line-inactive-foreground)
    (mode-line-inactive-background neutral mode-line-inactive-background)
    (header-line-source-foreground neutral header-line-source-foreground)
    (header-line-source-background neutral header-line-source-background)
    (tab-source-foreground neutral tab-source-foreground)
    (tab-source-background neutral tab-source-background)
    (org-clock-foreground neutral org-clock-foreground)
    (help-key-background neutral help-key-background)
    (whitespace-line-background neutral whitespace-line-background)
    (corfu-indexed-foreground neutral corfu-indexed-foreground)
    (corfu-indexed-background neutral corfu-indexed-background)
    (corfu-quick-foreground neutral corfu-quick-foreground)
    (transient-key-noop neutral transient-key-noop)
    (corfu-current-foreground neutral corfu-quick-foreground)
    (avy-lead-1-background neutral avy-lead-1-background)
    (magit-blame-foreground neutral magit-blame-foreground)
    (magit-blame-background neutral magit-blame-background)
    (magit-hunk-foreground neutral magit-hunk-foreground)
    (magit-hunk-background neutral magit-hunk-background)
    (magit-hunk-highlight-background neutral magit-hunk-highlight-background)
    (magit-context-highlight-foreground
     neutral magit-context-highlight-foreground)
    (magit-context-highlight-background
     neutral magit-context-highlight-background)
    (magit-lines-foreground neutral magit-lines-foreground)
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
    (secondary-ansi-magenta secondary ansi-magenta)
    (secondary-ansi-bright-magenta secondary ansi-bright-magenta)
    (secondary-ansi-green secondary ansi-green)
    (secondary-ansi-bright-green secondary ansi-bright-green)
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
    (special-glyph secondary special-glyph)
    (font-lock-type primary pale-success)
    (compilation-exit secondary steady)
    (custom-button-pressed-unraised secondary visited-link)
    (org-done secondary pale-success)
    (org-scheduled secondary org-scheduled)
    (message-header-cc primary message-header-cc)
    (message-header-name primary message-header-name)
    (message-header-newsgroups primary message-header-newsgroups)
    (message-header-other primary message-header-other)
    (message-header-subject primary message-header-subject)
    (message-header-to primary message-header-to)
    (message-mml secondary message-mml)
    (message-separator primary message-separator)
    (sh-quoted-exec primary sh-quoted-exec)
    (speedbar-highlight secondary speedbar-highlight)
    (blink-offscreen secondary blink-offscreen)
    (custom-state-foreground secondary custom-state-foreground)
    (speedbar-button secondary speedbar-button)
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
    (visited-link secondary visited-link)
    (match secondary match)
    (search primary alert)
    (gnus-mail-1-empty primary gnus-mail-1-empty)
    (gnus-mail-2-empty primary gnus-mail-2-empty)
    (gnus-mail-3-empty primary gnus-mail-3-empty)
    (gnus-mail-low-empty primary gnus-mail-low-empty)
    (gnus-news-1-empty secondary gnus-news-1-empty)
    (gnus-news-2-empty secondary gnus-news-2-empty)
    (gnus-news-low-empty secondary gnus-news-low-empty)
    (gnus-summary-cancelled primary contrast-yellow-1)
    (gnus-summary-ancient primary gnus-summary-ancient)
    (gnus-summary-read secondary gnus-summary-read)
    (gnus-summary-ticked primary gnus-summary-ticked)
    (gnus-summary-undownloaded secondary gnus-summary-undownloaded)
    (info-node primary info-node)
    (message-cited-1 primary message-cited-1)
    (message-cited-2 secondary message-cited-2)
    (message-cited-3 primary message-cited-3)
    (message-cited-4 secondary message-cited-4)
    (message-command-output primary message-command-output)
    (isearch-foreground primary isearch-foreground)
    (isearch-background primary isearch-background)
    (paren-mismatch-background primary paren-mismatch-background)
    (contrast-red-1 primary contrast-red-1)
    (contrast-yellow-1 secondary contrast-yellow-1)
    (custom-state-background primary custom-state-background)
    (custom-rogue-foreground secondary custom-rogue-foreground)
    (org-clock-background secondary org-clock-background)
    (org-dispatcher-foreground primary org-dispatcher-foreground)
    (org-dispatcher-background primary org-dispatcher-background)
    (help-key-foreground primary help-key-foreground)
    (whitespace-space-background secondary whitespace-space-background)
    (whitespace-hspace-background secondary whitespace-hspace-background)
    (whitespace-tab-background secondary whitespace-tab-background)
    (contrast-firebrick primary contrast-firebrick)
    (contrast-dark-orange secondary contrast-dark-orange)
    (whitespace-line-foreground secondary whitespace-line-foreground)
    (whitespace-missing-background secondary whitespace-missing-background)
    (ert-expected secondary ert-expected)
    (ert-unexpected primary ert-unexpected)
    (corfu-quick-1-background primary corfu-quick-1-background)
    (corfu-quick-2-background secondary corfu-quick-2-background)
    (vundo-diff-highlight primary vundo-diff-highlight)
    (corfu-current-background primary corfu-current-background)
    (diff-hl-change-foreground secondary diff-hl-change-foreground)
    (diff-hl-change-background secondary diff-hl-change-background)
    (tempel-field-foreground primary tempel-field-foreground)
    (tempel-field-background primary tempel-field-background)
    (tempel-form-foreground secondary tempel-form-foreground)
    (tempel-form-background secondary tempel-form-background)
    (tempel-default-foreground primary tempel-default-foreground)
    (tempel-default-background primary tempel-default-background)
    (avy-lead-background primary avy-lead-background)
    (avy-lead-0-background primary avy-lead-0-background)
    (avy-lead-2-background secondary avy-lead-2-background)
    (transient-disabled-background primary transient-disabled-background)
    (transient-enabled-background secondary transient-enabled-background)
    (magit-lines-background primary magit-lines-background)
    (magit-red-deep primary magit-red-deep)
    (magit-red-pale primary magit-red-pale)
    (magit-green-deep secondary magit-green-deep)
    (magit-green-pale secondary magit-green-pale)
    (magit-base-deep secondary magit-base-deep)
    (magit-base-pale secondary magit-base-pale)
    (magit-red-highlight-foreground
     primary magit-red-highlight-foreground)
    (magit-red-highlight-background
     primary magit-red-highlight-background)
    (magit-green-highlight-foreground
     secondary magit-green-highlight-foreground)
    (magit-green-highlight-background
     secondary magit-green-highlight-background)
    (magit-base-highlight-foreground
     secondary magit-base-highlight-foreground)
    (magit-base-highlight-background
     secondary magit-base-highlight-background)
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
