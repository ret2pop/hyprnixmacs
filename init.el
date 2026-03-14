;; [[file:../config/emacs.org::*Initialization][Initialization:1]]
;; -*- lexical-binding: t; -*-
;; Initialization:1 ends here

;; [[file:../config/emacs.org::*State][State:1]]
;; pure, well okay it prints but whatever
(defmacro try (expr)
  `(condition-case err
       ,expr
     (error
      (princ (format "BLOCK FAILED: %s\n" (error-message-string err))))))

;; pure
(defmacro declare-irc-server (name server port)
  `(defun ,name ()
     (interactive)
     (erc-tls :server ,server
              :port ,port)))

;; pure, well imperative when evaluated but they're all just bindings that don't depend on each other
(defmacro create-irc-servers (&rest server-list)
  `(progn
     ,@(mapcar (lambda (n) `(declare-irc-server ,@n)) server-list)))

;; pure
(defun org-html-latex-environment-pandoc-fix (orig-fun latex-environment contents info)
  "Force `ox-html' to use the convert command for LaTeX environments when set to 'html."
  (let ((processing-type (plist-get info :with-latex)))
    (if (eq processing-type 'html)
        (let* ((latex-frag (org-remove-indentation (org-element-property :value latex-environment)))
               (converted (org-format-latex-as-html latex-frag)))
          (format "<div class=\"equation-container\">\n<span class=\"equation\">\n%s\n</span>\n</div>" converted))
      (funcall orig-fun latex-environment contents info))))

;; imperative
(defun insert-urandom-password (&optional length)
  (interactive "P")
  (let ((length (or length 32))
        (chars "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()-_=+[]{};:,.<>?"))
    (insert
     (with-temp-buffer
       (call-process "head" nil t nil "-c" (number-to-string length) "/dev/urandom")
       (let ((bytes (buffer-string)))
         (mapconcat (lambda (c)
                      (string (elt chars (mod (string-to-char (char-to-string c)) (length chars)))))
                    bytes ""))))))

;; imperative
(defun create-htmlize-css ()
  (org-html-htmlize-generate-css)
  (with-current-buffer "*html*"
    (buffer-string)))

;; imperative
(defun minify-css (css)
  "A functional wrapper around the external 'minify' binary."
  (with-temp-buffer
    (insert css)
    (call-process-region (point-min) (point-max) "minify" t t nil "--type=css")
    (buffer-string)))

;; imperative
(defun emacs-config ()
  (unless noninteractive (server-start))

  ;; start with sane defaults
  (pixel-scroll-precision-mode 1)
  (display-battery-mode 1)
  (display-time-mode 1)
  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  (tool-bar-mode -1)

  ;; load theme, fonts, and transparency. Prettify symbols.
  (set-face-attribute 'default nil :font "Iosevka Nerd Font" :height 130)
  (set-face-attribute 'variable-pitch nil :font "Lora" :height 1.1)

  (when (display-graphic-p)
    (set-fontset-font t 'han (font-spec :family "Noto Sans CJK SC"))
    (set-fontset-font t 'kana (font-spec :family "Noto Sans CJK JP"))
    (set-fontset-font t 'symbol (font-spec :family "Noto Color Emoji"))
    (set-fontset-font t 'symbol (font-spec :family "Symbols Nerd Font Mono") nil 'append))
  (set-frame-parameter nil 'alpha-background 70))

;; imperative
(defun evil-config ()
  (evil-mode 1)
  (evil-set-undo-system 'undo-redo)
  (evil-set-initial-state 'pdf-view-mode 'normal))

;; imperative
(defun doom-themes-config ()
  (load-theme 'doom-rouge t)
  (doom-themes-visual-bell-config)
  (doom-themes-treemacs-config)
  (doom-themes-org-config))

;; imperative
(defun org-roam-config ()
  (org-roam-db-autosync-mode)
  (org-roam-update-org-id-locations))

;; same as above
(defun org-electric-pair ()
  (setq-local electric-pair-inhibit-predicate
              (lambda (c) (if (eq c ?<) t (electric-pair-default-inhibit c)))))

;; same as above
(defun org-yasnippet-latex () (yas-activate-extra-mode 'latex-mode))

;; same as above
(defun remove-annoying-pairing () (remove-hook 'post-self-insert-hook #'yaml-electric-bar-and-angle t))
;; State:1 ends here

;; [[file:../config/emacs.org::*Random Packages][Random Packages:1]]
(use-package tex-site)
(use-package subr-x)
(use-package dash)
(use-package s)
(use-package f)
;; Random Packages:1 ends here

;; [[file:../config/emacs.org::*Emacs][Emacs:1]]
(use-package emacs
  :custom
  ;; global defaults
  (indent-tabs-mode nil "no real tabs, only spaces")
  (tab-width 2 "tab show as 2 spaces")
  (standard-indent 2 "base indentation")
  (custom-safe-themes t "I already manage my themes with nix")
  (custom-file null-device "Don't save custom configs")

  ;; Startup errors
  (warning-minimum-level :emergency "Supress emacs warnings")
  (confirm-kill-processes nil "Don't ask to quit")
  (debug-ignored-errors (cons 'remote-file-error debug-ignored-errors) "Remove annoying error from debug errors")
  (browse-url-generic-program "librewolf" "set browser to librewolf")
  (browse-url-secondary-browser-function 'browse-url-generic "set browser")
  (browse-url-browser-function 'browse-url-generic "set browser")
  (default-frame-alist '((alpha-background . 70)
                         (vertical-scroll-bars)
                         (internal-border-width . 24)
                         (left-fringe . 8)
                         (right-fringe . 8)))

  ;; Mouse wheel
  (mouse-wheel-scroll-amount '(1 ((shift) . 1)) "Nicer scrolling")
  (mouse-wheel-progressive-speed nil "Make scrolling non laggy")
  (mouse-wheel-follow-mouse 't "Scroll correct window")
  (scroll-conservatively 101 "Sort of smooth scrolling")
  (scroll-step 1 "Scroll one line at a time")
  (debug-on-error nil "Don't make the annoying popups")
  (display-time-24hr-format t "Use 24 hour format to read the time")
  (display-line-numbers-type 'relative "Relative line numbers for easy vim jumping")
  (use-short-answers t "Use y instead of yes")
  (make-backup-files nil "Don't make backups")
  (display-fill-column-indicator-column 150 "Draw a line at 100 characters")
  (fill-column 150)
  (line-spacing 2 "Default line spacing")
  (c-doc-comment-style '((c-mode . doxygen)
                         (c++-mode . doxygen)))


  :hook ((text-mode . visual-line-mode)
         (prog-mode . display-line-numbers-mode)
         (prog-mode . display-fill-column-indicator-mode)
         (org-mode . auto-fill-mode)
         (org-mode . display-fill-column-indicator-mode)
         (org-mode . display-line-numbers-mode))
  :config (emacs-config))
;; Emacs:1 ends here

;; [[file:../config/emacs.org::*Org Mode][Org Mode:1]]
(use-package org
  :after (f s dash nix-mode)
  :hook
  ((org-mode-hook . remove-annoying-pairing))
  :custom
  ;; Fix terrible indentation issues
  (org-edit-src-content-indentation 0)
  (org-src-tab-acts-natively t)
  (org-src-preserve-indentation t)

  (TeX-PDF-mode t)
  (org-confirm-babel-evaluate nil "Don't ask to evaluate code block")
  (org-export-with-broken-links t "publish website even with broken links")
  (org-src-fontify-natively t "Colors!")

  ;; org-latex
  (org-preview-latex-image-directory (expand-file-name "~/.cache/ltximg/") "don't use weird cache location")
  (org-latex-preview-ltxpng-directory (expand-file-name "~/.cache/ltximg/") "don't use weird cache location")
  (org-latex-to-html-convert-command "printf '%%s' %i | pandoc -f latex -t html --mathml | tr -d '\\n' | sed -e 's/^<p>//' -e 's/<\\/p>$//'" "latex to MathML with special character handling")
  (org-latex-to-mathml-convert-command "printf '%%s' %i | pandoc -f latex -t html --mathml | tr -d '\\n' | sed -e 's/^<p>//' -e 's/<\\/p>$//'" "latex to MathML with special character handling")

  (TeX-engine 'xetex "set xelatex as default engine")
  (preview-default-option-list '("displaymath" "textmath" "graphics") "preview latex")
  (preview-image-type 'png "Use PNGs")
  (org-format-latex-options
   '(:foreground default
                 :background default
                 :scale 2
                 :html-foreground "Black"
                 :html-background "Transparent"
                 :html-scale 1.5
                 :matchers ("begin" "$1" "$" "$$" "\\(" "\\[")) "space latex better")
  (org-return-follows-link t "be able to follow links without mouse")
  (org-startup-indented t "Indent the headings")
  (org-image-actual-width '(300) "Cap width") 
  (org-startup-with-latex-preview t "see latex previews on opening file")
  (org-startup-with-inline-images t "See images on opening file")
  (org-hide-emphasis-markers t "prettify org mode")
  (org-use-sub-superscripts "{}" "Only display superscripts and subscripts when enclosed in {}")
  (org-pretty-entities t "prettify org mode")
  (org-agenda-files (list "~/monorepo/agenda.org" "~/org/notes.org" "~/org/agenda.org") "set default org files")
  (org-default-notes-file (concat org-directory "/notes.org") "Notes file")

  ;; ricing
  (org-auto-align-tags nil)
  (org-tags-column 0)
  (org-catch-invisible-edits 'show-and-error)
  (org-special-ctrl-a/e t)
  (org-insert-heading-respect-content t)
  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-agenda-tags-column 0)
  (org-ellipsis "…")
  :config
  (org-babel-do-load-languages 'org-babel-load-languages
                               '((shell . t)
                                 (python . t)
                                 (nix . t)
                                 (latex . t))))

(use-package org-tempo
  :after org)

(use-package org-habit
  :after org
  :custom
  (org-habit-preceding-days 7 "See org habit entries")
  (org-habit-following-days 35 "See org habit entries")
  (org-habit-show-habits t "See org habit entries")
  (org-habit-show-habits-only-for-today nil "See org habit entries")
  (org-habit-show-all-today t "Show org habit graph"))

(use-package htmlize
  :after (doom-themes catppuccin-theme))

(use-package ox-latex
  :after (org)
  :custom
  (org-latex-compiler "xelatex" "Use latex as default")
  (org-latex-pdf-process '("xelatex -interaction=nonstopmode -output-directory=%o %f") "set xelatex as default"))

(use-package ox-html
  :after (org htmlize)
  :custom
  (org-html-htmlize-output-type 'css "allow styling from CSS file")
  (org-html-with-latex 'html "let my html handler handle latex")
  (org-html-mathjax-options nil "disable mathjax, use MathML")
  (org-html-mathjax-template "" "disable mathjax, use MathML")
  (org-html-head-include-default-style nil "use my own css for everything")
  (org-html-head-include-scripts nil "use my own js for everything")
  (org-html-postamble (concat "Copyright © 2024 " system-fullname) "set copyright notice on bottom of site")
  (org-html-divs '((preamble "header" "preamble")
                   (content "main" "content")
                   (postamble "footer" "postamble")) "semantic html exports")
  (org-html-viewport '((width "device-width")
                       (initial-scale "1.0")
                       (minimum-scale "1.0")) "Prevent zooming out past default size")
  :config (advice-add 'org-html-latex-environment :around #'org-html-latex-environment-pandoc-fix))

(use-package ox-publish
  :after (org f s dash ox-html)
  :custom
  (org-publish-project-alist
   `(("website-org"
      :base-directory "~/monorepo"
      :base-extension "org"
      :exclude "nix/README\\.org"
      :publishing-directory "~/website_html"
      :with-author t
      :with-date t
      :recursive t
      :publishing-function org-html-publish-to-html
      :headline-levels 4
      :html-head ,(concat "<meta name=\"theme-color\" content=\"#ffffff\">\n<link rel=\"preload\" href=\"/fonts/Inconsolata-Medium.woff2\" as=\"font\" type=\"font/woff2\" crossorigin>\n<meta name=\"theme-color\" content=\"#ffffff\">\n<link rel=\"preload\" href=\"/fonts/Lora-Medium.woff2\" as=\"font\" type=\"font/woff2\" crossorigin>\n<link rel=\"preload\" href=\"/fonts/CormorantGaramond-Bold.woff2\" as=\"font\" type=\"font/woff2\" crossorigin>\n<link rel=\"preload\" href=\"/fonts/CormorantGaramond-Medium.woff2\" as=\"font\" type=\"font/woff2\" crossorigin>\n<link rel=\"manifest\" href=\"/site.webmanifest\">\n<link rel=\"icon\" type=\"image/png\" sizes=\"16x16\" href=\"/favicon-16x16.png\">\n<link rel=\"mask-icon\" href=\"/safari-pinned-tab.svg\" color=\"#5bbad5\">\n<link rel=\"icon\" type=\"image/png\" sizes=\"32x32\" href=\"/favicon-32x32.png\">\n<link rel=\"apple-touch-icon\" sizes=\"180x180\" href=\"/apple-touch-icon.png\"><meta name=\"msapplication-TileColor\" content=\"#da532c\">\n"
                          "<style>"
                          (->> (create-htmlize-css)
                               (s-replace-regexp "<style[^>]*>" "")
                               (s-replace "</style>" "")
                               (s-replace "<![CDATA[/*><![CDATA[/*>\n" "")
                               (s-replace "/*]]>*/-->" "")
                               (s-trim)
                               (minify-css))
                          (f-read-text "~/monorepo/style.css" 'utf-8)
                          "</style>")
      :html-preamble t
      :html-preamble-format (("en" "<p class=\"preamble\"><a href=\"/index.html\">home</a> | <a href=\"./index.html\">section main page</a></p><hr>")))
     ("website-static"
      :base-directory "~/monorepo"
      :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf\\|ico\\|asc\\|pub\\|webmanifest\\|xml\\|svg\\|txt\\|webp\\|conf"
      :publishing-directory "~/website_html/"
      :recursive t
      :publishing-function org-publish-attachment)
     ("website" :auto-sitemap t :components ("website-org" "website-static"))) "functions to publish website"))
;; Org Mode:1 ends here

;; [[file:../config/emacs.org::*All The Icons][All The Icons:1]]
(use-package all-the-icons
  :if (display-graphic-p))
;; All The Icons:1 ends here

;; [[file:../config/emacs.org::*Variable Pitch Font][Variable Pitch Font:1]]
(use-package mixed-pitch
  :hook ((text-mode . mixed-pitch-mode)
         (org-mode . mixed-pitch-mode))
  :custom (mixed-pitch-set-height t)
  :config
  (dolist (face '(org-latex-and-related
                  org-priority
                  org-block
                  org-table
                  org-formula))
    (add-to-list 'mixed-pitch-fixed-pitch-faces face)))
;; Variable Pitch Font:1 ends here

;; [[file:../config/emacs.org::*Writeroom][Writeroom:1]]
(use-package writeroom-mode
  :custom (writeroom-width 150))
;; Writeroom:1 ends here

;; [[file:../config/emacs.org::*Indent Bars][Indent Bars:1]]
(use-package indent-bars
  :after (nix-mode)
  :hook ((python-mode yaml-mode nix-mode) . indent-bars-mode))
;; Indent Bars:1 ends here

;; [[file:../config/emacs.org::*Autopair][Autopair:1]]
(use-package electric-pair
  :hook ((prog-mode . electric-pair-mode)
         (org-mode . org-electric-pair)))
;; Autopair:1 ends here

;; [[file:../config/emacs.org::*Search and Replace][Search and Replace:1]]
(use-package wgrep
  :after grep)
;; Search and Replace:1 ends here

;; [[file:../config/emacs.org::*Fragtog][Fragtog:1]]
(use-package org-fragtog :hook (org-mode . org-fragtog-mode))
;; Fragtog:1 ends here

;; [[file:../config/emacs.org::*Snippets][Snippets:1]]
(use-package yasnippet
  :demand t
  :hook (org-mode . org-yasnippet-latex)
  :custom (yas-snippet-dirs '("~/monorepo/yasnippet/" "~/.emacs.d/snippets"))
  :config (yas-global-mode 1))

(use-package yasnippet-snippets
  :after yasnippet)
;; Snippets:1 ends here

;; [[file:../config/emacs.org::*Completion][Completion:1]]
(use-package company
  :custom (company-backends '(company-ispell company-capf company-yasnippet company-files) "Set company backends")
  :hook ((after-init . global-company-mode)))
(use-package company-box
  :hook (company-mode . company-box-mode))
;; Completion:1 ends here

;; [[file:../config/emacs.org::*Spelling][Spelling:1]]
(unless noninteractive (use-package ispell
                         :custom
                         (ispell-program-name "aspell" "use aspell")
                         (ispell-local-dictionary-alist
                          '(("en" "[[:alpha:]]" "[^[:alpha:]]" "[']" t ("-d" "en") nil utf-8)))
                         (ispell-dictionary "en" "Use english dictionary")
                         (ispell-extra-args my-ispell-args "Force aspell to use normal mode instead of nroff")
                         (ispell-silently-savep t "Save changes to dict without confirmation")
                         (ispell-alternate-dictionary my-ispell-dictionary "dict location")))

(unless noninteractive (use-package flyspell
                         :hook (text-mode . flyspell-mode)))
;; Spelling:1 ends here

;; [[file:../config/emacs.org::*Packages][Packages:1]]
(use-package evil
  :demand t
  :custom (evil-want-keybinding nil "Don't load a whole bunch of default keybindings")
  :bind
  (:map evil-normal-state-map
        ("/" . swiper)
        ("?" . (lambda () (interactive) (swiper "--reverse"))))
  :config (evil-config))

(use-package evil-collection
  :demand t
  :after (evil)
  :bind (:map evil-motion-state-map
              ("SPC" . nil)
              ("RET" . nil)
              ("TAB" . nil))
  :config (evil-collection-init))

(use-package evil-commentary
  :after (evil)
  :config (evil-commentary-mode))

(use-package evil-org
  :after (evil org)
  :hook (org-mode . evil-org-mode))

(use-package evil-org-agenda
  :after (evil-org)
  :config (evil-org-agenda-set-keys))

(use-package which-key
  :config (which-key-mode))

(use-package page-break-lines
  :config (page-break-lines-mode))
;; Packages:1 ends here

;; [[file:../config/emacs.org::*Journal][Journal:1]]
(use-package org-journal
  :after (org)
  :custom
  (org-journal-dir "~/monorepo/journal/" "Set journal directory")
  (org-journal-date-format "%A, %d %B %Y" "Date format")
  (org-journal-file-format "%Y%m%d.org" "Automatic file creation format based on date")
  (org-journal-enable-agenda-integration t "All org-journal entries are org-agenda entries")
  (org-journal-file-header "#+TITLE: Daily Journal\n#+STARTUP: showeverything\n#+DESCRIPTION: My daily journal entry\n#+AUTHOR: Preston Pan\n#+date:\n#+options: broken-links:t" "set header files on new org journal entry"))
;; Journal:1 ends here

;; [[file:../config/emacs.org::*Doom Modeline][Doom Modeline:1]]
(use-package doom-modeline
  :config (doom-modeline-mode 1))
;; Doom Modeline:1 ends here

;; [[file:../config/emacs.org::*Doom Theme][Doom Theme:1]]
(use-package doom-themes
  :custom
  (doom-themes-enable-bold t "use bold letters")
  (doom-themes-enable-italic t "use italic letters")
  (doom-themes-treemacs-theme "doom-colors" "set theme to something like catppuccin but doom")
  :config
  (unless noninteractive (doom-themes-config)))

(use-package catppuccin-theme
  :config (when noninteractive (try (load-theme 'catppuccin-theme t))))

(use-package solaire-mode
  :after doom-themes
  :config (solaire-global-mode +1))
;; Doom Theme:1 ends here

;; [[file:../config/emacs.org::*Grammar][Grammar:1]]
(use-package writegood-mode
  :hook (text-mode . writegood-mode))
;; Grammar:1 ends here

;; [[file:../config/emacs.org::*Make Org Look Better][Make Org Look Better:1]]
(use-package org-modern
  :after (org)
  :hook (org-mode . org-modern-mode)
  :custom
  (org-modern-block-fringe t)
  (org-modern-block-name t)
  (org-modern-star '("◉" "○" "◈" "◇"))
  (org-modern-block-name '((t . t)))
  (org-modern-keyword '((t . t)))
  :config
  (global-org-modern-mode))
;; Make Org Look Better:1 ends here

;; [[file:../config/emacs.org::*LSP][LSP:1]]
(use-package lsp
  :custom
  (lsp-use-plists t)
  (lsp-typescript-format-enable t)
  (lsp-typescript-indent-size 4)
  (lsp-typescript-tab-size 4)
  (lsp-typescript-indent-style "spaces")
  :hook ((prog-mode . lsp)))

(use-package editorconfig
  :config (editorconfig-mode 1))

(use-package flycheck
  :config (global-flycheck-mode))

(use-package platformio-mode
  :hook (prog-mode . platformio-conditionally-enable))
;; LSP:1 ends here

;; [[file:../config/emacs.org::*C/C++][C/C++:1]]
(use-package irony
  :hook ((c++-mode . irony-mode)
         (c-mode . irony-mode)
         (objc-mode . irony-mode)
         (irony-mode . irony-cdb-autosetup-compile-options)))

(use-package irony-eldoc
  :hook ((irony-mode . irony-eldoc)))
;; C/C++:1 ends here

;; [[file:../config/emacs.org::*Solidity][Solidity:1]]
(use-package solidity-mode)
(use-package company-solidity
  :after company)
(use-package solidity-flycheck
  :after flycheck
  :custom (solidity-flycheck-solc-checker-active t))
;; Solidity:1 ends here

;; [[file:../config/emacs.org::*Projectile][Projectile:1]]
(use-package projectile
  :custom
  (projectile-project-search-path '("~/org" "~/src" "~/monorepo" "~/projects") "search path for projects")
  :config (projectile-mode +1))
;; Projectile:1 ends here

;; [[file:../config/emacs.org::*Dashboard][Dashboard:1]]
(use-package dashboard
  :after (projectile)
  :custom
  (dashboard-banner-logo-title "Welcome, Commander!" "Set title for dashboard")
  (dashboard-icon-type 'nerd-icons "Use nerd icons")
  (dashboard-vertically-center-content t "Center content")
  (dashboard-set-init-info t)
  (dashboard-week-agenda t "Agenda in dashboard")
  (dashboard-items '((recents   . 5)
                     (bookmarks . 5)
                     (projects  . 5)
                     (agenda    . 5)
                     (registers . 5)) "Look at some items")
  :config (unless noninteractive (dashboard-setup-startup-hook)))
;; Dashboard:1 ends here

;; [[file:../config/emacs.org::*Ivy][Ivy:1]]
(use-package ivy
  :demand t
  :custom
  (ivy-use-virtual-buffers t "Make searching more efficient")
  (enable-recursive-minibuffers t "Don't get soft locked when in a minibuffer")
  :bind
  ("C-j" . ivy-immediate-done)
  ("C-c C-r" . ivy-resume)
  :init (ivy-mode)
  :config (ivy-rich-mode))

(use-package counsel
  :after ivy
  :bind
  ("M-x" . counsel-M-x)
  ("C-x C-f" . counsel-find-file)
  ("<f1> f" . counsel-describe-function)
  ("<f1> v" . counsel-describe-variable)
  ("<f1> o" . counsel-describe-symbol)
  ("<f1> l" . counsel-find-library)
  ("<f2> i" . counsel-info-lookup-symbol)
  ("<f2> u" . counsel-unicode-char)
  ("C-c g" . counsel-git)
  ("C-c j" . counsel-git-grep)
  ("C-c k" . counsel-ag)
  ("C-x l" . counsel-locate))

(use-package swiper
  :after ivy
  :bind ("C-s" . swiper))

(use-package ivy-posframe
  :custom
  (ivy-posframe-display-functions-alist '((t . ivy-posframe-display)))
  :config (ivy-posframe-mode 1))

(use-package all-the-icons-ivy-rich
  :after (ivy all-the-icons)
  :config (all-the-icons-ivy-rich-mode 1))
;; Ivy:1 ends here

;; [[file:../config/emacs.org::*Magit][Magit:1]]
(use-package magit)
(use-package git-gutter
  :config
  (global-git-gutter-mode +1))
;; Magit:1 ends here

;; [[file:../config/emacs.org::*IRC][IRC:1]]
(use-package erc
  :hook ((erc-mode . erc-notifications-mode))
  :custom
  (erc-nick system-username "sets erc username to the one set in nix config")
  (erc-user-full-name system-fullname "sets erc fullname to the one set in nix config"))
;; IRC:1 ends here

;; [[file:../config/emacs.org::*Keybindings][Keybindings:1]]
(use-package general
  :after (evil evil-collection)
  :init (general-create-definer leader-key :prefix "SPC")
  :config
  ;; these are just bindings but the symbols are all lazily handled by general
  (create-irc-servers
   (znc "ret2pop.net" "5000")
   (prestonpan "nullring.xyz" "6697")
   (libera-chat "irc.libera.chat" "6697")
   (efnet "irc.prison.net" "6697")
   (matrix-org "matrix.org" "8448")
   (gimp-org "irc.gimp.org" "6697"))

  (leader-key 'normal
    "o c" '(org-capture :wk "Capture")
    ;; Org Mode
    "n" '(:ignore t :wk "Org mode plugins")
    "n j j" '(org-journal-new-entry :wk "Make new journal entry")
    "n r f" '(org-roam-node-find :wk "Find roam node")
    "n r i" '(org-roam-node-insert :wk "Insert roam node")
    "n r a" '(org-roam-alias-add :wk "Add alias to org roam node")
    "n r g" '(org-roam-graph :wk "Graph roam database")
    "m I" '(org-id-get-create :wk "Make org id")

    ;; Programming Projects
    "." '(counsel-find-file :wk "find file")
    "p a" '(projectile-add-known-project :wk "Add to project list")
    
    "N f" '(nix-flake :wk "nix flake menu")
    "f" '(:ignore t :wk "file operations")
    "f p" '(projectile-switch-project :wk "find project to switch to")
    "f f" '(counsel-fzf :wk "find file in project")
    "f s" '(counsel-rg :wk "find string in project")

    "y n s" '(yas-new-snippet :wk "Create new snippet")

    "g" '(:ignore t :wk "Magit")
    "g /" '(magit-dispatch :wk "git commands")
    "g P" '(magit-push :wk "git push")
    "g c" '(magit-commit :wk "git commit")
    "g p" '(magit-pull :wk "Pull from git")
    "g s" '(magit-status :wk "Change status of files")
    "g i" '(magit-init :wk "init new git project")
    "g r" '(magit-rebase :wk "Rebase branch")
    "g m" '(magit-merge :wk "Merge branches")
    "g b" '(magit-branch :wk "Git branch")

    "o p" '(treemacs :wk "Project Drawer")
    "o P" '(treemacs-projectile :wk "Import Projectile project to treemacs")

    "w r" '(writeroom-mode :wk "focus mode for writing")

    ;; Applications
    "o" '(:ignore t :wk "Open application")
    "o t" '(vterm :wk "Terminal")
    "o e" '(eshell :wk "Elisp Interpreter")
    "o m" '(mu4e :wk "Email")
    "o M" '(matrix-org :wk "Connect to matrix")
    "o r s" '(elfeed :wk "rss feed")
    "o a" '(org-agenda :wk "Open agenda")
    "o w" '(eww :wk "web browser")
    "m m" '(emms :wk "Music player")
    "s m" '(proced :wk "System Manager")
    "l p" '(list-processes :wk "List Emacs Processes")

    "m P p" '(org-publish :wk "Publish website components")
    "s e" '(sudo-edit :wk "Edit file with sudo")

    ;; "f f" '(eglot-format :wk "Format code buffer")
    "i p c" '(prestonpan :wk "Connect to my IRC server")
    "i l c" '(liberachat :wk "Connect to libera chat server")
    "i e c" '(efnet :wk "Connect to efnet chat server")
    "i g c" '(gimp-org :wk "Connect to gimp chat server")
    "i z c" '(znc :wk "Connect to my ZNC instance")

    ;; Documentation
    "h" '(:ignore t :wk "Documentation")
    "h v" '(counsel-describe-variable :wk "Describe variable")
    "h f" '(counsel-describe-function :wk "Describe function")
    "h h" '(help :wk "Help")
    "h m" '(woman :wk "Manual")
    "h i" '(info :wk "Info")

    "s i p" '(insert-urandom-password :wk "insert random password to buffer (for sops)")

    "h r r" '(lambda () (interactive) (load-file (expand-file-name "~/monorepo/nix/init.el")))))
;; Keybindings:1 ends here

;; [[file:../config/emacs.org::*Minuet][Minuet:1]]
(use-package minuet
  :bind
  (("M-y" . #'minuet-complete-with-minibuffer)
   ("C-c m" . #'minuet-show-suggestion)
   :map minuet-active-mode-map
   ("C-c r" . #'minuet-dismiss-suggestion)
   ("TAB" . #'minuet-accept-suggestion))
  :hook ((prog-mode-hook . minuet-auto-suggestion-mode))
  :custom
  (minuet-request-timeout 40 "Max timeout in seconds")
  (minuet-provider 'openai-fim-compatible "FIM compatible OpenAI-like API (Ollama)")
  (minuet-n-completions 1 "I am using ghost text so I only need one possible completion")
  (minuet-context-window 1024 "how much context do I want?")
  (minuet-openai-fim-compatible-options
   '(
     :end-point "http://localhost:11434/v1/completions"
     :name "Ollama"
     :api-key "TERM"
     :template (
                :prompt minuet--default-fim-prompt-function
                :suffix minuet--default-fim-suffix-function)
     :transform ()
     :get-text-fn minuet--openai-fim-get-text-fn
     :optional (:max-tokens 50)
     :model "qwen2.5-coder:14b")))
;; Minuet:1 ends here

;; [[file:../config/emacs.org::*RSS Feed][RSS Feed:1]]
(use-package elfeed
  :hook ((elfeed-search-mode . elfeed-update))
  :custom (elfeed-search-filter "@1-month-ago +unread" "Only display unread articles from a month ago")
  :config (run-with-timer 0 (* 60 3) 'elfeed-update))

(use-package elfeed-org
  :after (elfeed org)
  :demand t
  :custom (rmh-elfeed-org-files '("~/monorepo/config/elfeed.org") "Use elfeed config in repo as default")
  :config (elfeed-org))
;; RSS Feed:1 ends here

;; [[file:../config/emacs.org::*Youtube][Youtube:1]]
(use-package elfeed-tube
  :after elfeed
  :demand t
  :bind (:map elfeed-show-mode-map
              ("F" . elfeed-tube-fetch)
              ([remap save-buffer] . elfeed-tube-save)
              :map elfeed-search-mode-map
              ("F" . elfeed-tube-fetch)
              ([remap save-buffer] . elfeed-tube-save))
  :config (elfeed-tube-setup))

(use-package elfeed-tube-mpv
  :bind (:map elfeed-show-mode-map
              ("C-c C-f" . elfeed-tube-mpv-follow-mode)
              ("C-c C-c" . elfeed-tube-mpv)
              ("C-c C-w" . elfeed-tube-mpv-where)
              :map elfeed-search-mode-map
              ("M" . elfeed-tube-mpv)))
;; Youtube:1 ends here

;; [[file:../config/emacs.org::*Project Drawer][Project Drawer:1]]
(use-package treemacs
  :after doom-themes)

(use-package treemacs-evil
  :after (treemacs evil))

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package treemacs-magit
  :after (treemacs magit))

(use-package treemacs-all-the-icons
  :after (treemacs all-the-icons))
;; Project Drawer:1 ends here

;; [[file:../config/emacs.org::*Eww][Eww:1]]
(use-package eww
  :bind (:map eww-mode-map
              ("y Y" . eww-copy-page-url))
  :custom
  (search-engines
   '((("google" "g") "https://google.com/search?q=%s")
     (("duckduckgo" "d" "ddg") "https://duckduckgo.com/?q=%s")
     (("rfc" "r") "https://www.rfc-editor.org/rfc/rfc%s.txt")
     (("rfc-kw" "rk") "https://www.rfc-editor.org/search/rfc_search_detail.php?title=%s"))
   "use this set of search engines")
  (search-engine-default "google" "Use google as default")
  (eww-search-prefix "https://google.com/search?q=" "Google prefix"))
;; Eww:1 ends here

;; [[file:../config/emacs.org::*Nix Mode][Nix Mode:1]]
(use-package nix-mode
  :mode "\\.nix\\'")
;; Nix Mode:1 ends here

;; [[file:../config/emacs.org::*Org Roam][Org Roam:1]]
(use-package org-roam
  :after (org)
  :custom
  (org-roam-db-update-on-save t "Update org-roam db")
  (org-roam-graph-viewer "librewolf" "Use librewolf to view org-roam graph")
  (org-roam-directory (file-truename "~/monorepo/mindmap") "Set org-roam directory inside monorepo")
  (org-roam-capture-templates '(("d" "default" plain "%?"
                                 :target (file+head "${title}.org"
                                                    "#+title: ${title}\n#+author: Preston Pan\n#+description:\n#+options: broken-links:t")
                                 :unnarrowed t)) "org-roam files start with this snippet by default")
  :config (org-roam-config))

(unless noninteractive (use-package org-roam-ui
                         :after org-roam
                         :hook (after-init . org-roam-ui-mode)
                         :custom
                         (org-roam-ui-sync-theme t "Use emacs theme for org-roam-ui")
                         (org-roam-ui-follow t "Have cool visual while editing org-roam")
                         (org-roam-ui-update-on-save t "This option is obvious")
                         (org-roam-ui-open-on-start t "Have cool visual open in librewolf when emacs loads")))
;; Org Roam:1 ends here

;; [[file:../config/emacs.org::*Pinentry][Pinentry:1]]
(unless noninteractive (use-package pinentry
                         :custom (epa-pinentry-mode `loopback "Set this option to match gpg-agent.conf")
                         :config (pinentry-start)))
;; Pinentry:1 ends here

;; [[file:../config/emacs.org::*Email][Email:1]]
(use-package smtpmail
  :custom
  (user-mail-address system-email "Use our email")
  (user-full-name system-fullname "Use our full name")
  (sendmail-program "msmtp" "Use msmtp in order to send emails")
  (send-mail-function 'smtpmail-send-it "This is required for this to work")
  (message-sendmail-f-is-evil t "Use evil-mode for sendmail")
  (message-sendmail-extra-arguments '("--read-envelope-from") "idk what this does")
  (message-send-mail-function 'message-send-mail-with-sendmail "Use sendmail"))

(use-package mu4e
  :after smtpmail
  :hook
  ((mu4e-compose-mode . mml-secure-message-sign-pgpmime))
  :custom
  (mu4e-drafts-folder "/Drafts" "Set drafts folder mu db")
  (mu4e-sent-folder   "/Sent" "Set sent folder in mu db")
  (mu4e-trash-folder  "/Trash" "Set trash folder in mu db")
  (mu4e-attachment-dir  "~/Downloads" "Set downloads folder for attachments")
  (mu4e-view-show-addresses 't "Show email addresses in main view")
  (mu4e-confirm-quit nil "Don't ask to quit")
  (message-kill-buffer-on-exit t "Kill buffer when I exit mu4e")
  (mu4e-compose-dont-reply-to-self t "Don't include self in replies")
  (mu4e-change-filenames-when-moving t)
  (mu4e-get-mail-command (concat "mbsync " system-username) "Use mbsync for imap")
  (mu4e-compose-reply-ignore-address (list "no-?reply" system-email) "ignore my own address and noreply")
  (mu4e-html2text-command "w3m -T text/html" "Use w3m to convert html to text")
  (mu4e-update-interval 300 "Update duration")
  (mu4e-headers-auto-update t "Auto-updates feed")
  (mu4e-view-show-images t "Shows images")
  (mu4e-compose-signature-auto-include nil)
  (mml-secure-openpgp-sign-with-sender t)
  (mml-secure-openpgp-signers (list system-gpgkey))
  (mail-user-agent 'mu4e-user-agent)
  (message-mail-user-agent 'mu4e-user-agent)
  (mu4e-use-fancy-chars t "Random option to make mu4e look nicer"))
;; Email:1 ends here

;; [[file:../config/emacs.org::*Music][Music:1]]
(unless noninteractive (use-package emms
                         :custom
                         (emms-source-file-default-directory (expand-file-name "~/music/") "Use directory specified in Nix")
                         (emms-player-mpd-music-directory (expand-file-name "~/music/") "Use directory specified in Nix")
                         (emms-player-mpd-server-name "localhost" "Connect to localhost")
                         (emms-player-mpd-server-port "6600" "Connect to port 6600")
                         (emms-player-list '(emms-player-mpd) "Use mpd")
                         (emms-lyrics-display-on-modeline t "Display lyrics for reading")
                         (emms-info-functions '(emms-info-mpd emms-info-native emms-info-cueinfo) "functions for displaying information about tracks")
                         :hook
                         ((emms-playlist-mode . emms-lyrics-mode)
                          (emms-player-started . emms-lyrics-lrclib-get))
                         :init (emms-all)
                         :config (emms-player-mpd-connect)))
;; Music:1 ends here

;; [[file:../config/emacs.org::*Tabs][Tabs:1]]
(use-package centaur-tabs
  :custom
  (centaur-tabs-set-icons t "use icons for centaur-tabs")
  (centaur-tabs-set-modified-marker t "show when buffer modified")
  (centaur-tabs-icon-type 'all-the-icons "use all-the-icons for icons")
  :bind
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward)
  :demand t
  :config (centaur-tabs-mode t))
;; Tabs:1 ends here

;; [[file:../config/emacs.org::*Lean4][Lean4:1]]
(unless noninteractive (use-package lean4-mode
                         :commands lean4-mode
                         :vc (:url "https://github.com/leanprover-community/lean4-mode.git"
                                   :rev "76895d8939111654a472cfc617cfd43fbf5f1eb6")))
;; Lean4:1 ends here
