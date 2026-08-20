;;; chroma-core-test.el --- Tests for Chroma core  -*- lexical-binding: t; -*-

;;; Code:

(require 'ert)
(require 'chroma-core)

(ert-deftest chroma-core-auto-secondary-pairs ()
  "Every primary hue resolves to its symmetric complementary partner."
  (should (equal (mapcar #'car chroma-primary-secondary-pairs)
                 chroma-supported-hues))
  (dolist (pair chroma-primary-secondary-pairs)
    (let ((secondary (chroma-resolve-secondary (car pair) 'auto)))
      (should (eq secondary (cdr pair)))
      (should (eq (chroma-resolve-secondary secondary 'auto)
                  (car pair))))))

(ert-deftest chroma-core-explicit-secondary-wins ()
  "An explicit secondary hue overrides the automatic pairing."
  (should (eq (chroma-resolve-secondary 'blue 'orange) 'orange))
  (should (eq (chroma-resolve-secondary 'red 'purple) 'purple)))

(ert-deftest chroma-core-rejects-invalid-options ()
  "Invalid primary and secondary settings fail explicitly."
  (should-error (chroma-resolve-secondary 'ultraviolet 'auto)
                :type 'user-error)
  (should-error (chroma-resolve-secondary 'blue 'ultraviolet)
                :type 'user-error)
  (let ((chroma-primary 'ultraviolet))
    (should-error (chroma-resolve-secondary) :type 'user-error))
  (let ((chroma-secondary 'ultraviolet))
    (should-error (chroma-resolve-secondary) :type 'user-error))
  (let ((chroma-variant 'sepia))
    (should-error (chroma-resolve-semantic-colors) :type 'user-error)))

(ert-deftest chroma-core-resolves-every-semantic-role ()
  "All semantic roles resolve for every supported primary hue."
  (let ((expected-roles (mapcar #'car chroma-semantic-role-sources)))
    (dolist (variant chroma-supported-variants)
      (dolist (primary chroma-supported-hues)
        (let ((colors
               (chroma-resolve-semantic-colors
                primary 'auto variant)))
          (should (= (length colors) (length expected-roles)))
          (dolist (role expected-roles)
            (should (stringp (alist-get role colors)))))))))

(ert-deftest chroma-core-semantic-roles-use-only-selected-hues ()
  "Chromatic semantic roles never select a fixed concrete hue."
  (dolist (source chroma-semantic-role-sources)
    (should (memq (nth 1 source) '(neutral primary secondary))))
  (dolist (variant chroma-supported-variants)
    (let ((colors
           (chroma-resolve-semantic-colors 'blue 'orange variant)))
      (should
       (equal (alist-get 'error colors)
              (chroma-palette-color 'blue 'status-error variant)))
      (should
       (equal (alist-get 'info colors)
              (chroma-palette-color 'blue 'emphasis variant)))
      (should
       (equal (alist-get 'success colors)
              (chroma-palette-color 'orange 'status-success variant)))
      (should
       (equal (alist-get 'warning colors)
              (chroma-palette-color 'orange 'status-warning variant)))
      (should
       (equal (alist-get 'warning-emphasis colors)
              (chroma-palette-color 'orange 'emphasis variant)))
      (should
       (equal (alist-get 'primary-vivid colors)
              (chroma-palette-color 'blue 'vivid variant)))
      (should
       (equal (alist-get 'secondary-refinement colors)
              (chroma-palette-color 'orange 'refinement variant))))))

(ert-deftest chroma-core-semantic-resolution-obeys-override ()
  "Primary and secondary semantic roles use their selected palettes."
  (dolist (variant chroma-supported-variants)
    (let ((colors
           (chroma-resolve-semantic-colors 'blue 'orange variant)))
      (should (equal (alist-get 'primary colors)
                     (chroma-palette-color 'blue 'base variant)))
      (should (equal (alist-get 'secondary colors)
                     (chroma-palette-color 'orange 'base variant)))
      (should (equal (alist-get 'visited-link colors)
                     (chroma-palette-color
                      'orange 'visited-link variant))))))

(ert-deftest chroma-core-options-are-customizable ()
  "Primary, secondary, and variant options are Customize variables."
  (dolist (option '(chroma-primary chroma-secondary chroma-variant))
    (should (custom-variable-p option))
    (should (get option 'custom-type))))

(ert-deftest chroma-core-expanded-built-in-roles-have-exact-sources ()
  "Expanded built-in roles retain their reviewed selector and token."
  (dolist
      (source
       '((breakpoint-disabled neutral fixed-gray-70)
         (eshell-ls-unreadable neutral fg-eshell-unreadable)
         (proced-interruptible-sleep neutral fixed-dim-gray)
         (log-view-file-background neutral fixed-gray-70)
         (log-view-message-background neutral fixed-gray-85)
         (erc-direct-message primary erc-direct-message)
         (erc-input primary erc-input)
         (erc-notice secondary erc-notice)
         (erc-prompt-background primary erc-prompt-background)
         (eshell-ls-archive secondary eshell-ls-archive)
         (eshell-ls-backup primary eshell-ls-backup)
         (eshell-ls-clutter primary eshell-ls-clutter)
         (eshell-ls-executable secondary eshell-ls-executable)
         (eshell-ls-readonly primary eshell-ls-readonly)
         (eshell-ls-special secondary eshell-ls-special)
         (ibuffer-locked primary ibuffer-locked)
         (proced-resource secondary proced-resource)
         (proced-emacs-pid primary proced-emacs-pid)
         (proced-executable primary proced-executable)
         (proced-memory-high primary proced-memory-high)
         (proced-memory-low secondary proced-memory-low)
         (proced-memory-medium secondary proced-memory-medium)
         (proced-pgrp primary proced-pgrp)
         (proced-pid primary proced-pid)
         (proced-ppid primary proced-ppid)
         (proced-run-status secondary source-green-1)
         (proced-sess primary proced-sess)
         (proced-time-colon secondary proced-time-colon)
         (rcirc-bright-nick secondary rcirc-bright-nick)
         (rcirc-my-nick primary rcirc-my-nick)
         (rcirc-nick-in-message primary rcirc-nick-in-message)
         (rcirc-other-nick secondary rcirc-other-nick)
         (rcirc-prompt primary rcirc-prompt)
         (rcirc-server secondary rcirc-server)))
    (should (equal (assq (car source) chroma-semantic-role-sources)
                   source))))

(provide 'chroma-core-test)

;;; chroma-core-test.el ends here
