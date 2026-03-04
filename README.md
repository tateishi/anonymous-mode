# anonymou-mode

Identation-based major mode for `.anon` files.

## install

### package.el (local)

```
M-x package-install RET /path/to/anonymous-mode.el
```

### straight.el + use-package

```elisp
(use-package anonymou-mode
  :straight (anonymou-mode: type git :host github :repo "tateishi/anonymous-mode")
  :mode "\\.anon\\'"
  :custom (anonymous-indent-offset 4))
```

### use-package (emacs >= 30 or + vc-use-package)

```elisp
(use-package anonymous-mode
  :vc (:url "https://github.com/tateishi/anonymous-mode/" :rev :newest)
  :mode "\\.anon\\'"
  :custom (anonymous-indent-offset 4))
```

## Usage

Open a .anon file and start editing.  Identation is block-based.
