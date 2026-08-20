;;; chroma-faces.el --- Chroma face mappings  -*- lexical-binding: t; -*-

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

;; Each mapping below says only which semantic color a face uses.  Mapping
;; values never contain literal colors.  Chroma deliberately does not set
;; structural attributes such as weight, slant, height, inheritance, or box
;; geometry.
;;
;; Composite attributes such as `:underline' and `:box' may embed a color,
;; but a theme face spec cannot safely merge only that nested color with the
;; structural value owned by Emacs.  This release therefore leaves those
;; attributes entirely to their defining libraries.
;;
;; Emacs normally replaces a face's complete `defface' spec when any theme
;; spec matches it.  Generated Chroma specs therefore inherit a private proxy
;; of the upstream spec.  The mappings still own colors only; the proxy keeps
;; upstream inheritance, inverse video, underlines, boxes, and other structure.

;;; Code:

(require 'button)
(require 'font-lock)
(require 'chroma-core)
(require 'chroma-faces-external)

(defconst chroma-face-color-attributes '(:foreground :background)
  "Face attributes Chroma mappings are allowed to set.")

(defconst chroma-audited-built-in-libraries
  '(tab-bar tab-line hl-line display-line-numbers isearch replace
    paren compile diff-mode ediff ansi-color cus-edit wid-edit ert org
    pulse sh-script dired help-mode info calendar whitespace message
    smerge-mode bookmark edmacro epa em-prompt eww shr speedbar tmm
    package flymake eglot xref completion-preview ibuffer proced calc
    vc-dir log-view grep gdb-mi shell comint em-ls rmail rcirc erc
    nxml-mode css-mode rst)
  "Built-in libraries with face-by-face Chroma audit decisions.

This is the single source of truth shared by the reverse coverage audit,
selector report, and effective contrast tests.  A library remains listed
even when all its faces are colorless or inherited-only.")

(defconst chroma-face-mappings-basic
  '((default :foreground fg-main :background bg-main)
    (cursor :background primary-emphasis)
    (region :background selection)
    (secondary-selection :background alternate-selection)
    (highlight :background primary-refinement)
    (shadow :foreground fg-muted)
    (link :foreground link)
    (link-visited :foreground visited-link)
    (error :foreground error)
    (warning :foreground warning)
    (success :foreground success)
    (escape-glyph :foreground special-glyph)
    (homoglyph :foreground special-glyph)
    (nobreak-hyphen :foreground special-glyph)
    (trailing-whitespace :background error-alert))
  "Color mappings for fundamental Emacs faces.")

(defconst chroma-face-mappings-font-lock
  '((font-lock-builtin-face :foreground primary-emphasis)
    (font-lock-comment-face :foreground primary)
    (font-lock-constant-face :foreground secondary-vivid)
    (font-lock-function-name-face :foreground primary-emphasis)
    (font-lock-keyword-face :foreground primary-vivid)
    (font-lock-string-face :foreground secondary-emphasis)
    (font-lock-type-face :foreground font-lock-type)
    (font-lock-variable-name-face :foreground secondary-vivid))
  "Color mappings for Font Lock faces with explicit standard colors.")

(defconst chroma-face-mappings-ui
  '((mode-line
     :foreground mode-line-source-foreground
     :background mode-line-source-background)
    (mode-line-inactive
     :foreground mode-line-inactive-foreground
     :background mode-line-inactive-background)
    (header-line
     :foreground header-line-source-foreground
     :background header-line-source-background)
    (minibuffer-prompt :foreground primary-emphasis)
    (fringe :background bg-main)
    (window-divider :foreground window-divider)
    (window-divider-first-pixel :foreground border-leading)
    (window-divider-last-pixel :foreground border-trailing)
    (line-number-major-tick :background bg-mode-line)
    (line-number-minor-tick :background bg-ui-inactive)
    (tab-bar :foreground tab-source-foreground
             :background tab-source-background)
    (tab-bar-tab-inactive :background bg-ui-inactive)
    (tab-line :foreground tab-source-foreground
              :background tab-source-background)
    (tab-line-tab-current :background bg-tab-current)
    (tab-line-tab-inactive :background bg-ui-inactive)
    (tab-line-tab-inactive-alternate
     :background bg-tab-inactive-alternate)
    (tab-line-highlight :foreground tab-source-foreground
                        :background tab-source-background)
    (tab-line-close-highlight :foreground error)
    (separator-line :background bg-separator)
    (tool-bar :foreground fixed-black :background bg-tool-bar)
    (tooltip :foreground fixed-black :background bg-tooltip)
    (icon-button :foreground fixed-black :background bg-fixed-gray-80))
  "Color mappings for built-in Emacs user-interface faces.")

