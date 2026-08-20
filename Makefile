EMACS ?= emacs

ELFILES = chroma-palette.el chroma-core.el chroma-faces-external.el \
	chroma-faces.el chroma-theme.el chroma-generate.el
TESTFILES = test/chroma-palette-test.el \
	test/chroma-core-test.el \
	test/chroma-faces-test.el \
	test/chroma-contrast-test.el \
	test/chroma-generate-test.el

.PHONY: all verify compile test reports bootstrap-external \
	check-external-fixtures test-external checkdoc diff-check visuals clean-elc

EXTERNAL_PACKAGES_DIR ?= .external-packages
VISUAL_DIR ?= screenshots
EXTERNAL_PACKAGE_NAMES = avy corfu diff-hl magit tempel transient vundo

all: verify

verify: compile test checkdoc reports diff-check clean-elc

compile:
	$(EMACS) -Q --batch -L . -f batch-byte-compile $(ELFILES)

test:
	$(EMACS) -Q --batch -L . -L test \
		$(addprefix -l ,$(TESTFILES)) \
		-f ert-run-tests-batch-and-exit

reports:
	$(EMACS) -Q --batch -L . -l chroma-generate.el \
		--eval "(chroma-generate-print-audit)"

bootstrap-external:
	sh ./test/bootstrap-external-packages.sh "$(EXTERNAL_PACKAGES_DIR)"

check-external-fixtures:
	@missing=""; \
	for package in $(EXTERNAL_PACKAGE_NAMES); do \
		test -d "$(EXTERNAL_PACKAGES_DIR)/$$package" || missing="$$missing $$package"; \
	done; \
	test -z "$$missing" || { \
		echo "Missing external fixtures:$$missing" >&2; \
		echo "Run 'make bootstrap-external' first." >&2; \
		exit 2; \
	}

test-external: check-external-fixtures
	CHROMA_EXTERNAL_PACKAGES_DIR="$(abspath $(EXTERNAL_PACKAGES_DIR))" \
	$(EMACS) -Q --batch -L . -L test \
		-l test/chroma-external-integration-test.el \
		-f ert-run-tests-batch-and-exit

checkdoc:
	$(EMACS) -Q --batch -L . --eval \
		"(progn (require 'checkdoc) (dolist (file '(\"chroma-palette.el\" \"chroma-core.el\" \"chroma-faces-external.el\" \"chroma-faces.el\" \"chroma-theme.el\" \"chroma-generate.el\")) (checkdoc-file file)))"

diff-check:
	git diff --check

visuals:
	mkdir -p "$(VISUAL_DIR)"
	$(EMACS) -Q -L . -l test/chroma-visual.el \
		--eval "(chroma-visual-export \"$(abspath $(VISUAL_DIR))\")"

clean-elc:
	$(RM) $(ELFILES:.el=.elc) test/*.elc
