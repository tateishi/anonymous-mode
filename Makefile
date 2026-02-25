EMACS ?= emacs

.PHONY: test lint byte-complie

test:
	cask exec ert-runner

lint:
	${EMACS} -Q --batch -l elisp-mode \
	  -eval "(checkdoc-file \"anonymous-mode.el\")"

byte-compile:
	${EMACS} -Q --batch -f batch-byte-compile anonymous-mode.el