(defconst chroma-face-mappings-search
  '((match :background match)
    (lazy-highlight :background alternate-selection)
    (isearch :foreground isearch-foreground :background isearch-background)
    (isearch-fail :background error-muted)
    (isearch-group-1
     :foreground primary-search-group-1-foreground
     :background primary-search-group-1-background)
    (isearch-group-2
     :foreground secondary-search-group-2-foreground
     :background secondary-search-group-2-background)
    (show-paren-match :background paren-match)
    (show-paren-mismatch
     :foreground fg-fixed-light :background paren-mismatch-background))
  "Color mappings for search, match, and parenthesis faces.")

(defconst chroma-face-mappings-completion
  '((completions-common-part :foreground primary-emphasis)
    (minibuffer-completion-active :background primary-muted))
  "Color mappings for built-in completion faces.")

(defconst chroma-face-mappings-diagnostics
  '((compilation-mode-line-exit :foreground compilation-exit)
    (compilation-mode-line-fail :foreground error))
  "Color mappings for built-in diagnostic faces.")

(defconst chroma-face-mappings-ert
  '((ert-test-result-expected :background ert-expected)
    (ert-test-result-unexpected :background ert-unexpected))
  "Color mappings for ERT result faces with explicit colors.")

(defconst chroma-face-mappings-diff
  '((diff-added :background diff-added)
    (diff-removed :background diff-removed)
    (diff-header :background bg-panel)
    (diff-file-header :background bg-ui-inactive)
    (diff-indicator-added :foreground secondary-indicator-added)
    (diff-indicator-removed :foreground primary-indicator-removed)
    (diff-indicator-changed :foreground secondary-changed-indicator)
    (diff-refine-added :background diff-refine-added)
    (diff-refine-removed :background diff-refine-removed)
    (diff-refine-changed :background secondary-fine-c)
    (diff-changed-unspecified :background bg-diff-changed-unspecified)
    (diff-error :foreground contrast-red-1 :background fixed-black))
  "Color mappings for built-in Diff mode faces.")

(defconst chroma-face-mappings-ediff
  '((ediff-even-diff-A :background bg-ediff-light)
    (ediff-even-diff-Ancestor :background bg-ediff-mid)
    (ediff-even-diff-B :background bg-ediff-mid)
    (ediff-even-diff-C :background bg-ediff-light)
    (ediff-odd-diff-A :background bg-ediff-mid)
    (ediff-odd-diff-Ancestor :background bg-fixed-gray-40)
    (ediff-odd-diff-B :background bg-ediff-light)
    (ediff-odd-diff-C :background bg-ediff-mid)
    (ediff-current-diff-A :background primary-current-a)
    (ediff-current-diff-Ancestor :background primary-current-ancestor)
    (ediff-current-diff-B :background secondary-current-b)
    (ediff-current-diff-C :background secondary-current-c)
    (ediff-fine-diff-A :background primary-fine-a)
    (ediff-fine-diff-Ancestor :background primary-fine-ancestor)
    (ediff-fine-diff-B :background secondary-fine-b)
    (ediff-fine-diff-C :background secondary-fine-c))
  "Color mappings for built-in Ediff faces.")

(defconst chroma-face-mappings-ansi
  '((ansi-color-black
     :foreground ansi-black :background ansi-black)
    (ansi-color-bright-black
     :foreground ansi-bright-black :background ansi-bright-black)
    (ansi-color-white
     :foreground ansi-white :background ansi-white)
    (ansi-color-bright-white
     :foreground ansi-bright-white :background ansi-bright-white)
    (ansi-color-red
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
     :foreground secondary-ansi-green :background secondary-ansi-green)
    (ansi-color-bright-green
     :foreground secondary-ansi-bright-green
     :background secondary-ansi-bright-green)
    (ansi-color-yellow
     :foreground secondary-ansi-upper-bright
     :background secondary-ansi-upper-bright)
    (ansi-color-bright-yellow
     :foreground secondary-ansi-vivid
     :background secondary-ansi-vivid)
    (ansi-color-magenta
     :foreground secondary-ansi-magenta
     :background secondary-ansi-magenta)
    (ansi-color-bright-magenta
     :foreground secondary-ansi-bright-magenta
     :background secondary-ansi-bright-magenta))
  "Color mappings for built-in ANSI color faces.")

