;;; anonymous-mode.el --- Indentation-based major mode for .anon -*- lexical-binding: t; -*-

;; Author: Your Name <you@example.com>
;; URL: https://github.com/yourname/anonymous-mode
;; Version: 0.1.0
;; Package-Requires: ((emacs "26.1"))
;; Keywords: languages

;;; Commentary:
;; A minimal major mode for indentation-based "anonymous" files (.anon).
;;
;; Features:
;; - ; line comments
;; - Indentation-based blocks (basic)
;; - Simple font-lock placeholders
;; - auto-mode-alist registration
;;
;; Install:
;;   M-x package-install-file RET /path/to/anonymous-mode.el
;;
;; Usage:
;;   (add-to-list 'auto-mode-alist '("\\.anon\\'" . anonymous-mode))

;;; Code:

(require 'syntax)

(defgroup anonymous nil
  "Major mode for indentation-based anonymous language."
  :group 'languages
  :prefix "anonymous-")

(defcustom anonymous-indent-offset 2
  "Indent width used when increasing indentation."
  :type 'integer
  :safe #'integerp
  :group 'anonymous)

(defvar anonymous-mode-hook nil
  "Hook run when entering `anonymous-mode'.")

(defvar anonymous-mode-map
  (let ((map (make-sparse-keymap)))
    ;; Example: (define-key map (kbd "RET") #'newline-and-indent)
    map)
  "Keymap for `anonymous-mode'.")

;; Syntax table: ; starts line comment, _ is word constituent.
(defvar anonymous-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?\; "<" st)      ; comment start
    (modify-syntax-entry ?\n ">" st)      ; comment end
    (modify-syntax-entry ?_ "w" st)
    st)
  "Syntax table for `anonymous-mode'.")

;; Font-lock (最低限の例: 予約語・定数・関数名っぽい識別子)
(defconst anonymous--keywords
  '("def" "let" "if" "elif" "else" "for" "while" "return" "match" "case" "end"))
(defconst anonymous--constants
  '("true" "false" "null" "nil"))

(defconst anonymous-font-lock-keywords
  `(
    (,(regexp-opt anonymous--keywords 'symbols) . font-lock-keyword-face)
    (,(regexp-opt anonymous--constants 'symbols) . font-lock-constant-face)
    ;; def name:
    ("\\_<def\\s-+\\([A-Za-z_][A-Za-z0-9_]*\\)\\_>" 1 font-lock-function-name-face)
    ))

;; ========== インデント ==========
;; 仕様（暫定）:
;; - 前行のインデントを基本的に継承。
;; - 前行がブロックを開始すると判断できる語（例: "def", "if", "for", "while", "match", "case", ":"で終わる等）の場合は +offset。
;; - 現行行が「明らかに閉じ」のキーワードで始まる場合（例: "elif", "else", "end" 等）は -offset。
;; ★ 実際の言語仕様に合わせてルールを調整してください。
(defun anonymous--line-indentation ()
  "Compute indentation level (columns) for current line in `anonymous-mode'."
  (save-excursion
    (back-to-indentation)
    (let* ((cur-line (thing-at-point 'line t))
           (cur-trim (and cur-line (string-trim-left cur-line)))
           (cur-dedent (and cur-trim
                            (string-match-p
                             (rx line-start
                                 (or "elif" "else" "end" "case")
                                 symbol-end)
                             cur-trim)))
           )
      ;; 1) 先行行のインデント取得
      (forward-line -1)
      (let ((base (if (bobp) 0
                    (progn (back-to-indentation)
                           (current-column))))
            )
        ;; 2) 先行行がブロック開始か？
        (let* ((prev-line (thing-at-point 'line t))
               (prev-trim (and prev-line (string-trim-right (string-trim-left prev-line))))
               )
          (when prev-trim
            (let ((opens-block
                   (or
                    ;; 末尾コロン「:」で増やす（お好み）
                    (string-match-p (rx ":" string-end) prev-trim)
                    ;; ブロック開始っぽいキーワード
                    (string-match-p
                     (rx symbol-start
                         (or "def" "if" "for" "while" "match" "case")
                         symbol-end)
                     prev-trim)))
                  ); )
            (setq base (if opens-block
                           (+ base anonymous-indent-offset)
                         base))))
        ;; 3) 現行行が dedent キーワードで始まるなら 1 段戻す
        (when cur-dedent
          (setq base (max 0 (- base anonymous-indent-offset))))
        (max 0 base))))))

(defun anonymous-indent-line ()
  "Indent current line according to indentation-based block rules."
  (interactive)
  (let ((target (anonymous--line-indentation))
        (pos (- (point-max) (point))))
    (indent-line-to target)
    ;; 文字が先頭より右にある場合はカーソルを相対位置で維持
    (when (> (- (point-max) pos) (line-end-position))
      (goto-char (- (point-max) pos)))))

;; imenu（例: def 名 を拾う）
(defvar anonymous-imenu-generic-expression
  '(("Definitions" "^\\s-*def\\s-+\\([A-Za-z_][A-Za-z0-9_]*\\)" 1))
  "Imenu expressions for `anonymous-mode'.")

;;;###autoload
(define-derived-mode anonymous-mode prog-mode "Anonymous"
  "Major mode for indentation-based anonymous language (.anon)."
  :group 'anonymous
  :syntax-table anonymous-syntax-table
  (setq-local font-lock-defaults '(anonymous-font-lock-keywords))
  (setq-local comment-start "; ")
  (setq-local comment-end "")
  (setq-local comment-start-skip ";+\\s-*")
  (setq-local indent-line-function #'anonymous-indent-line)
  (setq-local imenu-generic-expression anonymous-imenu-generic-expression)
  (setq-local electric-indent-inhibit nil))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.anon\\'" . anonymous-mode))

(provide 'anonymous-mode)
;;; anonymous-mode.el ends here
