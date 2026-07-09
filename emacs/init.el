;;; init.el --- magit + org-roam, Emacs vanilla -*- lexical-binding: t; -*-
;;
;; Aucune couche modale. Paquets fournis par Nix (voir emacs.nix) :
;; les `use-package' ne font que configurer, jamais installer.

;;;; ── Fondations ─────────────────────────────────────────────────────

;; Le bruit de customize hors du dépôt.
(setq custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file) (load custom-file))

;; Pas de fichiers parasites à côté des vrais.
(setq make-backup-files nil
      auto-save-default nil
      create-lockfiles nil)

(setq ring-bell-function 'ignore
      use-short-answers t
      sentence-end-double-space nil)

(savehist-mode 1)                 ; historique du minibuffer
(recentf-mode 1)                  ; fichiers récents (consult-buffer les liste)
(save-place-mode 1)               ; rouvrir au dernier point
(global-auto-revert-mode 1)       ; suivre les modifs externes (hx, git…)
(electric-pair-mode 1)
(which-key-mode 1)                ; intégré depuis Emacs 30
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;;;; ── Thème ──────────────────────────────────────────────────────────

(use-package catppuccin-theme
  :config
  (setq catppuccin-flavor 'mocha)  ; latte / frappe / macchiato / mocha
  (load-theme 'catppuccin :no-confirm))

;;;; ── Minibuffer façon fzf : vertico + orderless + consult ───────────

(use-package vertico
  :config (vertico-mode 1))

(use-package orderless
  :demand t   ; sans quoi son entrée dans completion-styles-alist
              ; n'est jamais enregistrée : voir vertico/corfu ci-dessus
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :config (marginalia-mode 1))

(use-package consult
  :bind (("C-s"   . consult-line)      ; recherche floue dans le buffer
         ("C-x b" . consult-buffer)
         ("M-y"   . consult-yank-pop)
         ("C-c r" . consult-ripgrep)   ; votre rgf, version intégrée
         ("C-c f" . consult-fd)))

(use-package embark
  :bind (("C-." . embark-act)))        ; actions contextuelles sur le candidat

(use-package embark-consult
  :after (embark consult))

;;;; ── Complétion dans le buffer ──────────────────────────────────────

(use-package corfu
  :custom (corfu-auto t)
  :config (global-corfu-mode 1))

(use-package corfu-terminal            ; inactif en GUI, prend le relais en TTY
  :after corfu
  :config (corfu-terminal-mode 1))

;;;; ── Tree-sitter & LSP (natifs) ─────────────────────────────────────
;; Grammaires : toutes installées (treesit-grammars.with-all-grammars).
;; Serveurs LSP : pris dans votre environnement, exactement comme pour hx.

;; Tous les modes tree-sitter intégrés d'Emacs 30 prennent la main
;; sur leurs équivalents historiques.
(setq major-mode-remap-alist
      '((sh-mode         . bash-ts-mode)
        (bash-mode       . bash-ts-mode)
        (c-mode          . c-ts-mode)
        (c++-mode        . c++-ts-mode)
        (c-or-c++-mode   . c-or-c++-ts-mode)
        (csharp-mode     . csharp-ts-mode)
        (css-mode        . css-ts-mode)
        (html-mode       . html-ts-mode)
        (mhtml-mode      . html-ts-mode)
        (java-mode       . java-ts-mode)
        (javascript-mode . js-ts-mode)
        (js-mode         . js-ts-mode)
        (js-json-mode    . json-ts-mode)
        (python-mode     . python-ts-mode)
        (ruby-mode       . ruby-ts-mode)
        (conf-toml-mode  . toml-ts-mode)))

;; Extensions dont le mode ts ne s'enregistre pas (ou pas partout) seul.
(dolist (assoc
         '(("\\.ts\\'"                   . typescript-ts-mode)
           ("\\.mts\\'"                  . typescript-ts-mode)
           ("\\.cts\\'"                  . typescript-ts-mode)
           ("\\.tsx\\'"                  . tsx-ts-mode)
           ("\\.go\\'"                   . go-ts-mode)
           ("/go\\.mod\\'"               . go-mod-ts-mode)
           ("\\.ya?ml\\'"                . yaml-ts-mode)
           ("\\.lua\\'"                  . lua-ts-mode)
           ("\\.php\\'"                  . php-ts-mode)
           ("\\.exs?\\'"                 . elixir-ts-mode)
           ("\\.heex\\'"                 . heex-ts-mode)
           ("\\.cmake\\'"                . cmake-ts-mode)
           ("CMakeLists\\.txt\\'"        . cmake-ts-mode)
           ("/Dockerfile\\(?:\\..*\\)?\\'" . dockerfile-ts-mode)))
  (add-to-list 'auto-mode-alist assoc))

(use-package nix-ts-mode
  :mode "\\.nix\\'")

(use-package typst-ts-mode
  :mode "\\.typ\\'")

(use-package web-mode                  ; templates : vue, twig, jinja…
  :mode ("\\.vue\\'" "\\.twig\\'" "\\.j2\\'" "\\.jinja2?\\'"))

;; Les autres modes externes (markdown, haskell, OCaml, zig, gleam, kotlin,
;; scala, swift, julia, clojure, erlang, elm, fish, nim, crystal, dart,
;; racket, F#, D, GLSL, meson, dhall, jsonnet, solidity, svelte, protobuf,
;; terraform, graphql, just…) s'enregistrent seuls via leurs autoloads,
;; chargés par le site-start de Nix : rien à déclarer ici.

(use-package eglot
  :hook ((bash-ts-mode c-ts-mode c++-ts-mode csharp-ts-mode
          go-ts-mode java-ts-mode js-ts-mode json-ts-mode
          python-ts-mode ruby-ts-mode rust-ts-mode
          typescript-ts-mode tsx-ts-mode yaml-ts-mode
          nix-ts-mode zig-mode haskell-mode tuareg-mode
          typst-ts-mode markdown-mode)
         . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs '(nix-ts-mode . ("nil")))
  (add-to-list 'eglot-server-programs '(typst-ts-mode . ("tinymist")))
  (add-to-list 'eglot-server-programs '(markdown-mode . ("marksman"))))

;;;; ── Magit ──────────────────────────────────────────────────────────

(use-package magit
  :bind (("C-x g" . magit-status)))

;;;; ── Org + org-roam ─────────────────────────────────────────────────

(use-package org
  :custom
  (org-directory "~/org")
  (org-startup-indented t)
  (org-return-follows-link t))

(use-package org-roam
  :demand t   ; chargé par le démon : popup de capture instantanée
  :custom
  (org-roam-directory (file-truename "~/org/roam"))
  (org-roam-dailies-directory "daily/")
  :bind (("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ("C-c n l" . org-roam-buffer-toggle)
         ("C-c n d" . org-roam-dailies-capture-today)
         ("C-c n j" . org-roam-dailies-goto-today))
  :config
  (unless (file-directory-p org-roam-directory)
    (make-directory org-roam-directory t))
  (setq org-roam-dailies-capture-templates
        '(("d" "défaut" entry "* %<%H:%M> %?"
           :target (file+head "%<%Y-%m-%d>.org"
                              "#+title: %<%Y-%m-%d>\n"))))
  (org-roam-db-autosync-mode 1))       ; l'index SQLite suit les fichiers

;;; init.el ends here