(defconst chroma-face-mappings-custom
  '((custom-button
     :foreground fixed-black :background bg-fixed-light-gray)
    (custom-button-mouse
     :foreground fixed-black :background bg-fixed-gray-90)
    (custom-button-pressed
     :foreground fixed-black :background bg-fixed-light-gray)
    (custom-button-pressed-unraised
     :foreground custom-button-pressed-unraised)
    (custom-changed
     :foreground fg-fixed-light :background custom-state-background)
    (custom-comment-tag :foreground primary-strong)
    (custom-comment :background bg-input)
    (custom-group-tag :foreground primary-emphasis)
    (custom-group-tag-1 :foreground secondary-status-error)
    (custom-invalid
     :foreground contrast-yellow-1 :background contrast-red-1)
    (custom-modified
     :foreground fg-fixed-light :background custom-state-background)
    (custom-rogue
     :foreground custom-rogue-foreground :background fixed-black)
    (custom-set
     :foreground fg-fixed-light :background custom-state-background)
    (custom-state :foreground custom-state-foreground)
    (custom-themed
     :foreground fg-fixed-light :background custom-state-background)
    (custom-variable-obsolete :foreground primary-emphasis)
    (custom-variable-tag :foreground primary-emphasis)
    (widget-button-pressed :foreground primary-alert)
    (widget-documentation :foreground custom-state-foreground))
  "Color mappings for built-in Customize and Widget faces.")

(defconst chroma-face-mappings-org
  '((org-agenda-done :foreground org-done)
    (org-agenda-dimmed-todo-face :foreground fg-fixed-gray-50)
    (org-agenda-restriction-lock :background bg-subtle)
    (org-agenda-structure :foreground primary-emphasis)
    (org-clock-overlay
     :foreground org-clock-foreground :background org-clock-background)
    (org-date :foreground primary-status-success)
    (org-date-selected :foreground error)
    (org-dispatcher-highlight
     :foreground org-dispatcher-foreground
     :background org-dispatcher-background)
    (org-document-info :foreground primary-strong)
    (org-document-title :foreground primary-strong)
    (org-done :foreground org-done)
    (org-drawer :foreground secondary)
    (org-ellipsis :foreground secondary-polarity)
    (org-footnote :foreground primary-status-success)
    (org-formula :foreground primary)
    (org-column :background bg-org-column)
    (org-column-title :background bg-org-column)
    (org-headline-done :foreground secondary-polarity)
    (org-headline-todo :foreground primary)
    (org-hide :foreground bg-main)
    (org-latex-and-related :foreground secondary)
    (org-mode-line-clock-overrun :background error-alert)
    (org-scheduled :foreground org-scheduled)
    (org-scheduled-previously :foreground primary)
    (org-scheduled-today :foreground org-scheduled)
    (org-sexp-date :foreground primary-status-success)
    (org-table :foreground secondary)
    (org-table-header
     :foreground fixed-black :background bg-fixed-light-gray)
    (org-time-grid :foreground secondary-polarity)
    (org-todo :foreground error)
    (org-upcoming-deadline :foreground primary))
  "Color mappings for Org faces with explicit standard colors.")

(defconst chroma-face-mappings-misc
  '((blink-matching-paren-offscreen :foreground blink-offscreen)
    (elisp-shorthand-font-lock-face :foreground primary-ansi-vivid)
    (pulse-highlight-face :background pulse)
    (pulse-highlight-start-face :background pulse)
    (sh-heredoc :foreground secondary-ansi-vivid)
    (sh-quoted-exec :foreground sh-quoted-exec))
  "Color mappings for miscellaneous built-in chromatic faces.")

