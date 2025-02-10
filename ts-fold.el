;;; ts-fold.el --- Code folding using tree-sitter  -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Junyi Hou
;; Copyright (C) 2021-2025  Shen, Jen-Chieh

;; Created date 2021-08-11 14:12:37

;; Author: Junyi Hou <junyi.yi.hou@gmail.com>
;;         Shen, Jen-Chieh <jcs090218@gmail.com>
;; URL: https://github.com/emacs-tree-sitter/ts-fold
;; Version: 0.3.1
;; Package-Requires: ((emacs "26.1") (tree-sitter "0.15.1") (s "1.9.0") (fringe-helper "1.0.1"))
;; Keywords: convenience folding tree-sitter

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This package provides a code-folding mechanism based on tree-sitter
;; package.  Turn on the minor-mode `ts-fold-mode' to enable
;; this mechanism.  Note that all functionalities provided here based on the
;; `tree-sitter-mode', and thus it should be enabled before
;; `ts-fold-mode' can properly fold codes.

;;; Code:

(require 'seq)
(require 'subr-x)

(require 's)
(require 'tree-sitter)

(require 'ts-fold-util)
(require 'ts-fold-parsers)
(require 'ts-fold-summary)

;;
;; (@* "Customization" )
;;

(defgroup ts-fold nil
  "Code folding using tree-sitter."
  :group 'tree-sitter
  :prefix "ts-fold-")

;; TODO(everyone): This is a bit messy, but try to keep this alist
;; alphabetically sorted
(defcustom ts-fold-range-alist
  `((actionscript-mode      . ,(ts-fold-parsers-actionscript))
    (agda-mode              . ,(ts-fold-parsers-agda))
    (arduino-mode           . ,(ts-fold-parsers-arduino))
    (asm-mode               . ,(ts-fold-parsers-asm))
    (fasm-mode              . ,(ts-fold-parsers-asm))
    (masm-mode              . ,(ts-fold-parsers-asm))
    (nasm-mode              . ,(ts-fold-parsers-asm))
    (gas-mode               . ,(ts-fold-parsers-asm))
    (beancount-mode         . ,(ts-fold-parsers-beancount))
    (c-mode                 . ,(ts-fold-parsers-c))
    (c++-mode               . ,(ts-fold-parsers-c++))
    (caml-mode              . ,(ts-fold-parsers-ocaml))
    (cmake-mode             . ,(ts-fold-parsers-cmake))
    (clojure-mode           . ,(ts-fold-parsers-clojure))
    (csharp-mode            . ,(ts-fold-parsers-csharp))
    (css-mode               . ,(ts-fold-parsers-css))
    (dart-mode              . ,(ts-fold-parsers-dart))
    (editorconfig-conf-mode . ,(ts-fold-parsers-editorconfig))
    (emacs-lisp-mode        . ,(ts-fold-parsers-elisp))
    (elixir-mode            . ,(ts-fold-parsers-elixir))
    (erlang-mode            . ,(ts-fold-parsers-erlang))
    (ess-r-mode             . ,(ts-fold-parsers-r))
    (fish-mode              . ,(ts-fold-parsers-fish))
    (gdscript-mode          . ,(ts-fold-parsers-gdscript))
    (glsl-mode              . ,(ts-fold-parsers-glsl))
    (go-mode                . ,(ts-fold-parsers-go))
    (groovy-mode            . ,(ts-fold-parsers-groovy))
    (jenkinsfile-mode       . ,(ts-fold-parsers-groovy))
    (haskell-mode           . ,(ts-fold-parsers-haskell))
    (haxe-mode              . ,(ts-fold-parsers-haxe))
    (heex-mode              . ,(ts-fold-parsers-heex))
    (hlsl-mode              . ,(ts-fold-parsers-hlsl))
    (html-mode              . ,(ts-fold-parsers-html))
    (jai-mode               . ,(ts-fold-parsers-jai))
    (janet-mode             . ,(ts-fold-parsers-janet))
    (java-mode              . ,(ts-fold-parsers-java))
    (javascript-mode        . ,(ts-fold-parsers-javascript))
    (js-mode                . ,(ts-fold-parsers-javascript))
    (js2-mode               . ,(ts-fold-parsers-javascript))
    (js3-mode               . ,(ts-fold-parsers-javascript))
    (json-mode              . ,(ts-fold-parsers-json))
    (jsonc-mode             . ,(ts-fold-parsers-json))
    (jsonnet-mode           . ,(ts-fold-parsers-jsonnet))
    (julia-mode             . ,(ts-fold-parsers-julia))
    (kotlin-mode            . ,(ts-fold-parsers-kotlin))
    (latex-mode             . ,(ts-fold-parsers-latex))
    (LaTeX-mode             . ,(ts-fold-parsers-latex))
    (lisp-mode              . ,(ts-fold-parsers-lisp))
    (lisp-interaction-mode  . ,(ts-fold-parsers-lisp))
    (llvm-mode              . ,(ts-fold-parsers-llvm))
    (llvm-mir-mode          . ,(ts-fold-parsers-llvm-mir))
    (lua-mode               . ,(ts-fold-parsers-lua))
    (makefile-mode          . ,(ts-fold-parsers-make))
    (makefile-automake-mode . ,(ts-fold-parsers-make))
    (makefile-gmake-mode    . ,(ts-fold-parsers-make))
    (makefile-makepp-mode   . ,(ts-fold-parsers-make))
    (makefile-bsdmake-mode  . ,(ts-fold-parsers-make))
    (makefile-imake-mode    . ,(ts-fold-parsers-make))
    (markdown-mode          . ,(ts-fold-parsers-markdown))
    (matlab-mode            . ,(ts-fold-parsers-matlab))
    (mermaid-mode           . ,(ts-fold-parsers-mermaid))
    (ninja-mode             . ,(ts-fold-parsers-ninja))
    (noir-mode              . ,(ts-fold-parsers-noir))
    (nix-mode               . ,(ts-fold-parsers-nix))
    (ocaml-mode             . ,(ts-fold-parsers-ocaml))
    (org-mode               . ,(ts-fold-parsers-org))
    (pascal-mode            . ,(ts-fold-parsers-pascal))
    (perl-mode              . ,(ts-fold-parsers-perl))
    (php-mode               . ,(ts-fold-parsers-php))
    (python-mode            . ,(ts-fold-parsers-python))
    (qss-mode               . ,(ts-fold-parsers-qss))
    (rjsx-mode              . ,(ts-fold-parsers-javascript))
    (rst-mode               . ,(ts-fold-parsers-rst))
    (ruby-mode              . ,(ts-fold-parsers-ruby))
    (rust-mode              . ,(ts-fold-parsers-rust))
    (rustic-mode            . ,(ts-fold-parsers-rust))
    (scheme-mode            . ,(ts-fold-parsers-scheme))
    (sh-mode                . ,(ts-fold-parsers-bash))
    (scala-mode             . ,(ts-fold-parsers-scala))
    (sql-mode               . ,(ts-fold-parsers-sql))
    (svelte-mode            . ,(ts-fold-parsers-svelte))
    (swift-mode             . ,(ts-fold-parsers-swift))
    (tablegen-mode          . ,(ts-fold-parsers-tablegen))
    (toml-mode              . ,(ts-fold-parsers-toml))
    (conf-toml-mode         . ,(ts-fold-parsers-toml))
    (tuareg-mode            . ,(ts-fold-parsers-ocaml))
    (typescript-mode        . ,(ts-fold-parsers-typescript))
    (verilog-mode           . ,(ts-fold-parsers-verilog))
    (vhdl-mode              . ,(ts-fold-parsers-vhdl))
    (nxml-mode              . ,(ts-fold-parsers-xml))
    (yaml-mode              . ,(ts-fold-parsers-yaml))
    (k8s-mode               . ,(ts-fold-parsers-yaml))
    (zig-mode               . ,(ts-fold-parsers-zig)))
  "An alist of (major-mode . (foldable-node-type . function)).

