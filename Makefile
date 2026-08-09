EMACS ?= emacs

ELFILES = chroma-palette.el chroma-core.el chroma-faces-external.el \
	chroma-faces.el chroma-theme.el
TESTFILES = test/chroma-palette-test.el \
	test/chroma-core-test.el \
	test/chroma-faces-test.el \
	test/chroma-contrast-test.el

.PHONY: all compile test checkdoc clean-elc

all: compile test

compile:
	$(EMACS) -Q --batch -L . -f batch-byte-compile $(ELFILES)

test:
	$(EMACS) -Q --batch -L . -L test \
		$(addprefix -l ,$(TESTFILES)) \
		-f ert-run-tests-batch-and-exit

checkdoc:
	$(EMACS) -Q --batch -L . --eval \
		"(progn (require 'checkdoc) (dolist (file '(\"chroma-palette.el\" \"chroma-core.el\" \"chroma-faces-external.el\" \"chroma-faces.el\" \"chroma-theme.el\")) (checkdoc-file file)))"

clean-elc:
	$(RM) $(ELFILES:.el=.elc) test/*.elc