(defconst chroma-face-mappings-tools
  '((dired-broken-symlink
     :foreground contrast-yellow-1 :background contrast-red-1)
    (help-key-binding
     :foreground help-key-foreground :background help-key-background)
    (info-menu-star :foreground primary-alert)
    (info-node :foreground info-node)
    (diary :foreground secondary-status-success)
    (holiday :background warning-muted)
    (whitespace-space
     :foreground fg-fixed-gray :background whitespace-space-background)
    (whitespace-hspace
     :foreground fg-fixed-gray :background whitespace-hspace-background)
    (whitespace-tab
     :foreground fg-fixed-gray :background whitespace-tab-background)
    (whitespace-newline :foreground fg-fixed-gray)
    (whitespace-trailing
     :foreground contrast-yellow-1 :background contrast-red-1)
    (whitespace-empty
     :foreground contrast-firebrick :background contrast-yellow-1)
    (whitespace-indentation
     :foreground contrast-firebrick :background contrast-yellow-1)
    (whitespace-space-after-tab
     :foreground contrast-firebrick :background contrast-yellow-1)
    (whitespace-space-before-tab
     :foreground contrast-firebrick :background contrast-dark-orange)
    (whitespace-big-indent
     :foreground primary-whitespace-big-foreground
     :background primary-alert)
    (whitespace-line
     :foreground whitespace-line-foreground
     :background whitespace-line-background)
    (whitespace-missing-newline-at-eof
     :foreground fixed-black :background whitespace-missing-background)
    (widget-field :background bg-input)
    (widget-single-line-field :background bg-input))
  "Color mappings for selected built-in tool faces.")

(defconst chroma-face-mappings-message
  '((message-cited-text-1 :foreground message-cited-1)
    (message-cited-text-2 :foreground message-cited-2)
    (message-cited-text-3 :foreground message-cited-3)
    (message-cited-text-4 :foreground message-cited-4)
    (message-header-cc :foreground message-header-cc)
    (message-header-name :foreground message-header-name)
    (message-header-newsgroups :foreground message-header-newsgroups)
    (message-header-other :foreground message-header-other)
    (message-header-subject :foreground message-header-subject)
    (message-header-to :foreground message-header-to)
    (message-header-xheader :foreground secondary-emphasis)
    (message-mml :foreground message-mml)
    (message-separator :foreground message-separator)
    (mm-command-output :foreground message-command-output))
  "Color mappings for Message mode faces with explicit colors.")

(defconst chroma-face-mappings-gnus
  '((gnus-group-mail-1-empty :foreground gnus-mail-1-empty)
    (gnus-group-mail-2-empty :foreground gnus-mail-2-empty)
    (gnus-group-mail-3-empty :foreground gnus-mail-3-empty)
    (gnus-group-mail-low-empty :foreground gnus-mail-low-empty)
    (gnus-group-news-1-empty :foreground gnus-news-1-empty)
    (gnus-group-news-2-empty :foreground gnus-news-2-empty)
    (gnus-group-news-low-empty :foreground gnus-news-low-empty)
    (gnus-splash :foreground fg-gnus-splash)
    (gnus-summary-cancelled
     :foreground gnus-summary-cancelled :background fixed-black)
    (gnus-summary-normal-ancient :foreground gnus-summary-ancient)
    (gnus-summary-normal-read :foreground gnus-summary-read)
    (gnus-summary-normal-ticked :foreground gnus-summary-ticked)
    (gnus-summary-normal-undownloaded
     :foreground gnus-summary-undownloaded))
  "Color mappings for Gnus faces with explicit standard colors.")

