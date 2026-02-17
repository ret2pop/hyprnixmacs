(use-package emacs
:custom
;; global defaults
(indent-tabs-mode nil "no real tabs, only spaces")
(tab-width 2 "tab show as 2 spaces")
(standard-indent 2 "base indentation")

;; Startup errors
(warning-minimum-level :emergency "Supress emacs warnings")
(confirm-kill-processes nil "Don't ask to quit")
(debug-ignored-errors (cons 'remote-file-error debug-ignored-errors) "Remove annoying error from debug errors")
(browse-url-generic-program "firefox")
(browse-url-secondary-browser-function 'browse-url-generic)
(browse-url-browser-function 'browse-url-generic)

;; Mouse wheel
(mouse-wheel-scroll-amount '(1 ((shift) . 1)) "Nicer scrolling")
(mouse-wheel-progressive-speed nil "Make scrolling non laggy")
(mouse-wheel-follow-mouse 't "Scroll correct window")
(scroll-conservatively 101 "Sort of smooth scrolling")
(scroll-step 1 "Scroll one line at a time")
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
  	 (org-mode . display-line-numbers-mode)
  	 (org-mode . (lambda ()
  		       (setq prettify-symbols-alist
  			     '(("#+begin_src" . ?)
  			       ("#+BEGIN_SRC" . ?)
  			       ("#+end_src" . ?)
  			       ("#+END_SRC" . ?)
  			       ("#+begin_example" . ?)
  			       ("#+BEGIN_EXAMPLE" . ?)
  			       ("#+end_example" . ?)
  			       ("#+END_EXAMPLE" . ?)
  			       ("#+header:" . ?)
  			       ("#+HEADER:" . ?)
  			       ("#+name:" . ?﮸)
  			       ("#+NAME:" . ?﮸)
  			       ("#+results:" . ?)
  			       ("#+RESULTS:" . ?)
  			       ("#+call:" . ?)
  			       ("#+CALL:" . ?)
  			       (":PROPERTIES:" . ?)
  			       (":properties:" . ?)
  			       ("lambda" . ?λ)
  			       ("->"     . ?→)
  			       ("map"    . ?↦)
  			       ("/="     . ?≠)
  			       ("!="     . ?≠)
  			       ("=="     . ?≡)
  			       ("<="     . ?≤)
  			       (">="     . ?≥)
  			       ("&&"     . ?∧)
  			       ("||"     . ?∨)
  			       ("sqrt"   . ?√)
  			       ("..."    . ?…)))
  		       (prettify-symbols-mode)))
  	 (prog-mode .
  		    (lambda ()
  		      (setq prettify-symbols-alist
  			    '(("lambda" . ?λ)
  			      ("->"     . ?→)
  			      ("map"    . ?↦)
  			      ("/="     . ?≠)
  			      ("!="     . ?≠)
  			      ("=="     . ?≡)
  			      ("<="     . ?≤)
  			      (">="     . ?≥)
  			      ("&&"     . ?∧)
  			      ("||"     . ?∨)
  			      ("sqrt"   . ?√)
  			      ("..."    . ?…)))
  		      (prettify-symbols-mode))))
    :config
    (require 'tex-site)
    (server-start)

    ;; start wiith sane defaults
    (pixel-scroll-precision-mode 1)
    (display-battery-mode 1)
    (display-time-mode 1)
    (menu-bar-mode -1)
    (scroll-bar-mode -1)
    (tool-bar-mode -1)

    ;; load theme, fonts, and transparency. Prettify symbols.
    (global-prettify-symbols-mode 1)
    (set-face-attribute 'default nil :font "Iosevka Nerd Font" :height 130)
    (set-frame-parameter nil 'alpha-background 70)
    (add-to-list 'default-frame-alist '(alpha-background . 70)))

(use-package org
    :hook
    ((org-mode-hook . (lambda () (remove-hook 'post-self-insert-hook #'yaml-electric-bar-and-angle t))))
    :custom
    (org-confirm-babel-evaluate nil "Don't ask to evaluate code block")
    (org-export-with-broken-links t "publish website even with broken links")
    (org-src-fontify-natively t "Colors!")
    (org-latex-preview-image-directory (expand-file-name "~/.cache/ltximg/") "don't use weird cache location")
    (org-preview-latex-image-directory (expand-file-name "~/.cache/ltximg/") "don't use weird cache location")
    (TeX-PDF-mode t)
    (org-latex-compiler "xelatex" "Use latex as default")
    (org-latex-pdf-process '("xelatex -interaction=nonstopmode -output-directory=%o %f") "set xelatex as default")
    (TeX-engine 'xetex "set xelatex as default engine")
    (preview-default-option-list '("displaymath" "textmath" "graphics") "preview latex")
    (preview-image-type 'png "Use PNGs")
;;    (org-format-latex-options (plist-put org-format-latex-options :scale 1.5) "space latex better")
    (org-return-follows-link t "be able to follow links without mouse")
    (org-habit-preceding-days 7 "See org habit entries")
    (org-habit-following-days 35 "See org habit entries")
    (org-habit-show-habits t "See org habit entries")
    (org-habit-show-habits-only-for-today nil "See org habit entries")
    (org-habit-show-all-today t "Show org habit graph")
    (org-startup-indented t "Indent the headings")
    (org-image-actual-width '(300) "Cap width") 
    (org-startup-with-latex-preview t "see latex previews on opening file")
    (org-startup-with-inline-images t "See images on opening file")
    (org-hide-emphasis-markers t "prettify org mode")
    (org-use-sub-superscripts "{}" "Only display superscripts and subscripts when enclosed in {}")
    (org-pretty-entities t "prettify org mode")
    (org-agenda-files (list "~/monorepo/agenda.org" "~/org/notes.org" "~/org/agenda.org") "set default org files")
    (org-default-notes-file (concat org-directory "/notes.org") "Notes file")
    (org-publish-project-alist
     '(("website-org"
        :base-directory "~/monorepo"
        :base-extension "org"
        :publishing-directory "~/website_html"
        :recursive t
        :publishing-function org-html-publish-to-html
        :headline-levels 4
        :html-preamble t
        :html-preamble-format (("en" "<p class=\"preamble\"><a href=\"/index.html\">home</a> | <a href=\"./index.html\">section main page</a></p><hr>")))
       ("website-static"
        :base-directory "~/monorepo"
        :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf\\|ico\\|asc\\|pub\\|webmanifest\\|xml\\|svg"
        :publishing-directory "~/website_html/"
        :recursive t
        :publishing-function org-publish-attachment)
       ("website" :auto-sitemap t :components ("website-org" "website-static"))) "functions to publish website")
    (org-html-postamble (concat "Copyright © 2024 " system-fullname) "set copyright notice on bottom of site")
    :config
    (require 'ox-publish)
    (require 'org-tempo)
    (require 'org-habit)
    (org-babel-do-load-languages 'org-babel-load-languages
                                 '((shell . t)
                                   (python . t)
                                   (latex . t))))

(use-package unicode-fonts
  :init (unicode-fonts-setup))

(use-package electric-pair
  :hook ((prog-mode . electric-pair-mode)
         (org-mode . (lambda () (setq-local electric-pair-inhibit-predicate (lambda (c) (if (eq c ?<) t (electric-pair-default-inhibit c))))))))

(use-package wgrep
  :after grep)

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

(use-package org-fragtog :hook (org-mode . org-fragtog-mode))

(use-package yasnippet
  :config
  (add-to-list 'yas-snippet-dirs "~/monorepo/yasnippet/")
  (yas-global-mode 1)
  :hook (org-mode . (lambda () (yas-minor-mode) (yas-activate-extra-mode 'latex-mode))))

(use-package company
  :config
  '(add-to-list 'company-backends '(company-ispell company-capf company-yasnippet company-files))
  :hook ((after-init . global-company-mode)))

(use-package ispell
  :custom
  (ispell-program-name "aspell" "use aspell")
  (ispell-silently-savep t "Save changes to dict without confirmation")
  (ispell-dictionary "en" "Use english dictionary")
  (ispell-alternate-dictionary "~/.local/share/dict" "dict location"))

(use-package flyspell
  :hook (text-mode . flyspell-mode))

(use-package evil
  :custom
  (evil-want-keybinding nil "Don't load a whole bunch of default keybindings")
  :config
  (evil-mode 1)
  (evil-set-undo-system 'undo-redo)
  (evil-set-initial-state 'pdf-view-mode 'normal)
  ;; bind / and ? safely after evil is loaded
  (define-key evil-normal-state-map (kbd "/") 'swiper)
  (define-key evil-normal-state-map (kbd "?")
    (lambda () (interactive) (swiper "--reverse"))))

(use-package evil-collection
  :after (evil)
  :config
  (with-eval-after-load 'evil-maps
    (define-key evil-motion-state-map (kbd "SPC") nil)
    (define-key evil-motion-state-map (kbd "RET") nil)
    (define-key evil-motion-state-map (kbd "TAB") nil))
  (evil-collection-init))


(use-package evil-commentary
  :after (evil)
  :config
  (evil-commentary-mode))

(use-package evil-org
  :after (evil org)
  :hook (org-mode . (lambda () evil-org-mode))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(use-package which-key
  :config
  (which-key-mode))

(use-package page-break-lines
  :init
  (page-break-lines-mode))

(use-package org-journal
  :after (org)
  :custom
  (org-journal-dir "~/monorepo/journal/" "Set journal directory")
  (org-journal-date-format "%A, %d %B %Y" "Date format")
  (org-journal-file-format "%Y%m%d.org" "Automatic file creation format based on date")
  (org-journal-enable-agenda-integration t "All org-journal entries are org-agenda entries")
  :init
  (defun org-journal-file-header-func (time)
    "Custom function to create journal header."
    (concat
     (pcase org-journal-file-type
       (`daily "#+TITLE: Daily Journal\n#+STARTUP: showeverything\n#+DESCRIPTION: My daily journal entry\n#+AUTHOR: Preston Pan\n#+HTML_HEAD: <link rel=\"stylesheet\" type=\"text/css\" href=\"../style.css\" />\n#+html_head: <script src=\"https://polyfill.io/v3/polyfill.min.js?features=es6\"></script>\n#+html_head: <script id=\"MathJax-script\" async src=\"https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js\"></script>\n#+options: broken-links:t")
       (`weekly "#+TITLE: Weekly Journal\n#+STARTUP: folded")
       (`monthly "#+TITLE: Monthly Journal\n#+STARTUP: folded")
       (`yearly "#+TITLE: Yearly Journal\n#+STARTUP: folded"))))
  (setq org-journal-file-header 'org-journal-file-header-func))

(use-package doom-modeline
  :config
  (doom-modeline-mode 1))

(use-package doom-themes
  :ensure t
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  (doom-themes-treemacs-theme "doom-rouge")
  :config
  (load-theme 'doom-rouge t)

  (doom-themes-visual-bell-config)
  (doom-themes-treemacs-config)
  (doom-themes-org-config))
;; (load-theme 'catppuccin :no-confirm)

(use-package writegood-mode
  :hook (text-mode . writegood-mode))

(use-package org-superstar
  :after (org)
  :hook (org-mode . (lambda () (org-superstar-mode 1))))

;; (use-package eglot
 ;;   :hook
 ;;   (prog-mode . eglot-ensure)
 ;;   (nix-mode . eglot-ensure)
 ;;   :config
 ;;   (add-to-list 'eglot-server-programs '(nix-mode . ("nil"))))

 (use-package lsp
   :hook
   (prog-mode . lsp))

(with-eval-after-load 'lsp-mode
  (setq lsp-typescript-format-enable t
        lsp-typescript-indent-size 4
        lsp-typescript-tab-size 4
        lsp-typescript-indent-style "spaces"))

(use-package editorconfig
  :config
  (editorconfig-mode 1))

 (use-package flycheck
   :config (global-flycheck-mode))

 (use-package platformio-mode
:hook (prog-mode . platformio-conditionally-enable))

(use-package irony-mode
  :hook (
  (c++-mode . irony-mode)
  (c-mode . irony-mode)
  (objc-mode . irony-mode)
  (irony-mode . irony-cdb-autosetup-compile-options)))

(use-package irony-eldoc
  :hook ((irony-mode . irony-eldoc)))

(use-package solidity-mode)
(use-package company-solidity)
(use-package solidity-flycheck
  :custom
  (solidity-flycheck-solc-checker-active t))

(use-package projectile
  :custom
  (projectile-project-search-path '("~/org" "~/src" "~/monorepo" "~/projects") "search path for projects")
  :config
  (projectile-mode +1))

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
  :config
  (dashboard-setup-startup-hook))

(use-package counsel)

(use-package ivy
  :custom
  (ivy-use-virtual-buffers t "Make searching more efficient")
  (enable-recursive-minibuffers t "Don't get soft locked when in a minibuffer")
  :bind
  ("C-s" . swiper)
  ("C-c C-r" . ivy-resume)
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
  ("C-x l" . counsel-locate)
  :config
  (ivy-mode))
(define-key ivy-minibuffer-map (kbd "C-j") 'ivy-immediate-done)

(use-package magit)

(use-package erc
  :hook
  ((erc-mode . erc-notifications-mode))
  :custom
  (erc-nick system-username "sets erc username to the one set in nix config")
  (erc-user-full-name system-fullname "sets erc fullname to the one set in nix config"))

(use-package general
  :init
  (defun znc ()
    (interactive)
    (erc-tls :server "ret2pop.net"
             :port "5000"))

  (defun prestonpan ()
    (interactive)
    (erc-tls :server "nullring.xyz"
	     :port   "6697"))

  (defun liberachat ()
    (interactive)
    (erc-tls :server "irc.libera.chat"
	     :port   "6697"))

  (defun efnet ()
    (interactive)
    (erc-tls :server "irc.prison.net"
	     :port   "6697"))

  (defun matrix-org ()
    (interactive)
    (ement-connect))

  (defun gimp-org ()
    (interactive)
    (erc-tls :server "irc.gimp.org"
	     :port "6697"))

  :config
  (general-create-definer leader-key :prefix "SPC")
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

    "h r r" '(lambda () (interactive) (org-babel-load-file (expand-file-name "~/monorepo/config/emacs.org")))))

;; (use-package ellama
;;   :custom
;;   (ellama-sessions-directory "~/org/ellama/" "Set org directory for LLM sessions")
;;   :init
;;   (require 'llm-ollama)
;;   (setopt ellama-provider (make-llm-ollama
;; 	     :host "localhost"
;; 	     :chat-model "qwen2.5:14b")))

(use-package minuet
    :bind
    (("M-y" . #'minuet-complete-with-minibuffer)
     ("C-c m" . #'minuet-show-suggestion)
     :map minuet-active-mode-map
     ("C-c r" . #'minuet-dismiss-suggestion)
     ("TAB" . #'minuet-accept-suggestion))

    :init
    (add-hook 'prog-mode-hook #'minuet-auto-suggestion-mode)

    :custom
    (minuet-request-timeout 40 "Max timeout in seconds")
    (minuet-provider 'openai-fim-compatible "FIM compatible OpenAI-like API (Ollama)")
    (minuet-n-completions 1 "I am using ghost text so I only need one possible completion")
    (minuet-context-window 1024 "how much context do I want?")

    :config
    (plist-put minuet-openai-fim-compatible-options :end-point "http://localhost:11434/v1/completions")

    (plist-put minuet-openai-fim-compatible-options :name "Ollama")
    (plist-put minuet-openai-fim-compatible-options :api-key "TERM")
    (plist-put minuet-openai-fim-compatible-options :model "qwen2.5-coder:14b")

    (minuet-set-optional-options minuet-openai-fim-compatible-options :max_tokens 50))

(use-package elfeed
  :custom
  (elfeed-search-filter "@1-month-ago +unread" "Only display unread articles from a month ago")

  :config
  (run-with-timer 0 (* 60 60 4) 'elfeed-update)

  :hook ((elfeed-search-mode . elfeed-update)))

(use-package elfeed-org
  :custom
  (rmh-elfeed-org-files '("~/monorepo/config/elfeed.org") "Use elfeed config in repo as default")
  :config
  (elfeed-org))

(use-package elfeed-tube
  :after elfeed
  :demand t
  :config
  (elfeed-tube-setup)
  :bind (:map elfeed-show-mode-map
         ("F" . elfeed-tube-fetch)
         ([remap save-buffer] . elfeed-tube-save)
         :map elfeed-search-mode-map
         ("F" . elfeed-tube-fetch)
         ([remap save-buffer] . elfeed-tube-save)))

(use-package elfeed-tube-mpv
  :bind (:map elfeed-show-mode-map
              ("C-c C-f" . elfeed-tube-mpv-follow-mode)
              ("C-c C-c" . elfeed-tube-mpv)
              ("C-c C-w" . elfeed-tube-mpv-where)
         :map elfeed-search-mode-map
	        ("M" . elfeed-tube-mpv)))

(use-package treemacs)
(use-package treemacs-evil
  :after (treemacs evil))
(use-package treemacs-projectile
  :after (treemacs projectile))
(use-package treemacs-magit
  :after (treemacs magit))

(use-package eww
  :custom
  (search-engines
	'((("google" "g") "https://google.com/search?q=%s")
          (("duckduckgo" "d" "ddg") "https://duckduckgo.com/?q=%s")
          (("rfc" "r") "https://www.rfc-editor.org/rfc/rfc%s.txt")
          (("rfc-kw" "rk") "https://www.rfc-editor.org/search/rfc_search_detail.php?title=%s"))
	"use this set of search engines")

  (search-engine-default "google" "Use google as default")
  (eww-search-prefix "https://google.com/search?q=" "Google prefix")
  :hook ((eww-mode . (lambda () (local-set-key (kbd "y Y") #'eww-copy-page-url)))))

(use-package org-roam
  :after (org)
  :custom
  (org-roam-db-update-on-save t "Update org-roam db")
  (org-roam-graph-viewer "firefox" "Use firefox to view org-roam graph")
  (org-roam-directory (file-truename "~/monorepo/mindmap") "Set org-roam directory inside monorepo")
  (org-roam-capture-templates '(("d" "default" plain "%?"
				 :target (file+head "${title}.org"
						    "#+title: ${title}\n#+author: Preston Pan\n#+html_head: <link rel=\"stylesheet\" type=\"text/css\" href=\"../style.css\" />\n#+html_head: <script src=\"https://polyfill.io/v3/polyfill.min.js?features=es6\"></script>\n#+html_head: <script id=\"MathJax-script\" async src=\"https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js\"></script>\n#+options: broken-links:t")
				 :unnarrowed t)) "org-roam files start with this snippet by default")
  :config
  (org-roam-db-autosync-mode)
  ;; Otherwise links are broken when publishing
  (org-roam-update-org-id-locations))

(use-package org-roam-ui
  :after org-roam
  :hook (after-init . org-roam-ui-mode)
  :custom
  (org-roam-ui-sync-theme t "Use emacs theme for org-roam-ui")
  (org-roam-ui-follow t "Have cool visual while editing org-roam")
  (org-roam-ui-update-on-save t "This option is obvious")
  (org-roam-ui-open-on-start t "Have cool visual open in firefox when emacs loads"))

(use-package pinentry
  :custom (epa-pinentry-mode `loopback "Set this option to match gpg-agent.conf")
  :config (pinentry-start))

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

(use-package emms
  :custom
  (emms-source-file-default-directory (expand-file-name "~/music/") "Use directory specified in Nix")
  (emms-player-mpd-music-directory (expand-file-name "~/music/") "Use directory specified in Nix")
  (emms-player-mpd-server-name "localhost" "Connect to localhost")
  (emms-player-mpd-server-port "6600" "Connect to port 6600")
  (emms-player-list '(emms-player-mpd) "Use mpd")
  (emms-lyrics-display-on-modeline t)
  :hook
  ((emms-playlist-mode . emms-lyrics-mode)
   (emms-player-started . emms-lyrics-lrclib-get))
  :init
  (emms-all)
  (add-to-list 'emms-info-functions 'emms-info-mpd)
  (add-to-list 'emms-player-list 'emms-player-mpd)
  :config (emms-player-mpd-connect))

(use-package centaur-tabs
  :custom
  (centaur-tabs-set-icons t "use icons for centaur-tabs")
  (centaur-tabs-set-modified-marker t "show when buffer modified")
  (centaur-tabs-icon-type 'all-the-icons "use all-the-icons for icons")
  :demand
  :config
  (centaur-tabs-mode t)
  :bind
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward))

(use-package lean4-mode
  :commands lean4-mode
  :vc (:url "https://github.com/leanprover-community/lean4-mode.git"
       :rev "76895d8939111654a472cfc617cfd43fbf5f1eb6"))
