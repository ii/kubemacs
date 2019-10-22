;;; packages.el --- ii layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2018 Sylvain Benner & Contributors
;;
;; Author: Zach Mandeville <zz@sharing.io>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `ii-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `ii/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `ii/pre-init-PACKAGE' and/or
;;   `ii/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:
(defun ii/init-feature-mode ()
  (use-package feature-mode))
(defun ii/init-ob-tmate ()
  (use-package ob-tmate))
(defun ii/init-ob-sql-mode ()
  (use-package ob-sql-mode))
(defun ii/init-s ()
  (use-package ob-sql-mode))
(defun ii/init-xclip ()
  (use-package xclip))


(defconst ii-packages
  '(
    ;; async
    ;; closql
    ;; command-log-mode
    ;; dash
    ;; demo-it
    ;; ein ;; https://github.com/millejoh/emacs-ipython-notebook
    ;; emms
    ;; emacsql-sqlite
    ;; evil-vimish-fold
    ;; fancy-narrow
    feature-mode
    ;;(forge :location "/usr/local/share/emacs/site-lisp/forge"
    ;;       :afer magit)
    ;; ghub
    ;;go-playground
    ;;go-dlv
    ;;gorepl-mode ;; go
    ;;graphql
    ;;graphql-mode
    ;; (graphql-mode :location (recipe
    ;;                          :fetcher github
    ;;                          :repo "davazp/graphql-mode"
    ;;                          :commit "301a218"
    ;;                          ))
    ;; groovy-mode
    ;; jupyter
    ;; ob-async
    (ob-tmate :ensure t
              :location (recipe
                         :fetcher github
                         :repo "ii/ob-tmate"))
    (ob-sql-mode :ensure t)
    ;; oer-reveal
    ;; (org-protocol-capture-html :location (recipe
    ;;                                       :fetcher github
    ;;                                       :repo "alphapapa/org-protocol-capture-html"
    ;;                                       :commit "23a1336c"))
    ;; org-re-reveal-ref
    ;; (emacs-reveal :location (recipe
    ;;                          :fetcher gitlab
    ;;                          :repo "oer/emacs-reveal"
    ;;                          :commit "d0aa1f9d"))
    ;;ob-go
    ;; org-protocol ;; https://orgmode.org/worg/org-contrib/org-protocol.html
    ;; http://tech.memoryimprintstudio.com/org-capture-from-external-applications/
    ;; https://github.com/sprig/org-capture-extension
    ;;ob-tmux
    ;; org-babel-eval-in-repl
    ;; org-tree-slide
    ;; org-mu4e
    ;; org-pdfview
    ;; ox-reveal
    ;; pdf-tools ;; https://github.com/politza/pdf-tools
    ;; pdf-view
    s
    ;; scad-mode
    ;; slime
    ;; transcribe
    ;; togetherly
    ;; vimish-fold
    xclip
    ;; (yasnippet :location (recipe
    ;;                       :fetcher github
    ;;                       :repo "joaotavora/yasnippet"
    ;;                       :branch "0.13.0"))
    ;; :commit "89eb7ab"))
    ;;                      :branch "0.12.2"))
    ;; for tmate and over ssh cut-and-paste
    ;; https://gist.github.com/49eabc1978fe3d6dedb3ca5674a16ece.git
    ;; sakura is waiting on vte
    ;; https://bugs.launchpad.net/sakura/+bug/1769575
    ;; I'm pretty sure the lib vte issue is stale
    ;; https://bugzilla.gnome.org/show_bug.cgi?id=795774
    ;; available in minitty since 2.6.1
    ;; https://github.com/mintty/mintty/issues/258
    ;; http://mintty.github.io/ (Default tty on Cygwin etc)
    ;; I created a ticket to add support to vte
    ;; https://gitlab.gnome.org/GNOME/vte/issues/125
    ;; this would in turn enable support on many
    ;; default linux/gnome terminals
    ;; for now, you probably want to use xterm
    ;;(osc52e :location (recipe
    ;;                   :fetcher git
    ;;                   :url "https://gist.github.com/49eabc1978fe3d6dedb3ca5674a16ece.git"
    ;;                   :ensure t
    ;;                   ))
    ;; for jupyter
    ;; websocket
    ;; simple-httpd
    ;; emacs-websocket
    ;; company-mode
    ;; markdown-mode
    ;; (zmq :ensure t)
    )
  "The list of Lisp packages required by the ii layer.

Each entry is either:

1. A symbol, which is interpreted as a package to be installed, or

2. A list of the form (PACKAGE KEYS...), where PACKAGE is the
    name of the package to be installed or loaded, and KEYS are
    any number of keyword-value-pairs.

    The following keys are accepted:

    - :excluded (t or nil): Prevent the package from being loaded
      if value is non-nil

    - :location: Specify a custom installation location.
      The following values are legal:

      - The symbol `elpa' (default) means PACKAGE will be
        installed using the Emacs package manager.

      - The symbol `local' directs Spacemacs to load the file at
        `./local/PACKAGE/PACKAGE.el'

      - A list beginning with the symbol `recipe' is a melpa
        recipe.  See: https://github.com/milkypostman/melpa#recipe-format")


;;; packages.el ends here