(defconst chroma-face-mappings-merge
  '((smerge-base :background secondary-current-c)
    (smerge-lower :background secondary-current-b)
    (smerge-markers :background bg-highlight)
    (smerge-refined-added :background secondary-fine-b)
    (smerge-refined-removed :background primary-fine-a)
    (smerge-upper :background primary-current-a))
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
    (eww-form-checkbox
     :foreground fixed-black :background bg-fixed-light-gray)
    (eww-form-file
     :foreground fixed-black :background bg-fixed-gray-80)
    (eww-form-select
     :foreground fixed-black :background bg-fixed-light-gray)
    (eww-form-submit
     :foreground fixed-black :background bg-fixed-gray-80)
    (eww-form-text
     :foreground fg-fixed-light :background bg-fixed-gray-50)
    (eww-form-textarea
     :foreground fixed-black :background bg-fixed-gray-192)
    (eww-invalid-certificate :foreground primary-alert)
    (eww-valid-certificate :foreground secondary-steady)
    (shr-mark :foreground fixed-black :background contrast-yellow-1)
    (shr-selected-link :background error-alert)
    (speedbar-button-face :foreground speedbar-button)
    (speedbar-directory-face :foreground primary-emphasis)
    (speedbar-file-face :foreground primary-status-success)
    (speedbar-highlight-face :background speedbar-highlight)
    (speedbar-selected-face :foreground primary-alert)
    (speedbar-separator-face
     :foreground fg-fixed-light :background custom-state-background)
    (speedbar-tag-face :foreground secondary-polarity-strong)
    (tty-menu-disabled-face
     :foreground fg-fixed-light-gray :background custom-state-background)
    (tty-menu-enabled-face
     :foreground contrast-yellow-1 :background custom-state-background)
    (tty-menu-selected-face :background secondary-alert))
  "Color mappings for selected built-in application faces.")

(defconst chroma-face-mappings-additional-built-ins
  '((breakpoint-disabled :foreground breakpoint-disabled)
    (breakpoint-enabled :foreground contrast-red-1)
    (erc-direct-msg-face :foreground erc-direct-message)
    (erc-error-face :foreground contrast-red-1)
    (erc-input-face :foreground erc-input)
    (erc-my-nick-face :foreground erc-input)
    (erc-nick-msg-face :foreground erc-direct-message)
    (erc-notice-face :foreground erc-notice)
    (erc-prompt-face
     :foreground fixed-black :background erc-prompt-background)
    (eshell-ls-archive :foreground eshell-ls-archive)
    (eshell-ls-backup :foreground eshell-ls-backup)
    (eshell-ls-clutter :foreground eshell-ls-clutter)
    (eshell-ls-executable :foreground eshell-ls-executable)
    (eshell-ls-missing :foreground contrast-red-1)
    (eshell-ls-product :foreground eshell-ls-backup)
    (eshell-ls-readonly :foreground eshell-ls-readonly)
    (eshell-ls-special :foreground eshell-ls-special)
    (eshell-ls-unreadable :foreground eshell-ls-unreadable)
    (ibuffer-locked-buffer :foreground ibuffer-locked)
    (log-view-file :background ((light . log-view-file-background)))
    (log-view-message :background ((light . log-view-message-background)))
    (nxml-glyph
     :foreground fixed-black :background bg-fixed-light-gray)
    (proced-cpu :foreground proced-resource)
    (proced-emacs-pid :foreground proced-emacs-pid)
    (proced-executable :foreground proced-executable)
    (proced-interruptible-sleep-status-code
     :foreground proced-interruptible-sleep)
    (proced-mem :foreground proced-resource)
    (proced-memory-high-usage :foreground proced-memory-high)
    (proced-memory-low-usage :foreground proced-memory-low)
    (proced-memory-medium-usage :foreground proced-memory-medium)
    (proced-pgrp :foreground proced-pgrp)
    (proced-pid :foreground proced-pid)
    (proced-ppid :foreground proced-ppid)
    (proced-run-status-code :foreground proced-run-status)
    (proced-sess :foreground proced-sess)
    (proced-session-leader-pid :foreground proced-pid)
    (proced-time-colon :foreground proced-time-colon)
    (proced-uninterruptible-sleep-status-code
     :foreground contrast-red-1)
    (rcirc-bright-nick :foreground rcirc-bright-nick)
    (rcirc-my-nick :foreground rcirc-my-nick)
    (rcirc-nick-in-message :foreground rcirc-nick-in-message)
    (rcirc-other-nick :foreground rcirc-other-nick)
    (rcirc-prompt :foreground rcirc-prompt)
    (rcirc-server :foreground rcirc-server)
    (rst-level-1 :background rst-level-1-background)
    (rst-level-2 :background rst-level-2-background)
    (rst-level-3 :background rst-level-3-background)
    (rst-level-4 :background rst-level-4-background)
    (rst-level-5 :background rst-level-5-background)
    (rst-level-6 :background rst-level-6-background))
  "Color mappings from the expanded Emacs 30 built-in audit.")

