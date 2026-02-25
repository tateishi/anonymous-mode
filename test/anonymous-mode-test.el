;;; anonymous-mode-test.el --- Tests -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(require 'ert)
(require 'anonymous-mode)

(ert-deftest anonymous-mode-loads ()
  (with-temp-buffer
    (anonymous-mode)
    (should (eq major-mode 'anonymous-mode))))

(ert-deftest anonymous-indent-basic ()
  (with-temp-buffer
    (insert "def foo:\n")
    (anonymous-mode)
    (goto-char (point-max))
    (insert "x")
    (anonymous-indent-line)
    (beginning-of-line)
    (should (= (current-indentation) anonymous-indent-offset))))

;;; anonymous-mode-test.el ends here