FUNCTION is used to determine where the beginning and end for FOLDABLE-NODE-TYPE
in MAJOR-MODE.  It should take a single argument (the syntax node with type
FOLDABLE-NODE-TYPE) and return the buffer positions of the beginning and end of
the fold in a cons cell.  See `ts-fold-range-python-def' for an example."
  :type '(alist :key-type symbol
                :value-type (alist :key-type symbol :value-type function))
  :group 'ts-fold)

(defcustom ts-fold-mode-hook nil
  "Hook to run when enabling `ts-fold-mode`."
  :type 'hook
  :group 'ts-fold)

(defcustom ts-fold-on-fold-hook nil
  "Hook runs on folding."
  :type 'hook
  :group 'ts-fold)

(defcustom ts-fold-on-next-line t
  "If non-nil, we leave ending keywords on the next line.

This is only used in languages that uses keyword to end the scope.
For example, Lua, Ruby, etc."
  :type 'boolean
  :group 'ts-fold)

(defcustom ts-fold-priority 30
  "Fold range overlay's priority."
  :type 'integer
  :group 'ts-fold)

(defface ts-fold-replacement-face
  '((t :foreground "#808080" :box (:line-width -1 :style pressed-button)))
  "Face used to display the fold replacement text."
  :group 'ts-fold)

(defface ts-fold-replacement-mouse-face
  '((t :foreground "#808080" :box (:line-width -1 :style released-button)))
  "Face used to when mouse hovering replacement text."
  :group 'ts-fold)

(defface ts-fold-fringe-face
  '((t ()))
  "Face used to display fringe contents."
  :group 'ts-fold)

;;
;; (@* "Externals" )
;;

(defvar ts-fold-indicators-mode)

(declare-function ts-fold-indicators-mode "ts-fold-indicators.el")
(declare-function ts-fold-indicators-refresh "ts-fold-indicators.el")

;;
;; (@* "Entry" )
;;

(defun ts-fold--enable ()
  "Start folding minor mode."
  (setq-local line-move-ignore-invisible t)
  (add-to-invisibility-spec '(ts-fold . t))

  ;; evil integration
  (when (bound-and-true-p evil-fold-list)
    (add-to-list 'evil-fold-list
                 '((ts-fold-mode)
                   :toggle ts-fold-toggle
                   :open ts-fold-open
                   :close ts-fold-close
                   :open-rec ts-fold-open-recursively
                   :open-all ts-fold-open-all
                   :close-all ts-fold-close-all))))

(defun ts-fold--disable ()
  "Stop folding minor mode."
  (remove-from-invisibility-spec '(ts-fold . t))
  (let ((tree-sitter-mode t))
    (ts-fold-open-all)))

(defun ts-fold--tree-sitter-trigger ()
  "Turn `ts-fold-mode' on and off alongside `tree-sitter-mode' when in a mode
ts-fold can act on."
  (when (and tree-sitter-mode (ts-fold-usable-mode-p))
    (ts-fold-mode 1)))