(defconst chroma--true-color-display
  '((class color) (min-colors 16777216))
  "Face display condition supported by the initial release.")

(defun chroma--base-face-symbol (face)
  "Return Chroma's private default-spec proxy for FACE."
  (intern (concat "chroma--base-" (symbol-name face))))

(defun chroma--ensure-base-face (face)
  "Return a proxy face that retains FACE's upstream default spec."
  (let ((base-face (chroma--base-face-symbol face))
        (default-spec (copy-tree (get face 'face-defface-spec))))
    (unless (equal (get base-face 'face-defface-spec) default-spec)
      (face-spec-set base-face default-spec 'face-defface-spec))
    base-face))

(defun chroma-face-mappings ()
  "Return all Chroma face-to-semantic-role mappings."
  (append chroma-face-mappings-basic
          chroma-face-mappings-font-lock
          chroma-face-mappings-ui
          chroma-face-mappings-search
          chroma-face-mappings-completion
          chroma-face-mappings-diagnostics
          chroma-face-mappings-ert
          chroma-face-mappings-diff
          chroma-face-mappings-ediff
          chroma-face-mappings-ansi
          chroma-face-mappings-custom
          chroma-face-mappings-org
          chroma-face-mappings-misc
          chroma-face-mappings-tools
          chroma-face-mappings-message
          chroma-face-mappings-gnus
          chroma-face-mappings-merge
          chroma-face-mappings-applications
          chroma-face-mappings-additional-built-ins
          (chroma-external-face-mappings)))

(defun chroma-face-mapping (face)
  "Return the semantic color mapping for FACE, or nil if absent."
  (cdr (assq face (chroma-face-mappings))))

(defun chroma--resolve-face-attributes (mapping colors &optional variant)
  "Resolve a face MAPPING using semantic role alist COLORS.

VARIANT defaults to `chroma-variant'.  A mapping role may instead be an
alist from variants to roles when upstream owns that color attribute only
in particular variants.  An absent variant deliberately leaves the
attribute to the upstream proxy."
  (let (attributes)
    (while mapping
      (let* ((attribute (pop mapping))
             (source (pop mapping))
             (role (if (symbolp source)
                       source
                     (alist-get (or variant chroma-variant) source)))
             (color (and role (alist-get role colors))))
        (unless (memq attribute chroma-face-color-attributes)
          (error "Chroma mapping uses non-color attribute %S" attribute))
        (when (and role (null color))
          (error "Chroma mapping refers to unknown semantic role %S" role))
        (when role
          (setq attributes (append attributes (list attribute color))))))
    attributes))

(defun chroma-build-face-specs (&optional colors mappings)
  "Build theme face specs from semantic COLORS.

COLORS defaults to `chroma-resolve-semantic-colors'.  MAPPINGS defaults
to all Chroma mappings and may select an incremental subset.  Only faces
that exist in the running Emacs are returned.  This avoids manufacturing
newer-version faces on older Emacs releases; `chroma-theme-refresh' adds
mappings for built-in faces that are defined later."
  (let ((resolved-colors (or colors (chroma-resolve-semantic-colors))))
    (delq nil
          (mapcar
           (lambda (mapping)
             (let ((face (car mapping)))
               (when (facep face)
                 (let ((attributes
                        (chroma--resolve-face-attributes
                         (cdr mapping) resolved-colors chroma-variant)))
                   ;; A matching theme spec replaces the upstream `defface'
                   ;; spec instead of merging with it.  Inherit a private
                   ;; proxy of that spec so Chroma can replace colors without
                   ;; dropping structural attributes such as `:inverse-video',
                   ;; `:underline', `:box', and `:inherit'.  `default' is
                   ;; special: its font and geometry come from frame defaults.
                   (unless (eq face 'default)
                     (setq attributes
                           (cons :inherit
                                 (cons (chroma--ensure-base-face face)
                                       attributes))))
                   (list face
                         (list
                          (list chroma--true-color-display attributes)))))))
           (or mappings (chroma-face-mappings))))))

(provide 'chroma-faces)

;;; chroma-faces.el ends here
