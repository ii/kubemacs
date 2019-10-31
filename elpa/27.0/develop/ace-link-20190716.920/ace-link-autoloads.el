;;; ace-link-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "ace-link" "ace-link.el" (0 0 0 0))
;;; Generated autoloads from ace-link.el

(autoload 'ace-link "ace-link" "\
Call the ace link function for the current `major-mode'" t nil)

(autoload 'ace-link-info "ace-link" "\
Open a visible link in an `Info-mode' buffer." t nil)

(autoload 'ace-link-help "ace-link" "\
Open a visible link in a `help-mode' buffer." t nil)

(autoload 'ace-link-woman "ace-link" "\
Open a visible link in a `woman-mode' buffer." t nil)

(autoload 'ace-link-eww "ace-link" "\
Open a visible link in an `eww-mode' buffer." t nil)

(autoload 'ace-link-w3m "ace-link" "\
Open a visible link in an `w3m-mode' buffer." t nil)

(autoload 'ace-link-compilation "ace-link" "\
Open a visible link in a `compilation-mode' buffer." t nil)

(autoload 'ace-link-gnus "ace-link" "\
Open a visible link in a `gnus-article-mode' buffer." t nil)

(autoload 'ace-link-mu4e "ace-link" "\
Open a visible link in an `mu4e-view-mode' buffer." t nil)

(autoload 'ace-link-org "ace-link" "\
Open a visible link in an `org-mode' buffer." t nil)

(autoload 'ace-link-org-agenda "ace-link" "\
Open a visible link in an `org-mode-agenda' buffer." t nil)

(autoload 'ace-link-xref "ace-link" "\
Open a visible link in an `xref--xref-buffer-mode' buffer." t nil)

(autoload 'ace-link-custom "ace-link" "\
Open a visible link in an `Custom-mode' buffer." t nil)

(autoload 'ace-link-addr "ace-link" "\
Open a visible link in a goto-address buffer." t nil)

(autoload 'ace-link-sldb "ace-link" "\
Interact with a frame or local variable in a sldb buffer." t nil)

(autoload 'ace-link-slime-xref "ace-link" "\
Open a visible link in an `slime-xref-mode' buffer." t nil)

(autoload 'ace-link-slime-inspector "ace-link" "\
Interact with a value, an action or a range button in a
`slime-inspector-mode' buffer." t nil)

(autoload 'ace-link-indium-inspector "ace-link" "\
Interact with a value, an action or a range button in a
`indium-inspector-mode' buffer." t nil)

(autoload 'ace-link-indium-debugger-frames "ace-link" "\
Interact with a value, an action or a range button in a
`indium-debugger-frames-mode' buffer." t nil)

(autoload 'ace-link-setup-default "ace-link" "\
Bind KEY to appropriate functions in appropriate keymaps.

\(fn &optional KEY)" nil nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "ace-link" '("ace-link-")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; ace-link-autoloads.el ends here
