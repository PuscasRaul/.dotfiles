(org-babel-load-file
 (expand-file-name
  "config.org"
  user-emacs-directory))
(load "~/.config/emacs/mvn.el")
(setq user-emacs-directory (file-truename "~/.emacs.d/"))

