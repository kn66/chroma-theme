;;; chroma-faces-test.el --- Chroma face tests  -*- lexical-binding: t; -*-

;;; Code:

(require 'ert)
(require 'cl-lib)
(require 'chroma-faces)

(defconst chroma-test--project-directory
  (expand-file-name ".." (file-name-directory
                           (or load-file-name buffer-file-name)))
  "Chroma project directory used by theme-loading tests.")

(defconst chroma-test--audited-built-in-libraries
  '(tab-bar tab-line hl-line display-line-numbers isearch replace
    paren compile diff-mode ediff ansi-color cus-edit wid-edit ert org
    pulse sh-script dired help-mode info calendar whitespace message
    smerge-mode bookmark edmacro epa em-prompt eww shr speedbar tmm)
  "Built-in libraries included in Chroma's reverse face audit.")

(defun chroma-test--load-audited-built-ins ()
  "Load all libraries included in the built-in face audit."
  (dolist (library chroma-test--audited-built-in-libraries)
    (require library nil t)))

(require 'chroma-theme)

(defun chroma-test--theme-attribute (face attribute)
  "Return FACE's ATTRIBUTE stored for the Chroma theme."
  (let* ((theme-entry (assq 'chroma (get face 'theme-face)))
         (spec (cadr theme-entry))
         (attributes (cadr (car spec))))
    (plist-get attributes attribute)))

(defun chroma-test--theme-foreground (face)
  "Return FACE's foreground stored for the Chroma theme."
  (chroma-test--theme-attribute face :foreground))

(ert-deftest chroma-theme-registers-library-directory-for-discovery ()
  "Loading the library makes Chroma discoverable by `load-theme'."
  (let ((theme-directory
         (file-name-as-directory chroma-test--project-directory)))
    (should (member theme-directory custom-theme-load-path))
    (should (memq 'chroma (custom-available-themes)))))

(ert-deftest chroma-theme-applies-built-in-faces-defined-after-enable ()
  "Built-in faces loaded after Chroma receive their recorded theme spec."
  (let ((old-primary chroma-primary)
        (old-variant chroma-variant)
        (was-enabled (memq 'chroma custom-enabled-themes)))
    (unwind-protect
        (progn
          (setq chroma-primary 'purple
                chroma-variant 'light)
          (enable-theme 'chroma)
          (require 'org)
          (should
           (equal
            (chroma-test--theme-foreground 'org-todo)
            (chroma-palette-color 'purple 'status-error 'light))))
      (setq chroma-primary old-primary
            chroma-variant old-variant)
      (chroma-theme-refresh)
      (unless was-enabled
        (disable-theme 'chroma)))))

(ert-deftest chroma-theme-enable-resolves-post-load-setq ()
  "Enabling Chroma rebuilds specs changed by a post-load `setq'."
  (let ((old-primary chroma-primary)
        (was-enabled (memq 'chroma custom-enabled-themes)))
    (unwind-protect
        (progn
          (setq chroma-primary 'yellow)
          (enable-theme 'chroma)
          (should (equal
                   (chroma-test--theme-foreground
                    'font-lock-keyword-face)
                   (chroma-palette-color 'yellow 'vivid))))
      (setq chroma-primary old-primary)
      (chroma-theme-refresh)
      (unless was-enabled
        (disable-theme 'chroma)))))

(ert-deftest chroma-theme-switches-between-dark-and-light-palettes ()
  "Changing `chroma-variant' replaces colors and theme metadata."
  (let ((old-variant chroma-variant)
        (was-enabled (memq 'chroma custom-enabled-themes)))
    (unwind-protect
        (progn
          (unless was-enabled
            (enable-theme 'chroma))
          (dolist (variant chroma-supported-variants)
            (setq chroma-variant variant)
            (chroma-theme-refresh)
            (should
             (equal
              (chroma-test--theme-attribute 'default :background)
              (chroma-palette-color 'neutral 'bg-main variant)))
            (should
             (eq (plist-get (get 'chroma 'theme-properties)
                            :background-mode)
                 variant))))
      (setq chroma-variant old-variant)
      (chroma-theme-refresh)
      (unless was-enabled
        (disable-theme 'chroma)))))

(ert-deftest chroma-faces-major-mappings-use-expected-roles ()
  "Major built-in faces map to their intended semantic roles."
  (dolist (expectation
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
             (font-lock-builtin-face :foreground primary-emphasis)
             (font-lock-comment-face :foreground primary)
             (font-lock-constant-face :foreground secondary-vivid)
             (font-lock-function-name-face :foreground primary-emphasis)
             (font-lock-keyword-face :foreground primary-vivid)
             (font-lock-string-face :foreground secondary-emphasis)
             (font-lock-type-face :foreground font-lock-type)
             (font-lock-variable-name-face :foreground secondary-vivid)
             (mode-line
              :foreground mode-line-source-foreground
              :background mode-line-source-background)
             (mode-line-inactive
              :foreground mode-line-inactive-foreground
              :background mode-line-inactive-background)
             (header-line
              :foreground header-line-source-foreground
              :background header-line-source-background)
             (minibuffer-prompt :foreground primary-emphasis)
             (match :background match)
             (lazy-highlight
              :background alternate-selection)
             (isearch
              :foreground isearch-foreground
              :background isearch-background)))
    (should (equal (chroma-face-mapping (car expectation))
                   (cdr expectation)))))

(ert-deftest chroma-faces-reviewed-low-confidence-use-dedicated-roles ()
  "Reviewed ambiguous faces use their source-specific semantic roles."
  (dolist
      (expectation
       '((compilation-mode-line-exit :foreground compilation-exit)
         (custom-button-pressed-unraised
          :foreground custom-button-pressed-unraised)
         (escape-glyph :foreground special-glyph)
         (homoglyph :foreground special-glyph)
         (nobreak-hyphen :foreground special-glyph)
         (font-lock-type-face :foreground font-lock-type)
         (ansi-color-magenta
          :foreground secondary-ansi-magenta
          :background secondary-ansi-magenta)
         (ansi-color-bright-magenta
          :foreground secondary-ansi-bright-magenta
          :background secondary-ansi-bright-magenta)
         (ansi-color-green
          :foreground secondary-ansi-green
          :background secondary-ansi-green)
         (ansi-color-bright-green
          :foreground secondary-ansi-bright-green
          :background secondary-ansi-bright-green)
         (blink-matching-paren-offscreen :foreground blink-offscreen)
         (custom-state :foreground custom-state-foreground)
         (widget-documentation :foreground custom-state-foreground)
         (org-agenda-done :foreground org-done)
         (org-done :foreground org-done)
         (org-scheduled :foreground org-scheduled)
         (org-scheduled-today :foreground org-scheduled)
         (message-header-cc :foreground message-header-cc)
         (message-header-name :foreground message-header-name)
         (message-header-newsgroups :foreground message-header-newsgroups)
         (message-header-other :foreground message-header-other)
         (message-header-subject :foreground message-header-subject)
         (message-header-to :foreground message-header-to)
         (message-mml :foreground message-mml)
         (message-separator :foreground message-separator)
         (sh-quoted-exec :foreground sh-quoted-exec)
         (speedbar-button-face :foreground speedbar-button)
         (speedbar-highlight-face :background speedbar-highlight)))
    (should (equal (chroma-face-mapping (car expectation))
                   (cdr expectation)))))

(ert-deftest chroma-faces-hl-line-and-region-use-different-hues ()
  "Inherited current-line and region backgrounds use different hues."
  (should-not (chroma-face-mapping 'hl-line))
  (dolist (variant chroma-supported-variants)
    (let* ((colors
            (chroma-resolve-semantic-colors 'blue 'orange variant))
           (hl-line
            (chroma--resolve-face-attributes
             (chroma-face-mapping 'highlight) colors))
           (region
            (chroma--resolve-face-attributes
             (chroma-face-mapping 'region) colors))
           (hl-line-background (plist-get hl-line :background))
           (region-background (plist-get region :background)))
      (should
       (equal hl-line-background
              (chroma-palette-color 'blue 'refinement variant)))
      (should
       (equal region-background
              (chroma-palette-color 'orange 'selection variant)))
      (should-not (equal hl-line-background region-background)))))

(ert-deftest chroma-faces-search-states-remain-distinct ()
  "Match, lazy search, and matching parens use distinct finite tones."
  (let* ((colors (chroma-resolve-semantic-colors 'blue 'orange 'light))
         (backgrounds
          (mapcar
           (lambda (face)
             (plist-get
              (chroma--resolve-face-attributes
               (chroma-face-mapping face) colors)
              :background))
           '(match lazy-highlight show-paren-match))))
    (should (= (length (delete-dups backgrounds)) 3)))
  (should-not (chroma-face-mapping 'show-paren-match-expression)))

(ert-deftest chroma-faces-source-distinct-levels-do-not-collapse ()
  "Mappings retain audited distinctions between related source faces."
  (should-not
   (equal (chroma-face-mapping 'window-divider-first-pixel)
          (chroma-face-mapping 'window-divider-last-pixel)))
  (should-not
   (equal (chroma-face-mapping 'smerge-lower)
          (chroma-face-mapping 'smerge-refined-added)))
  (should-not
   (equal (chroma-face-mapping 'smerge-upper)
          (chroma-face-mapping 'smerge-refined-removed)))
  (should-not
   (equal (chroma-face-mapping 'magit-dimmed)
          (chroma-face-mapping 'magit-hash)))
  (should
   (equal (chroma-face-mapping 'magit-log-graph)
          (chroma-face-mapping 'magit-log-date)))
  (dolist (variant chroma-supported-variants)
    (dolist (primary chroma-supported-hues)
      (let* ((colors
              (chroma-resolve-semantic-colors primary 'auto variant))
             (base
              (chroma--resolve-face-attributes
               (chroma-face-mapping 'magit-diff-base) colors))
             (highlight
              (chroma--resolve-face-attributes
               (chroma-face-mapping 'magit-diff-base-highlight)
               colors)))
        (should-not (equal base highlight))))))

(ert-deftest chroma-faces-ansi-source-levels-remain-distinct ()
  "ANSI colors sharing a selected hue retain standard brightness levels."
  (dolist (family
           '((ansi-color-blue ansi-color-bright-blue
              ansi-color-red ansi-color-bright-red
              ansi-color-cyan ansi-color-bright-cyan)
             (ansi-color-magenta ansi-color-bright-magenta
              ansi-color-green ansi-color-bright-green
              ansi-color-yellow ansi-color-bright-yellow)))
    (let ((mappings (mapcar #'chroma-face-mapping family)))
      (should (= (length mappings)
                 (length (delete-dups mappings)))))))

(ert-deftest chroma-faces-external-packages-use-expected-roles ()
  "External package roots map only their explicit default colors."
  (should
   (equal chroma-supported-external-packages
          '(avy corfu diff-hl magit tempel transient vundo)))
  (dolist
      (expectation
       '((corfu-current
          :foreground corfu-current-foreground
          :background corfu-current-background)
         (corfu-indexed
          :foreground corfu-indexed-foreground
          :background corfu-indexed-background)
         (corfu-quick1
          :foreground corfu-quick-foreground
          :background corfu-quick-1-background)
         (corfu-quick2
          :foreground corfu-quick-foreground
          :background corfu-quick-2-background)
         (diff-hl-insert :foreground success-emphasis)
         (diff-hl-delete :foreground error-emphasis)
         (diff-hl-change
          :foreground diff-hl-change-foreground
          :background diff-hl-change-background)
         (tempel-field
          :foreground tempel-field-foreground
          :background tempel-field-background)
         (tempel-form
          :foreground tempel-form-foreground
          :background tempel-form-background)
         (avy-lead-face
          :foreground fixed-white :background avy-lead-background)
         (avy-lead-face-2
          :foreground fixed-white :background avy-lead-2-background)
         (vundo-highlight :foreground primary-emphasis)
         (vundo-saved :foreground secondary)
         (vundo-diff-highlight :foreground vundo-diff-highlight)
         (transient-disabled-suffix
          :foreground fixed-black
          :background transient-disabled-background)
         (transient-enabled-suffix
          :foreground fixed-black
          :background transient-enabled-background)
         (transient-key-noop :foreground transient-key-noop)
         (transient-key-exit :foreground error-emphasis)
         (transient-key-stay :foreground secondary-polarity)
         (magit-section-heading :foreground primary-emphasis)
         (magit-branch-local :foreground primary-emphasis)
         (magit-branch-remote :foreground secondary)
         (magit-diff-removed
          :foreground magit-red-pale :background magit-red-deep)
         (magit-diff-added
          :foreground magit-green-pale :background magit-green-deep)
         (magit-diff-base
          :foreground magit-base-pale :background magit-base-deep)
         (magit-diff-removed-highlight
          :foreground magit-red-highlight-foreground
          :background magit-red-highlight-background)
         (magit-diff-added-highlight
          :foreground magit-green-highlight-foreground
          :background magit-green-highlight-background)
         (magit-diff-base-highlight
          :foreground magit-base-highlight-foreground
          :background magit-base-highlight-background)
         (magit-diff-lines-heading
          :foreground ((dark . magit-lines-foreground))
          :background magit-lines-background)
         (magit-process-ok :foreground success-emphasis)
         (magit-process-ng :foreground error-emphasis)))
    (should (equal (chroma-face-mapping (car expectation))
                   (cdr expectation))))
  ;; These faces inherit a mapped root upstream.  Mapping them as well would
  ;; duplicate and freeze package-owned inheritance decisions.
  (dolist (face '(corfu-popupinfo vundo-last-saved
                  magit-branch-current magit-diff-hunk-region
                  magit-diff-their))
    (should-not (chroma-face-mapping face))))

(ert-deftest chroma-faces-standard-inheritance-is-not-frozen ()
  "Faces whose defaults only inherit another face remain unmapped."
  (dolist
      (face
       '(font-lock-comment-delimiter-face font-lock-doc-face
         font-lock-function-call-face font-lock-misc-punctuation-face
         font-lock-preprocessor-face font-lock-property-name-face
         font-lock-property-use-face font-lock-regexp-face
         font-lock-variable-use-face font-lock-warning-face
         button nobreak-space mode-line-active mode-line-emphasis
         mode-line-highlight header-line-highlight line-number
         hl-line fill-column-indicator
         help-argument-name calendar-today info-menu-header
         show-paren-match-expression query-replace
         completions-annotations completions-highlight
         completions-first-difference compilation-error
         compilation-warning compilation-info compilation-line-number
         compilation-column-number diff-hunk-header line-number-current-line
         dired-directory dired-flagged dired-header dired-ignored
         dired-mark dired-marked dired-perm-write dired-set-id
         dired-special dired-symlink tab-bar-tab))
    (should-not (chroma-face-mapping face))))

(ert-deftest chroma-faces-colorless-standard-faces-remain-unmapped ()
  "Faces with no standard color do not gain a Chroma color."
  (dolist
      (face
       '(font-lock-negation-char-face font-lock-number-face
         font-lock-operator-face font-lock-punctuation-face
         font-lock-regexp-grouping-backslash
         font-lock-regexp-grouping-construct
         vertical-border internal-border child-frame-border))
    (should-not (chroma-face-mapping face))))

(ert-deftest chroma-faces-built-in-mappings-match-upstream-color-attributes ()
  "Built-in mappings replace all and only directly specified colors."
  (chroma-test--load-audited-built-ins)
  (let ((external-faces (mapcar #'car (chroma-external-face-mappings)))
        (old-display-type (frame-parameter nil 'display-type))
        (old-background-mode (frame-parameter nil 'background-mode)))
    (unwind-protect
        (cl-letf (((symbol-function 'display-color-cells)
                   (lambda (&optional _frame) 16777216))
                  ((symbol-function 'window-system)
                   (lambda (&optional _frame) 'pgtk)))
          (dolist (mapping (chroma-face-mappings))
            (let ((face (car mapping)))
              (when (and (facep face)
                         (not (eq face 'default))
                         (not (memq face external-faces)))
                (let (default-color-attributes)
                  (dolist (mode '(light dark))
                    (modify-frame-parameters
                     nil (list (cons 'display-type 'color)
                               (cons 'background-mode mode)))
                    (let ((attributes
                           (face-spec-choose
                            (get face 'face-defface-spec))))
                      (dolist (attribute chroma-face-color-attributes)
                        (when (and (plist-member attributes attribute)
                                   (not (eq (plist-get attributes attribute)
                                            'unspecified)))
                          (cl-pushnew attribute
                                      default-color-attributes)))))
                  (let ((mapped-attributes
                         (cl-loop for (attribute _role) on (cdr mapping)
                                  by #'cddr collect attribute)))
                    (should
                     (equal (sort mapped-attributes
                                  (lambda (first second)
                                    (string< (symbol-name first)
                                             (symbol-name second))))
                            (sort default-color-attributes
                                  (lambda (first second)
                                    (string< (symbol-name first)
                                             (symbol-name second))))))))))))
      (modify-frame-parameters
       nil (list (cons 'display-type old-display-type)
                 (cons 'background-mode old-background-mode))))))

(ert-deftest chroma-faces-all-direct-built-in-colors-are-mapped ()
  "Every loaded built-in face with a direct simple color is mapped."
  (chroma-test--load-audited-built-ins)
  (let ((old-display-type (frame-parameter nil 'display-type))
        (old-background-mode (frame-parameter nil 'background-mode))
        (mapped-faces (mapcar #'car (chroma-face-mappings)))
        (audited-count 0))
    (unwind-protect
        (cl-letf (((symbol-function 'display-color-cells)
                   (lambda (&optional _frame) 16777216))
                  ((symbol-function 'window-system)
                   (lambda (&optional _frame) 'pgtk)))
          (dolist (face (face-list))
            (unless (string-prefix-p "chroma--base-" (symbol-name face))
              (let (direct-color-p)
                (dolist (mode '(light dark))
                  (modify-frame-parameters
                   nil (list (cons 'display-type 'color)
                             (cons 'background-mode mode)))
                  (let ((attributes
                         (face-spec-choose
                          (get face 'face-defface-spec))))
                    (dolist (attribute chroma-face-color-attributes)
                      (when (stringp (plist-get attributes attribute))
                        (setq direct-color-p t)))))
                (when direct-color-p
                  (setq audited-count (1+ audited-count))
                  (should (memq face mapped-faces)))))))
      (modify-frame-parameters
       nil (list (cons 'display-type old-display-type)
                 (cons 'background-mode old-background-mode))))
    ;; Guard against accidentally running the audit before its libraries load.
    (should (> audited-count 220))))

(ert-deftest chroma-faces-source-relative-regressions-use-dedicated-roles ()
  "High-risk faces use roles matching their standard prominence."
  (dolist
      (expectation
       '((org-mode-line-clock-overrun :background error-alert)
         (fringe :background bg-main)
         (window-divider :foreground window-divider)
         (diff-indicator-added :foreground secondary-indicator-added)
         (diff-indicator-removed :foreground primary-indicator-removed)
         (diff-indicator-changed
          :foreground secondary-changed-indicator)
         (ediff-fine-diff-A :background primary-fine-a)
         (ediff-fine-diff-Ancestor :background primary-fine-ancestor)
         (ediff-fine-diff-B :background secondary-fine-b)
         (ediff-fine-diff-C :background secondary-fine-c)
         (whitespace-hspace
          :foreground fg-fixed-gray
          :background whitespace-hspace-background)
         (whitespace-big-indent
          :foreground primary-whitespace-big-foreground
          :background primary-alert)
         (shr-selected-link :background error-alert)))
    (should (equal (chroma-face-mapping (car expectation))
                   (cdr expectation)))))

(ert-deftest chroma-faces-newly-audited-colors-use-exact-roles ()
  "New reverse-audited faces map all and only their direct colors."
  (dolist
      (expectation
       '((ert-test-result-expected :background ert-expected)
         (ert-test-result-unexpected :background ert-unexpected)
         (tab-line-tab-current :background bg-tab-current)
         (tab-line-tab-inactive-alternate
          :background bg-tab-inactive-alternate)
         (separator-line :background bg-separator)
         (tool-bar :foreground fixed-black :background bg-tool-bar)
         (tooltip :foreground fixed-black :background bg-tooltip)
         (icon-button
          :foreground fixed-black :background bg-fixed-gray-80)
         (diff-changed-unspecified
          :background bg-diff-changed-unspecified)
         (ediff-even-diff-A :background bg-ediff-light)
         (ediff-even-diff-Ancestor :background bg-ediff-mid)
         (ediff-even-diff-B :background bg-ediff-mid)
         (ediff-even-diff-C :background bg-ediff-light)
         (ediff-odd-diff-A :background bg-ediff-mid)
         (ediff-odd-diff-Ancestor :background bg-fixed-gray-40)
         (ediff-odd-diff-B :background bg-ediff-light)
         (ediff-odd-diff-C :background bg-ediff-mid)
         (ansi-color-black
          :foreground ansi-black :background ansi-black)
         (ansi-color-bright-black
          :foreground ansi-bright-black :background ansi-bright-black)
         (ansi-color-white
          :foreground ansi-white :background ansi-white)
         (ansi-color-bright-white
          :foreground ansi-bright-white :background ansi-bright-white)
         (custom-button
          :foreground fixed-black :background bg-fixed-light-gray)
         (custom-button-mouse
          :foreground fixed-black :background bg-fixed-gray-90)
         (custom-button-pressed
          :foreground fixed-black :background bg-fixed-light-gray)
         (custom-comment :background bg-input)
         (widget-field :background bg-input)
         (widget-single-line-field :background bg-input)
         (org-agenda-dimmed-todo-face :foreground fg-fixed-gray-50)
         (org-column :background bg-org-column)
         (org-column-title :background bg-org-column)
         (org-hide :foreground bg-main)
         (org-table-header
          :foreground fixed-black :background bg-fixed-light-gray)
         (info-node :foreground info-node)
         (message-cited-text-1 :foreground message-cited-1)
         (message-cited-text-2 :foreground message-cited-2)
         (message-cited-text-3 :foreground message-cited-3)
         (message-cited-text-4 :foreground message-cited-4)
         (mm-command-output :foreground message-command-output)
         (gnus-group-mail-1-empty :foreground gnus-mail-1-empty)
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
          :foreground gnus-summary-undownloaded)
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
          :foreground fixed-black :background bg-fixed-gray-192)))
    (should (equal (chroma-face-mapping (car expectation))
                   (cdr expectation)))))

(ert-deftest chroma-faces-explicit-default-color-attributes-are-covered ()
  "Mappings replace both parts of audited multi-color default faces."
  (dolist
      (expectation
       '((ansi-color-red
          :foreground primary-ansi-mid :background primary-ansi-mid)
         (ansi-color-bright-green
          :foreground secondary-ansi-bright-green
          :background secondary-ansi-bright-green)
         (dired-broken-symlink
          :foreground contrast-yellow-1 :background contrast-red-1)
         (help-key-binding
          :foreground help-key-foreground :background help-key-background)
         (holiday :background warning-muted)
         (line-number-major-tick :background bg-mode-line)
         (line-number-minor-tick :background bg-ui-inactive)
         (tab-line-highlight
          :foreground tab-source-foreground
          :background tab-source-background)
         (whitespace-space
          :foreground fg-fixed-gray
          :background whitespace-space-background)
         (whitespace-tab
          :foreground fg-fixed-gray
          :background whitespace-tab-background)
         (whitespace-space-after-tab
          :foreground contrast-firebrick
          :background contrast-yellow-1)
         (whitespace-space-before-tab
          :foreground contrast-firebrick
          :background contrast-dark-orange)))
    (should (equal (chroma-face-mapping (car expectation))
                   (cdr expectation)))))

(ert-deftest chroma-faces-magit-range-boundary-is-prominent ()
  "Magit's selected range boundary uses a high-contrast primary color."
  (dolist (variant chroma-supported-variants)
    (let* ((colors
            (chroma-resolve-semantic-colors 'yellow 'purple variant))
           (attributes
            (chroma--resolve-face-attributes
             (chroma-face-mapping 'magit-diff-lines-heading)
             colors variant)))
      (if (eq variant 'dark)
          (should
           (equal (plist-get attributes :foreground)
                  (chroma-palette-color
                   'neutral 'magit-lines-foreground variant)))
        (should-not (plist-member attributes :foreground)))
      (should
       (equal (plist-get attributes :background)
              (chroma-palette-color
               'yellow 'magit-lines-background variant)))))
  ;; Magit overlays this structural face on the selected lines.  Its default
  ;; bold weight must remain package-owned, and a background here would hide
  ;; the added/removed line colors underneath it.
  (should-not (chroma-face-mapping 'magit-diff-hunk-region)))

(ert-deftest chroma-faces-mappings-have-unique-faces ()
  "Each face has exactly one semantic mapping."
  (let (seen)
    (dolist (mapping (chroma-face-mappings))
      (should-not (memq (car mapping) seen))
      (push (car mapping) seen))))

(ert-deftest chroma-faces-standard-chromatic-faces-use-selected-hues ()
  "Audited built-in chromatic faces use primary or secondary roles."
  (dolist
      (face
       '(region secondary-selection highlight
         font-lock-comment-face completions-common-part
         compilation-mode-line-exit compilation-mode-line-fail
         custom-changed custom-comment-tag custom-group-tag
         custom-group-tag-1 custom-invalid custom-modified custom-rogue
         custom-set custom-state custom-themed custom-variable-obsolete
         custom-variable-tag widget-button-pressed widget-documentation
         diff-error ediff-current-diff-A ediff-current-diff-B
         ediff-current-diff-C ediff-fine-diff-A ediff-fine-diff-B
         ediff-fine-diff-C elisp-shorthand-font-lock-face
         isearch-group-1 isearch-group-2 org-agenda-done
         org-agenda-structure
         org-clock-overlay org-date org-date-selected
         org-dispatcher-highlight org-document-info org-document-title
         org-done org-drawer org-ellipsis org-footnote org-formula
         org-headline-done org-headline-todo org-latex-and-related
         org-mode-line-clock-overrun org-scheduled
         org-scheduled-previously org-scheduled-today org-sexp-date
         org-table org-time-grid org-todo org-upcoming-deadline
         bookmark-face edmacro-label epa-field-body epa-field-name
         epa-mark epa-string epa-validity-high epa-validity-medium
         eshell-prompt eww-invalid-certificate eww-valid-certificate
         message-header-cc message-header-name message-header-newsgroups
         message-header-other message-header-subject message-header-to
         message-header-xheader message-mml message-separator shr-mark
         shr-selected-link smerge-base smerge-lower smerge-refined-added
         smerge-refined-removed smerge-upper speedbar-button-face
         speedbar-directory-face speedbar-file-face speedbar-highlight-face
         speedbar-selected-face speedbar-separator-face speedbar-tag-face
         tty-menu-disabled-face tty-menu-enabled-face tty-menu-selected-face
         tab-line-close-highlight whitespace-big-indent whitespace-hspace
         whitespace-indentation whitespace-line
         whitespace-missing-newline-at-eof))
    (let ((mapping (chroma-face-mapping face))
          selected-hue-p)
      (should mapping)
      (while mapping
        (pop mapping)
        (let* ((role (pop mapping))
               (source (assq role chroma-semantic-role-sources)))
          (when (memq (nth 1 source) '(primary secondary))
            (setq selected-hue-p t))))
      (should selected-hue-p))))

(ert-deftest chroma-faces-org-source-and-completion-regression ()
  "Org source overlays and inherited completion highlights use selected hues."
  (let* ((variant 'light)
         (colors
          (chroma-resolve-semantic-colors 'purple 'auto variant))
         (primary (chroma-palette-color 'purple 'base variant))
         (primary-refinement
          (chroma-palette-color 'purple 'refinement variant))
         (secondary-selection
          (chroma-palette-color
           'chartreuse 'standalone-selection variant)))
    (should
     (equal
      (plist-get
       (chroma--resolve-face-attributes
       (chroma-face-mapping 'secondary-selection) colors)
       :background)
      secondary-selection))
    (should
     (equal
      (plist-get
       (chroma--resolve-face-attributes
        (chroma-face-mapping 'highlight) colors)
       :background)
      primary-refinement))
    (should-not (chroma-face-mapping 'completions-highlight))
    (should
     (equal
      (plist-get
       (chroma--resolve-face-attributes
        (chroma-face-mapping 'font-lock-comment-face) colors)
      :foreground)
      primary))))

(ert-deftest chroma-faces-purple-auto-magit-added-is-chartreuse ()
  "Purple with automatic Secondary gives Magit additions Chartreuse colors."
  (let* ((variant 'light)
         (colors
          (chroma-resolve-semantic-colors 'purple 'auto variant))
         (added
          (chroma--resolve-face-attributes
           (chroma-face-mapping 'magit-diff-added) colors))
         (removed
          (chroma--resolve-face-attributes
           (chroma-face-mapping 'magit-diff-removed) colors))
         (chartreuse-background
          (chroma-palette-color 'chartreuse 'magit-green-deep variant))
         (purple-background
          (chroma-palette-color 'purple 'magit-red-deep variant)))
    (should (equal (plist-get added :foreground)
                   (chroma-palette-color
                    'chartreuse 'magit-green-pale variant)))
    (should (equal (plist-get added :background) chartreuse-background))
    (should (equal (plist-get removed :background) purple-background))
    (should-not (equal chartreuse-background purple-background))))

(ert-deftest chroma-faces-primary-hue-is-dominant ()
  "Primary supplies at least 55 percent of chromatic mapping attributes."
  (let ((primary-count 0)
        (secondary-count 0))
    (dolist (mapping (chroma-face-mappings))
      (cl-loop
       for (_attribute source) on (cdr mapping) by #'cddr
       do (dolist (role (if (symbolp source)
                            (list source)
                          (mapcar #'cdr source)))
            (let ((selector
                   (nth 1 (assq role chroma-semantic-role-sources))))
              (cond
               ((eq selector 'primary)
                (setq primary-count (1+ primary-count)))
               ((eq selector 'secondary)
                (setq secondary-count (1+ secondary-count))))))))
    (should (> primary-count secondary-count))
    (should (>= (/ (float primary-count)
                   (+ primary-count secondary-count))
                0.55))))

(ert-deftest chroma-faces-mappings-contain-only-color-attributes ()
  "No face mapping can override a structural face attribute."
  (let ((known-roles (mapcar #'car chroma-semantic-role-sources)))
    (dolist (mapping (chroma-face-mappings))
      (should (= (% (length (cdr mapping)) 2) 0))
      (cl-loop
       for (attribute source) on (cdr mapping) by #'cddr
       do (should (memq attribute chroma-face-color-attributes))
       do (if (symbolp source)
              (should (memq source known-roles))
            (let (variants)
              (dolist (entry source)
                (should (memq (car entry) chroma-supported-variants))
                (should-not (memq (car entry) variants))
                (should (memq (cdr entry) known-roles))
                (push (car entry) variants))))))))

(ert-deftest chroma-faces-diff-colors-follow-primary-and-secondary ()
  "Diff colors contain only the selected primary and secondary hues."
  (dolist (variant chroma-supported-variants)
    (let* ((colors
            (chroma-resolve-semantic-colors 'blue 'orange variant))
           (added
            (chroma--resolve-face-attributes
             (chroma-face-mapping 'diff-added) colors))
           (removed
            (chroma--resolve-face-attributes
             (chroma-face-mapping 'diff-removed) colors)))
      (should
       (null (plist-get added :foreground)))
      (should
       (equal (plist-get added :background)
              (chroma-palette-color 'orange 'diff-added variant)))
      (should
       (null (plist-get removed :foreground)))
      (should
       (equal (plist-get removed :background)
              (chroma-palette-color 'blue 'diff-removed variant)))))
  ;; The standard `diff-changed' face has no color of its own.  Refined and
  ;; indicator faces retain the standard changed-state color distinction.
  (should-not (chroma-face-mapping 'diff-changed))
  (should
   (equal (chroma-face-mapping 'diff-refine-changed)
          '(:background secondary-fine-c)))
  (should-not
   (equal (chroma-face-mapping 'diff-added)
          (chroma-face-mapping 'diff-refine-added)))
  (should-not
   (equal (chroma-face-mapping 'diff-removed)
          (chroma-face-mapping 'diff-refine-removed))))

(ert-deftest chroma-faces-generated-specs-inherit-upstream-structure ()
  "Generated specs add only colors and an upstream structural proxy."
  (require 'org)
  (dolist (variant chroma-supported-variants)
    (let ((colors
           (chroma-resolve-semantic-colors nil nil variant)))
      (dolist (setting (chroma-build-face-specs colors))
        (dolist (display-spec (cadr setting))
          (let ((attributes (cadr display-spec)))
            (while attributes
              (let ((attribute (pop attributes))
                    (value (pop attributes)))
                (if (eq attribute :inherit)
                    (progn
                      (should-not (eq (car setting) 'default))
                      (should
                       (eq value
                           (chroma--base-face-symbol (car setting))))
                      (should
                       (equal (get value 'face-defface-spec)
                              (get (car setting) 'face-defface-spec))))
                  (should
                   (memq attribute chroma-face-color-attributes))
                  (should (stringp value))))))))))
  (let ((old-display-type (frame-parameter nil 'display-type))
        (old-background-mode (frame-parameter nil 'background-mode))
        (base-face (chroma--base-face-symbol 'org-date-selected)))
    (unwind-protect
        (cl-letf (((symbol-function 'display-color-cells)
                   (lambda (&optional _frame) 16777216))
                  ((symbol-function 'window-system)
                   (lambda (&optional _frame) 'pgtk)))
          (modify-frame-parameters
           nil '((display-type . color) (background-mode . light)))
          (chroma-build-face-specs)
          (should
           (eq (plist-get
                (face-spec-choose (get base-face 'face-defface-spec))
                :inverse-video)
               t)))
      (modify-frame-parameters
       nil (list (cons 'display-type old-display-type)
                 (cons 'background-mode old-background-mode))))))

(ert-deftest chroma-faces-theme-preserves-non-color-attributes ()
  "Enabling Chroma leaves representative structural attributes intact."
  (chroma-test--load-audited-built-ins)
  (let* ((faces '(default region link mode-line font-lock-keyword-face
                  org-date-selected custom-comment ediff-even-diff-A
                  eww-form-text message-cited-text-1 tool-bar
                  widget-field))
         (attributes '(:family :foundry :width :height :weight :slant
                       :underline :overline :strike-through :box
                       :inverse-video :stipple :extend))
         (was-enabled (memq 'chroma custom-enabled-themes))
         (before
          (mapcar
           (lambda (face)
             (cons face
                   (mapcar (lambda (attribute)
                             (cons attribute
                                   (face-attribute face attribute nil t)))
                           attributes)))
           faces)))
    (unwind-protect
        (progn
          (unless was-enabled
            (enable-theme 'chroma))
          (dolist (face-entry before)
            (dolist (attribute-entry (cdr face-entry))
              (should
               (equal (cdr attribute-entry)
                      (face-attribute (car face-entry)
                                      (car attribute-entry) nil t))))))
      (unless was-enabled
        (disable-theme 'chroma)))))

(ert-deftest chroma-faces-custom-change-refreshes-theme-specs ()
  "Customize changes replace colors stored in an enabled theme."
  (let ((old-primary chroma-primary)
        (old-secondary chroma-secondary)
        (old-primary-theme-value
         (copy-tree (get 'chroma-primary 'theme-value)))
        (old-secondary-theme-value
         (copy-tree (get 'chroma-secondary 'theme-value)))
        (old-primary-customized-value
         (copy-tree (get 'chroma-primary 'customized-value)))
        (old-secondary-customized-value
         (copy-tree (get 'chroma-secondary 'customized-value)))
        (old-user-settings (copy-tree (get 'user 'theme-settings)))
        (was-enabled (memq 'chroma custom-enabled-themes)))
    (unwind-protect
        (progn
          (unless was-enabled
            (enable-theme 'chroma))
          (customize-set-variable 'chroma-secondary 'auto)
          (customize-set-variable 'chroma-primary 'red)
          (should (equal
                   (chroma-test--theme-foreground
                    'font-lock-keyword-face)
                   (chroma-palette-color 'red 'vivid)))
          (should (eq (chroma-resolve-secondary) 'cyan)))
      (unless was-enabled
        (disable-theme 'chroma))
      (set-default 'chroma-primary old-primary)
      (set-default 'chroma-secondary old-secondary)
      (put 'chroma-primary 'theme-value old-primary-theme-value)
      (put 'chroma-secondary 'theme-value old-secondary-theme-value)
      (put 'chroma-primary 'customized-value
           old-primary-customized-value)
      (put 'chroma-secondary 'customized-value
           old-secondary-customized-value)
      (put 'user 'theme-settings old-user-settings)
      (when was-enabled
        (chroma-theme-refresh)))))

(provide 'chroma-faces-test)

;;; chroma-faces-test.el ends here
