;;; early-init.el --- chargé avant l'init -*- lexical-binding: t; -*-

;; Les paquets viennent de Nix : package.el n'a rien à faire ici.
(setq package-enable-at-startup nil)

;; GC moins agressif pendant le démarrage.
(setq gc-cons-threshold (* 128 1024 1024))

;; Interface nue, décidée avant le premier rendu.
(setq inhibit-startup-screen t
      frame-resize-pixelwise t)
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;;; early-init.el ends here