;;;###autoload
(define-minor-mode ts-fold-mode
  "Folding code using tree sitter."
  :group 'ts-fold
  :init-value nil
  :lighter " TS-Fold"
  (tree-sitter--handle-dependent ts-fold-mode
    #'ts-fold--enable
    #'ts-fold--disable))

;;;###autoload
(define-globalized-minor-mode global-ts-fold-mode
  ts-fold-mode ts-fold--tree-sitter-trigger
  :group 'treesit-fold)

(defun ts-fold-usable-mode-p (&optional mode)
  "Return non-nil if `ts-fold' has defined folds for MODE."
  (let ((mode (or mode major-mode)))
    (alist-get mode ts-fold-range-alist)))

;;;###autoload
(define-minor-mode ts-fold-line-comment-mode
  "Enable line comment folding."
  :group 'ts-fold
  :init-value nil
  (when (bound-and-true-p ts-fold-indicators-mode)
    (ts-fold-indicators-refresh)))

;;
;; (@* "Core" )
;;

(defun ts-fold--range-on-same-line (range)
  "Return non-nil if RANGE is on the same line."
  (let ((beg (car range))
        (end (cdr range))
        (lbp) (lep))
    (save-excursion
      (goto-char beg)
      (setq lbp (line-beginning-position)
            lep (line-end-position)))
    (and (<= lbp beg) (<= beg lep)
         (<= lbp end) (<= end lep))))

(defun ts-fold--get-fold-range (node)
  "Return the beginning (as buffer position) of fold for NODE.
Return nil if there is no fold to be made."
  (when-let* ((fold-alist (alist-get major-mode ts-fold-range-alist))
              (fold-func (alist-get (tsc-node-type node) fold-alist)))
    (cond ((functionp fold-func) (funcall fold-func node (cons 0 0)))
          ((listp fold-func) (funcall (nth 0 fold-func) node (cons (nth 1 fold-func) (nth 2 fold-func))))
          (t (user-error "Bad folding function for node")))))

(defun ts-fold--node-range-on-same-line (node)
  "Return non-nil when NODE range is on the same line."
  (let ((range (ts-fold--get-fold-range node)))
    (or (not range)                             ; Range not defined, continue.
        (ts-fold--range-on-same-line range))))  ; On same line, continue.

(defun ts-fold--non-foldable-node-p (node mode-ranges)
  "Return non-nil if NODE is a non-foldable in MODE-RANGES."
  (or (not (alist-get (tsc-node-type node) mode-ranges))  ; Not registered, continue.
      (ts-fold--node-range-on-same-line node)))           ; On same line, continue.

(defun ts-fold--foldable-node-at-pos (&optional pos)
  "Return the smallest foldable node at POS.  If POS is nil, use `point'.

Return nil if no valid node is found.

This function is borrowed from `tree-sitter-node-at-point'."
  (let* ((pos (or pos (point)))
         (mode-ranges (alist-get major-mode ts-fold-range-alist))
         (root (tsc-root-node tree-sitter-tree))
         (node (tsc-get-descendant-for-position-range root pos pos))
         ;; Used for looping
         (current node))
    (while (and current
                (ts-fold--non-foldable-node-p current mode-ranges))
      (setq current (tsc-get-parent current)))
    current))

;;
;; (@* "Overlays" )
;;

(defun ts-fold--create-overlay (range)
  "Create invisible overlay in RANGE."
  (when range
    (let* ((beg (car range))
           (end (cdr range))
           (ov (make-overlay beg end))
           (map (make-sparse-keymap)))
      (define-key map (kbd "<mouse-1>") #'ts-fold-open)
      (overlay-put ov 'creator 'ts-fold)
      (overlay-put ov 'priority ts-fold-priority)
      (overlay-put ov 'invisible 'ts-fold)
      (overlay-put ov 'display
                   (propertize (or (and ts-fold-summary-show
                                        (ts-fold-summary--get (buffer-substring beg end)))
                                   (ts-fold--truncate-string-ellipsis))
                               'mouse-face 'ts-fold-replacement-mouse-face
                               'help-echo "mouse-1: unfold this node"
                               'keymap map))
      (overlay-put ov 'face 'ts-fold-replacement-face)
      (overlay-put ov 'modification-hooks '(ts-fold--on-change))
      (overlay-put ov 'insert-in-front-hooks '(ts-fold--on-change))
      (overlay-put ov 'isearch-open-invisible #'ts-fold--on-change)
      (overlay-put ov 'isearch-open-invisible-temporary #'ts-fold--open-invisible-temporary)
      ov)))

(defun ts-fold--open-invisible-temporary (ov hide-p)
  "Temporary show/hide OV depends on HIDE-P flag."
  (if hide-p (ts-fold--hide-ov ov)
    (ts-fold--show-ov ov)))

(defun ts-fold--on-change (ov &rest _)
  "Open overlay OV during content is changed."
  (delete-overlay ov))

(defun ts-fold--show-ov (ov &rest _)
  "Show the OV."
  (overlay-put ov 'invisible nil)
  (overlay-put ov 'display nil)
  (overlay-put ov 'face nil)
  (ts-fold-indicators-refresh))

(defun ts-fold--hide-ov (ov &rest _)
  "Hide the OV."
  (let ((beg (overlay-start ov))
        (end (overlay-end ov)))
    (overlay-put ov 'invisible 'ts-fold)
    (overlay-put ov 'display (or (and ts-fold-summary-show
                                      (ts-fold-summary--get (buffer-substring beg end)))
                                 (ts-fold--truncate-string-ellipsis)))
    (overlay-put ov 'face 'ts-fold-replacement-face))
  (ts-fold-indicators-refresh))

(defun ts-fold-overlay-at (node)
  "Return the ts-fold overlay at NODE if NODE is foldable and folded.
Return nil otherwise."
  (when-let* ((range (ts-fold--get-fold-range node)))
    (thread-last (overlays-in (car range) (cdr range))
                 (seq-filter (lambda (ov)
                               (and (eq (overlay-get ov 'invisible) 'ts-fold)
                                    (= (overlay-start ov) (car range))
                                    (= (overlay-end ov) (cdr range)))))
                 car)))

;;
;; (@* "Commands" )
;;

(defmacro ts-fold--ensure-ts (&rest body)
  "Run BODY only if `tree-sitter-mode` is enabled."
  (declare (indent 0))
  `(if (bound-and-true-p tree-sitter-mode)
       (progn ,@body)
     (user-error "Ignored, tree-sitter-mode is not enabled in the current buffer")))

;;;###autoload
(defun ts-fold-close (&optional node)
  "Fold the syntax node at `point` if it is foldable.

Foldable nodes are defined in `ts-fold-range-alist' for the
current `major-mode'.

If no NODE is found in point, do nothing."
  (interactive)
  (ts-fold--ensure-ts
    (when-let* ((node (or node (ts-fold--foldable-node-at-pos))))
      ;; make sure I do not create multiple overlays for the same fold
      (when-let* ((ov (ts-fold-overlay-at node)))
        (delete-overlay ov))
      (when-let* ((range (ts-fold--get-fold-range node))
                  (ov (ts-fold--create-overlay range)))
        (run-hooks 'ts-fold-on-fold-hook)
        ov))))

;;;###autoload
(defun ts-fold-open ()
  "Open the fold of the syntax node in which `point' resides.
If the current node is not folded or not foldable, do nothing."
  (interactive)
  (ts-fold--ensure-ts
    (when-let* ((node (ts-fold--foldable-node-at-pos))
                (ov (ts-fold-overlay-at node)))
      (delete-overlay ov)
      (run-hooks 'ts-fold-on-fold-hook)
      t)))

;;;###autoload
(defun ts-fold-open-recursively ()
  "Open recursively folded syntax NODE that are contained in the node at point."
  (interactive)
  (ts-fold--ensure-ts
    (when-let* ((node (ts-fold--foldable-node-at-pos))
                (beg (tsc-node-start-position node))
                (end (tsc-node-end-position node))
                (nodes (ts-fold--overlays-in 'invisible 'ts-fold beg end)))
      (mapc #'delete-overlay nodes)
      (run-hooks 'ts-fold-on-fold-hook)
      t)))

;;;###autoload
(defun ts-fold-close-all ()
  "Fold all foldable syntax nodes in the buffer."
  (interactive)
  (ts-fold--ensure-ts
    (let (nodes)
      (let* ((ts-fold-indicators-mode)
             (ts-fold-on-fold-hook)
             (node (tsc-root-node tree-sitter-tree))
             (patterns (seq-mapcat (lambda (fold-range) `((,(car fold-range)) @name))
                                   (alist-get major-mode ts-fold-range-alist)
                                   'vector))
             (query (tsc-make-query tree-sitter-language patterns)))
        (setq nodes (tsc-query-captures query node #'ignore)
              nodes (cl-remove-if (lambda (node)
                                    ;; Removed if on same line
                                    (ts-fold--node-range-on-same-line (cdr node)))
                                  nodes))
        (thread-last nodes
                     (mapcar #'cdr)
                     (mapc #'ts-fold-close)))
      (when nodes
        (run-hooks 'ts-fold-on-fold-hook)
        t))))

;;;###autoload
(defun ts-fold-close-all-selected (type)
  "Fold all foldable syntax nodes corresponding to TYPE in the buffer."
  (interactive "SType: ")
  (ts-fold--ensure-ts
    (let* ((node (tsc-root-node tree-sitter-tree))
           (patterns (vector (list type) '@name))
           (query (tsc-make-query tree-sitter-language patterns))
           (nodes-to-fold (tsc-query-captures query node #'ignore))
           )
      (thread-last nodes-to-fold
                   (mapcar #'cdr)
                   (mapc #'ts-fold-close))
      )))

;;;###autoload
(defun ts-fold-open-all ()
  "Unfold all syntax nodes in the buffer."
  (interactive)
  (ts-fold--ensure-ts
    (when-let* ((nodes (ts-fold--overlays-in 'invisible 'ts-fold)))
      (mapc #'delete-overlay nodes)
      (run-hooks 'ts-fold-on-fold-hook)
      t)))

;;;###autoload
(defun ts-fold-toggle ()
  "Toggle the syntax node at `point'.
If the current syntax node is not foldable, do nothing."
  (interactive)
  (ts-fold--ensure-ts
    (if-let* ((node (ts-fold--foldable-node-at-pos (point)))
              (ov (ts-fold-overlay-at node)))
        (progn
          (delete-overlay ov)
          (run-hooks 'ts-fold-on-fold-hook)
          t)
      (ts-fold-close))))

(defun ts-fold--after-command (&rest _)
  "Function call after interactive commands."
  (ts-fold-indicators-refresh))

(let ((commands '(ts-fold-close
                  ts-fold-open
                  ts-fold-open-recursively
                  ts-fold-close-all
                  ts-fold-open-all
                  ts-fold-toggle)))
  (dolist (command commands)
    (advice-add command :after #'ts-fold--after-command)))

;;
;; (@* "Rule Helpers" )
;;

(defun ts-fold--next-prev-node (node next)
  "Return previous/next sibling node starting from NODE.

If NEXT is non-nil, return next sibling.  Otherwirse, return previouse sibling."
  (if next (tsc-get-next-sibling node) (tsc-get-prev-sibling node)))

(defun ts-fold--next-prev-node-skip-newline (node next)
  "Like function `ts-fold--next-prev-node'.

For arguments NODE and NEXT, please see the function `ts-fold--next-prev-node'
for more information."
  (let ((iter-node (ts-fold--next-prev-node node next)))
    (while (and iter-node
                (equal "\n" (ignore-errors (tsc-node-text iter-node))))
      (setq iter-node (ts-fold--next-prev-node iter-node next)))
    iter-node))

(defun ts-fold--continuous-node-prefix (node prefix next)
  "Iterate through node starting from NODE and compare node-text to PREFIX;
then return the last iterated node.

Argument NEXT is a boolean type.  If non-nil iterate forward; otherwise iterate
in backward direction."
  (let* ((iter-node node) (last-node node)
         (last-line (car (tsc-node-start-point node))) line text break
         (line-range 1) (last-line-range 1) max-line-range
         (indentation (ts-fold--indentation (tsc-node-start-position iter-node)))
         next-indentation)
    (while (and iter-node (not break))
      (setq text (string-trim (tsc-node-text iter-node))
            line (car (tsc-node-start-point iter-node))
            line-range (1+ (ts-fold--count-matches "\n" text))
            max-line-range (max line-range last-line-range)
            next-indentation (ts-fold--indentation (tsc-node-start-position iter-node)))
      (if (and (ts-fold--in-range-p line (- last-line max-line-range) (+ last-line max-line-range))
               (string-prefix-p prefix text)
               (= indentation next-indentation))
          (setq last-node iter-node last-line line
                last-line-range (1+ (ts-fold--count-matches "\n" text)))
        (setq break t))
      (setq iter-node (ts-fold--next-prev-node-skip-newline iter-node next)))
    last-node))

(defun ts-fold-range-seq (node offset)
  "Return the fold range in sequence starting from NODE.

Argument OFFSET can be used to tweak the final beginning and end position."
  (let ((beg (1+ (tsc-node-start-position node)))
        (end (1- (tsc-node-end-position node))))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-markers (node offset start-seq &optional end-seq)
  "Return the fold range for NODE with an OFFSET where the range starts at
the end of the first occurence of START-SEQ and ends at the end of the node
or the start of the last occurence of the optional parameter LAST-SEQ.

START-SEQ and LAST-SEQ can be named tree-sitter nodes or anonomous nodes.

If no occurence is found for START-SEQ or END-SEQ or the
occurences overlap, then the range returned is nil."
  (when start-seq
    (when-let* ((beg-node (car (ts-fold-find-children node start-seq)))
                (end-node (if end-seq
                              (car (last (ts-fold-find-children node end-seq)))
                            node))
                (beg (tsc-node-end-position beg-node))
                (end (if end-seq
                         (tsc-node-start-position end-node)
                       (1- (tsc-node-end-position node)))))
      (unless (> beg end) (ts-fold--cons-add (cons beg end) offset)))))

(defun ts-fold-range-line-comment (node offset prefix)
  "Define fold range for line comment.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information.

Argument PREFIX is the comment prefix in string."
  (save-excursion
    (when-let* ((ts-fold-line-comment-mode)  ; XXX: Check enabled!?
                (first-node (ignore-errors
                              (ts-fold--continuous-node-prefix node prefix nil)))
                (last-node (ignore-errors
                             (ts-fold--continuous-node-prefix node prefix t)))
                (prefix-len (length prefix))
                (beg (+ (tsc-node-start-position first-node) prefix-len))
                (end (tsc-node-end-position last-node)))
      (ts-fold--cons-add (cons beg end) offset))))

(defun ts-fold-range-block-comment (node offset)
  "Define fold range for block comment.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (ts-fold-range-seq node (ts-fold--cons-add '(1 . -1) offset)))

(defun ts-fold-range-c-like-comment (node offset)
  "Define fold range for C-like comemnt.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (let ((text (tsc-node-text node)))
    (if (and (string-match-p "\n" text) (string-prefix-p "/*" text))
        (ts-fold-range-block-comment node offset)
      (if (string-prefix-p "///" text)
          (ts-fold-range-line-comment node offset "///")
        (ts-fold-range-line-comment node offset "//")))))

;;
;; (@* "Languages" )
;;

(defun ts-fold-range-asm--find-last-instruction (node)
  "Find the last instruction node by starting NODE."
  (let* ((iter-node (ts-fold--next-prev-node-skip-newline node t))
         (last iter-node))
    (while (and iter-node
                (not (member (ts-fold-2str (tsc-node-type iter-node))
                             (ts-fold-listify "label"))))
      (setq last iter-node
            iter-node (ts-fold--next-prev-node-skip-newline iter-node t)))
    last))  ; return last insturction node

(defun ts-fold-range-asm-label (node offset)
  "Define fold range for `label' in Assembly.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((beg (tsc-node-end-position node))
              (end (ts-fold-range-asm--find-last-instruction node))
              (end (tsc-node-end-position end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-beancount-transaction (node offset)
  "Define fold range for `transaction' in Beancount.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((beg (tsc-node-start-position node))
              (beg (ts-fold--eol beg))
              (end (1- (tsc-node-end-position node))))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-c-preproc-if (node offset)
  "Define fold range for `if' preprocessor.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (let* ((named-node (tsc-get-child-by-field node :condition))
         (else (or (tsc-get-child-by-field node :alternative)
                   (car (ts-fold-find-children node "#endif"))))
         (beg (tsc-node-end-position named-node))
         (end (1- (tsc-node-start-position else))))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-c-preproc-ifdef (node offset)
  "Define fold range for `ifdef' and `ifndef' preprocessor.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((named-node (tsc-get-child-by-field node :name))
              (else (or (tsc-get-child-by-field node :alternative)
                        (car (ts-fold-find-children node "#endif"))))
              (beg (tsc-node-end-position named-node))
              (end (1- (tsc-node-start-position else))))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-c-preproc-elif (node offset)
  "Define fold range for `elif' preprocessor.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((named-node (tsc-get-child-by-field node :condition))
              (parent (or (ts-fold-find-parent node "preproc_if")
                          (ts-fold-find-parent node "preproc_ifdef")))
              (next (or (tsc-get-child-by-field node :alternative)
                        (car (ts-fold-find-children parent "#endif"))))
              (beg (tsc-node-end-position named-node))
              (end (1- (tsc-node-start-position next))))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-c-preproc-else (node offset)
  "Define fold range for `else' preprocessor.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((else-str (car (split-string (tsc-node-text node) "\n")))
              (parent (or (ts-fold-find-parent node "preproc_if")
                          (ts-fold-find-parent node "preproc_ifdef")))
              (next (car (ts-fold-find-children parent "#endif")))
              (beg (+ (tsc-node-start-position node) (length else-str)))
              (end (1- (tsc-node-start-position next))))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-clojure-function (node offset)
  "Return the fold range for `list_lit' NODE in Clojure.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((name-node (nth 1 (ts-fold-find-children node "sym_lit")))
              (next-node (tsc-get-next-sibling name-node))
              (beg (tsc-node-start-position next-node))
              (end (1- (tsc-node-end-position node))))
    (unless ts-fold-on-next-line  ; display nicely
      (setq beg (ts-fold--last-eol beg)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-cmake-body (node offset)
  "Return the fold range for `body' NODE in CMake.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((beg (tsc-node-start-position node))
              (end (tsc-node-end-position node)))
    (when ts-fold-on-next-line  ; display nicely
      (setq end (ts-fold--last-eol end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-editorconfig-end-section (node)
  "Return the section NODE's end point."
  (let ((pt (tsc-node-end-position node))
        (children (reverse (ts-fold-get-children node))))
    (or (cl-some (lambda (child)
                   (when (equal 'pair (tsc-node-type child))
                     (tsc-node-end-position child)))
                 children)
        pt)))

(defun ts-fold-range-editorconfig-section (node offset)
  "Return the fold range for `section' NODE in EditorConfig.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((end-bracket (car (ts-fold-find-children node "]")))
              (beg (tsc-node-end-position end-bracket))
              (end (1- (ts-fold-range-editorconfig-end-section node))))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-elisp-function (node offset)
  "Return the fold range for `macro_definition' and `function_definition' NODE
in Elisp.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((param-node (tsc-get-nth-child node 4))
              (beg (tsc-node-start-position param-node))
              (end (1- (tsc-node-end-position node))))
    (unless ts-fold-on-next-line  ; display nicely
      (setq beg (ts-fold--last-eol beg)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-elixir (node offset)
  "Return the fold range for `function' `module' NODE in Elixir.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((end-child (ts-fold-last-child node))
              (do-child (tsc-get-nth-child node 1))
              (beg (tsc-node-start-position do-child))
              (beg (ts-fold--last-eol beg))
              (end (tsc-node-start-position end-child)))
    (when ts-fold-on-next-line  ; display nicely
      (setq end (ts-fold--last-eol end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-erlang-signature (node offset start)
  "Return the fold range for generic signature NODE in Erlang.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information.

Argument START is a string to target for the first node we use to find the
start of the position."
  (when-let* ((start-node (car (ts-fold-find-children node start)))
              (beg (tsc-node-end-position start-node))
              (end (tsc-node-end-position node)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-erlang-clause-body (node offset)
  "Return the fold range for `clause_body' NODE in Erlang.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (ts-fold-range-erlang-signature node offset "->"))

(defun ts-fold-range-erlang-type-guards (node offset)
  "Return the fold range for `type_guards' NODE in Erlang.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (ts-fold-range-erlang-signature node offset "when"))

(defun ts-fold-range-fish-function (node offset)
  "Define fold range for `function' in Fish.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((func-name (tsc-get-nth-child node 1))
              (beg (tsc-node-end-position func-name))
              (end (tsc-node-end-position node))
              (end (- end 3)))
    (when ts-fold-on-next-line  ; display nicely
      (setq end (ts-fold--last-eol end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-fish-if (node offset)
  "Define fold range for `if_statement' in Fish.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((beg (tsc-node-start-position node))
              (beg (ts-fold--eol beg))
              (end (tsc-node-end-position node))
              (end (- end 3)))
    (when ts-fold-on-next-line  ; display nicely
      (setq end (ts-fold--last-eol end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-fish-case (node offset)
  "Define fold range for `case_clause' in Fish.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((beg (tsc-node-start-position node))
              (beg (ts-fold--eol beg))
              (end (tsc-node-end-position node))
              (end (1- end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-groovy-block (node offset)
  "Define fold range for `block' in Groovy.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((open-bracket (car (ts-fold-find-children node "{")))
              (beg (tsc-node-start-position open-bracket))
              (beg (1+ beg))
              (end (tsc-node-end-position node))
              (end (1- end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-haskell-function (node offset)
  "Define fold range for `function' in Haskell.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((beg (tsc-node-start-position node))
              (beg (ts-fold--eol beg))
              (end-node (ts-fold-last-child node))
              (end (tsc-node-end-position end-node)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-html (node offset)
  "Define fold range for tag in HTML.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (let* ((beg (tsc-node-end-position (tsc-get-nth-child node 0)))
         (end-node (ts-fold-last-child node))
         (end (tsc-node-start-position end-node)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-julia-function (node offset)
  "Return the fold range for a NODE in Julia.

It excludes the NODE's first child and the `end' keyword.  For
argument OFFSET, see function `ts-fold-range-seq' for more
information."
  (when-let* ((identifier (tsc-get-nth-named-child node 0))
              (params (tsc-get-nth-named-child node 1))
              (beg (tsc-node-end-position params))
              (end (tsc-node-end-position node))
              (end (- end 3)))
    (when ts-fold-on-next-line  ; display nicely
      (setq end (ts-fold--last-eol end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-julia-if (node offset)
  "Define fold range for if statement in Julia.

It excludes the NODE's first child and the `end' keyword.  For
argument OFFSET, see function `ts-fold-range-seq' for more
information."
  (when-let* ((params (tsc-get-nth-named-child node 0))
              (beg (tsc-node-end-position params))
              (end (tsc-node-end-position node))
              (end (- end 3)))
    (when ts-fold-on-next-line  ; display nicely
      (setq end (ts-fold--last-eol end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-julia-let (node offset)
  "Define fold range for let statement in Julia.

It excludes the NODE's first child and the `end' keyword.  For
argument OFFSET, see function `ts-fold-range-seq' for more
information."
  (when-let* ((vars (ts-fold-find-children node "variable_declaration"))
              (last-var (last vars))
              (last-var (car last-var))
              (beg (tsc-node-end-position last-var))
              (end (tsc-node-end-position node))
              (end (- end 3)))
    (when ts-fold-on-next-line  ; display nicely
      (setq end (ts-fold--last-eol end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-kotlin-when (node offset)
  "Return the fold range for `when' NODE in Kotlin.

It excludes the NODE's first child and the `end' keyword.  For
argument OFFSET, see function `ts-fold-range-seq' for more
information."
  (when-let* ((open-bracket (car (ts-fold-find-children node "{")))
              (beg (tsc-node-end-position open-bracket))
              (end (1- (tsc-node-end-position node))))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-latex-environment (node offset)
  "Define fold range for latex environments.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((beg-node (tsc-get-child-by-field node :begin))
              (end-node (tsc-get-child-by-field node :end))
              (beg (tsc-node-end-position beg-node))
              (end (tsc-node-start-position end-node)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-latex-section (node offset)
  "Define fold range for latex section.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((lab-node (car (ts-fold-find-children node "curly_group")))
              (beg (tsc-node-end-position lab-node))
              (end (tsc-node-end-position node)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-lisp-function (node offset)
  "Define fold range for function in Lisp .

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((header (car (ts-fold-find-children node "defun_header")))
              (body (tsc-get-next-sibling header))
              (beg (tsc-node-start-position body))
              (end (1- (tsc-node-end-position node))))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-llvm--find-last-instruction (node)
  "Find the last instruction node by starting NODE."
  (let* ((iter-node (ts-fold--next-prev-node-skip-newline node t))
         (last iter-node))
    (while (and iter-node
                (not (member (ts-fold-2str (tsc-node-type iter-node))
                             (ts-fold-listify '("label" "}")))))
      (setq last iter-node
            iter-node (ts-fold--next-prev-node-skip-newline iter-node t)))
    last))  ; return last insturction node

(defun ts-fold-range-llvm-label (node offset)
  "Define fold range for `label' in LLVM.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((beg (tsc-node-end-position node))
              (end (ts-fold-range-llvm--find-last-instruction node))
              (end (tsc-node-end-position end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-llvm-mir-label (node offset)
  "Define fold range for `label' in LLVM MIR.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((label (car (ts-fold-find-children node "label")))
              (colon (tsc-get-next-sibling label))
              (beg (tsc-node-end-position colon))
              (beg (ts-fold--eol beg))
              (end (ts-fold-range-llvm--find-last-instruction label))
              (end (tsc-node-end-position end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-lua-comment (node offset)
  "Define fold range for Lua comemnt.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (let ((text (tsc-node-text node)))
    (if (and (string-match-p "\n" text) (string-prefix-p "--[[" text))
        (ts-fold-range-block-comment node
                                     ;; XXX: Add 2 to for ]] at the end
                                     (ts-fold--cons-add (cons 2 0) offset))
      (ts-fold-range-line-comment node offset "--"))))

(defun ts-fold-range-lua-function (node offset)
  "Define fold range for Lua `function' declaration.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (let* ((params (tsc-get-child-by-field node :parameters))
         (beg (tsc-node-end-position params))
         (end (- (tsc-node-end-position node) 3)))  ; fit identifier `end'
    (when ts-fold-on-next-line  ; display nicely
      (setq end (ts-fold--last-eol end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-lua-if (node offset)
  "Define fold range for Lua `if' statement.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (let* ((then (car (ts-fold-find-children node "then")))
         (beg (tsc-node-end-position then))
         (next (or (ts-fold-find-children-traverse node "elseif_statement")
                   (ts-fold-find-children-traverse node "else_statement")))
         (end (if next
                  (tsc-node-start-position (car next))
                (- (tsc-node-end-position node) 3))))
    (when ts-fold-on-next-line  ; display nicely
      (setq end (ts-fold--last-eol end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-lua-elseif (node offset)
  "Define fold range for Lua `elseif' statement.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (let* ((then (car (ts-fold-find-children node "then")))
         (beg (tsc-node-end-position then))
         (next (tsc-get-next-sibling node))
         (end (if next
                  (tsc-node-start-position next)
                (tsc-node-end-position node))))
    (when ts-fold-on-next-line  ; display nicely
      (setq end (ts-fold--last-eol end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-lua-else (node offset)
  "Define fold range for Lua `else' statement.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (let* ((beg (+ (tsc-node-start-position node) 4))  ; fit `else', 4 letters
         (next (tsc-get-next-sibling node))          ; the `end' node
         (end (tsc-node-start-position next)))
    (when ts-fold-on-next-line  ; display nicely
      (setq end (ts-fold--last-eol end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-lua-do-loop (node offset)
  "Define fold range for Lua `while' and `for' statement.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (let* ((do (car (ts-fold-find-children node "do")))
         (beg (tsc-node-end-position do))
         (end (- (tsc-node-end-position node) 3)))
    (when ts-fold-on-next-line  ; display nicely
      (setq end (ts-fold--last-eol end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-lua-repeat (node offset)
  "Define fold range for Lua `repeat' statement.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (let* ((beg (+ (tsc-node-start-position node) 6))  ; fit `repeat', 6 letters
         (until (car (ts-fold-find-children node "until")))
         (end (tsc-node-start-position until)))
    (when ts-fold-on-next-line  ; display nicely
      (setq end (ts-fold--last-eol end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-make-recipe (node offset)
  "Define fold range for `recipe' in Make.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((last-child (ts-fold-last-child node))
              (beg (tsc-node-start-position node))
              (end (tsc-node-end-position last-child)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-markdown-heading (node offset)
  "Define fold range for Markdown headings.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((text (tsc-node-text node))
              ((string-prefix-p "#" text))
              (beg  (tsc-node-start-position node))
              (end  (tsc-node-end-position node)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-markdown-code-block (node offset)
  "Define fold range for Markdown code blocks.
For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (let* ((beg (1+ (tsc-node-start-position node)))
         (end (1- (tsc-node-end-position node)))
         (name (+ 2 (length
                     (or (tsc-node-text (tsc-get-nth-child node 1))
                         "")))))
    (ts-fold--cons-add (cons beg end) (cons name -2) offset)))

(defun ts-fold-range-markdown-html-block (node offset)
  "Define fold range for Markdown `html_block'.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (let* ((beg (+ (tsc-node-start-position node) 2))
         (end (- (tsc-node-end-position node) 3)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-matlab-blocks (node offset)
  "Define fold range for MATLAB blocks.

Each block is delimited by a line starting with '%%'.
For arguments NODE and OFFSET, see function `ts-fold-range-line-comment' for
more information."
  (when (string-prefix-p "%%" (tsc-node-text node))
    (let* ((beg (tsc-node-end-position node))
           (end (or (save-excursion
                      (progn (goto-char beg)
                             (when (re-search-forward "^\s*\^L*%%" nil t)
                               (beginning-of-line)
                               (if (or (eq (char-after) ?\C-l)
                                       (not (save-excursion (forward-line -1)
                                                            (eq (char-after) ?\C-l))))
                                   (forward-line -1)
                                 (forward-line -2))
                               (end-of-line) (point))))
                    (tsc-node-end-position (tsc-get-parent node)))))
      (ts-fold--cons-add (cons beg end) offset))))

(defun ts-fold-range-matlab-function (node offset)
  "Define fold range for MATLAB function definitions.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((named-node (or (tsc-get-child-by-field node :superclass)
                              (tsc-get-child-by-field node :properties)
                              (tsc-get-child-by-field node :methods)
                              (tsc-get-child-by-field node :function_arguments)
                              (tsc-get-child-by-field node :function_output)
                              (tsc-get-child-by-field node :name)))
              (beg (tsc-node-end-position (tsc-get-next-sibling named-node)))
              (end (tsc-node-end-position node)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-matlab-statements (node offset)
  "Define fold range for MATLAB statements.

For arguments NODE and OFFSET, see function `ts-fold-range-line-comment' for
more information."
  (when-let* ((cur-node (tree-sitter-node-at-pos))
              (named-node (car (ts-fold-find-children node "\n")))
              (beg (tsc-node-start-position named-node))
              (ins (append
                    (ts-fold-find-children node "catch_clause")
                    (ts-fold-find-children node "case_clause")
                    (ts-fold-find-children node "otherwise_clause")
                    (ts-fold-find-children node "elseif_clause")
                    (ts-fold-find-children node "else_clause")
                    (ts-fold-find-children node "end")))  ;; can include parts maybe
              (end (tsc-node-start-position (car (ts-fold-find-children node "end")))))
    (when (string-suffix-p "clause" (format "%s" (tsc-node-type (tsc-get-parent cur-node))))
      (if (or (equal (tsc-node-type cur-node) "otherwise")
              (equal (tsc-node-type cur-node) "else"))
          (setq beg (tsc-node-end-position cur-node))
        (setq beg (tsc-node-end-position (tsc-get-next-sibling cur-node))))
      (setq end (1- (tsc-node-end-position (tsc-get-parent cur-node)))))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-mermaid-diagram (node offset)
  "Define fold range for any diagram in Mermaid.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((first-child (tsc-get-nth-child node 0))
              (beg (tsc-node-end-position first-child))
              (beg (ts-fold--eol beg))
              (end (tsc-node-end-position node)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-mermaid-block (node offset)
  "Define fold range for any block in Mermaid.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((beg-bracket (car (ts-fold-find-children node "{")))
              (end-bracket (ts-fold-last-child node))
              (beg (tsc-node-end-position beg-bracket))
              (end (tsc-node-start-position end-bracket)))
    (ts-fold--cons-add (cons beg end) offset)))

;;+ OCaml

(defun ts-fold-range-ocaml-comment (node offset)
  "Define fold range for `comment'.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((text (tsc-node-text node))
              (beg  (+ (if (string-prefix-p "(* " text) 2 3)
                       (tsc-node-start-position node)))
              (end  (- (tsc-node-end-position node) 2)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-ocaml-module-definition (node offset)
  "Define fold range for `module_definition'.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let*
      ((module-binding (tsc-get-nth-named-child node 0))
       (body           (tsc-get-child-by-field module-binding :body))
       ;; body is struct ... end
       (beg            (+ 6 (tsc-node-start-position body)))
       (end            (- (tsc-node-end-position node) 3)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-ocaml-type-definition (node offset)
  "Define fold range for `type_definition'.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let*
      ((type-definition (tsc-get-nth-named-child node 0))
       (body            (tsc-get-child-by-field type-definition :body))
       (text            (tsc-node-text (tsc-get-nth-child body 0)))
       (beg
        (if (string-equal "{" text)
            (1+ (tsc-node-start-position body))
          (tsc-node-end-position (tsc-get-prev-sibling body))))
       (end
        (if (string-equal "{" text)
            (1- (tsc-node-end-position node))
          (tsc-node-end-position node))))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-ocaml-value-definition (node offset)
  "Define fold range for `value_definition'.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let*
      ((let-binding  (tsc-get-nth-named-child node 0))
       (body         (tsc-get-child-by-field let-binding :body))
       (beg          (tsc-node-end-position (tsc-get-prev-sibling body)))
       (end          (tsc-node-end-position node)))
    (ts-fold--cons-add (cons beg end) offset)))

;;- OCaml

(defun ts-fold-range-org-body (node offset)
  "Define fold range for `body' in Org.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let*
      ((parent (tsc-get-parent node))
       (parent (tsc-get-parent parent)))
    (ts-fold--cons-add (cons -1 0) (ts-fold-range-seq node offset))))

(defun ts-fold-range-pascal-comment (node offset)
  "Define fold range for `comment' in Pascal.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (let ((text (tsc-node-text node)))
    (cond ((string-prefix-p "{" text)
           (ts-fold-range-seq node offset))
          ((string-prefix-p "(*" text)
           (ts-fold-range-seq node (ts-fold--cons-add '(1 . -1) offset)))
          (t
           (ts-fold-range-c-like-comment node offset)))))

(defun ts-fold-range-python-def (node offset)
  "Define fold range for `function_definition' and `class_definition'.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((named-node (or (tsc-get-child-by-field node :superclasses)
                              (tsc-get-child-by-field node :return_type)
                              (tsc-get-child-by-field node :parameters)
                              (tsc-get-child-by-field node :name)))
              ;; the colon is an anonymous node after return_type or parameters node
              (beg (tsc-node-end-position (tsc-get-next-sibling named-node)))
              (end (tsc-node-end-position node)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-python-expression-statement (node offset)
  "Define fold range for `expression_statement'.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((string-node (car (ts-fold-find-children-traverse node "string")))
              ;; the colon is an anonymous node after return_type or parameters node
              (beg (tsc-node-start-position string-node))
              (end (tsc-node-end-position node)))
    (ts-fold--cons-add (cons (+ beg 3) (- end 3)) offset)))

(defun ts-fold-range-rst-body (node offset)
  "Define fold range for `body' in reStructuredText.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (let* ((first (car (ts-fold-get-children node)))
         (beg (tsc-node-end-position first))
         (end (tsc-node-end-position node))
         (same-pos (= beg end))
         (beg (if same-pos (tsc-node-start-position node) beg)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-ruby-class-def (node offset)
  "Define fold range for `method' and `class' in Ruby.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((named-node (or (tsc-get-child-by-field node :superclass)
                              (tsc-get-child-by-field node :parameters)
                              (tsc-get-child-by-field node :name)))
              (beg (tsc-node-end-position named-node))
              (end (tsc-node-end-position node))
              (end (- end 3)))
    (when ts-fold-on-next-line  ; display nicely
      (setq end (ts-fold--last-eol end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-ruby-if (node offset)
  "Define fold range for `if' (then), `elsif', and `else' in Ruby.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((beg (tsc-node-start-position node))
              (end (cond ((when-let* ((next (tsc-get-next-sibling node)))
                            (tsc-node-start-position next)))
                         ((when-let* ((parent (ts-fold-find-parent node "if")))
                            (- (tsc-node-end-position parent) 3))))))
    (when ts-fold-on-next-line  ; display nicely
      (setq end (ts-fold--last-eol end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-rust-macro (node offset)
  "Return the fold range for `macro_definition' in Rust.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((last_bracket (ts-fold-last-child node))
              (first_bracket (tsc-get-nth-child node 2))
              (beg (tsc-node-start-position first_bracket))
              (end (1+ (tsc-node-start-position last_bracket))))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-sql-block (node offset)
  "Return the fold range for `block' in SQL.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((beg-node (car (ts-fold-find-children node "keyword_begin")))
              (end-node (car (ts-fold-find-children node "keyword_end")))
              (beg (tsc-node-end-position beg-node))
              (end (tsc-node-start-position end-node)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-toml-table (node offset)
  "Return the fold range for `table' in TOML.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((close-bracket (car (ts-fold-find-children node "]")))
              (beg (tsc-node-end-position close-bracket))
              (end-child (ts-fold-last-child node))
              (end (tsc-node-end-position end-child)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-verilog-initial-construct (node offset)
  "Return the fold range for `initial' in Verilog.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((beg (tsc-node-start-position node))
              (beg (ts-fold--eol beg))
              (end-child (ts-fold-last-child node))
              (end (tsc-node-end-position end-child))
              (end (ts-fold--bol end)))
    (when ts-fold-on-next-line
      (setq end (ts-fold--last-eol end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-verilog-list (node offset)
  "Return the fold range for `list' in Verilog.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((prev (tsc-get-prev-sibling node))
              (next (tsc-get-next-sibling node))
              (beg (tsc-node-end-position prev))
              (end (tsc-node-start-position next)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-verilog-module (node offset)
  "Return the fold range for `module' in Verilog.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((close-bracket (car (ts-fold-find-children node ";")))
              (beg (tsc-node-end-position close-bracket))
              (end-child (ts-fold-last-child node))
              (end (tsc-node-end-position end-child))
              (end (ts-fold--bol end)))
    (when ts-fold-on-next-line
      (setq end (ts-fold--last-eol end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-vhdl-package (node offset)
  "Return the fold range for `package' in VHDL.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((start-child (car (ts-fold-find-children node "declarative_part")))
              (beg (tsc-node-start-position start-child))
              (beg (ts-fold--last-eol beg))
              (end-child (car (ts-fold-find-children node "end")))
              (end (tsc-node-start-position end-child)))
    (when ts-fold-on-next-line
      (setq end (ts-fold--last-eol end)))
    (ts-fold--cons-add (cons beg end) offset)))

(defun ts-fold-range-vhdl-type (node offset)
  "Return the fold range for `type' in VHDL.

For arguments NODE and OFFSET, see function `ts-fold-range-seq' for
more information."
  (when-let* ((start-child (car (ts-fold-find-children node "record_type_definition")))
              (record (car (ts-fold-find-children start-child "record")))
              (beg (tsc-node-end-position record))
              (end-child (car (ts-fold-find-children start-child "end")))
              (end (tsc-node-start-position end-child)))
    (when ts-fold-on-next-line
      (setq end (ts-fold--last-eol end)))
    (ts-fold--cons-add (cons beg end) offset)))

(provide 'ts-fold)
;;; ts-fold.el ends here
