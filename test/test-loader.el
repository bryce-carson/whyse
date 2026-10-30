(setq test-directory (file-name-directory load-file-name)
      build-directory (expand-file-name "../build" test-directory))

(when (and (load-library "peg")
           (load (expand-file-name "peg-noweb.el" build-directory)))
  (load-file (expand-file-name "test.el" test-directory)))

(defun test-peg-noweb ()
  (interactive)
  (require 'ido)
  (let ((f (ido-completing-read
            "Select a web: "
            (directory-files test-directory :full "\\.nw$"))))
    (find-file-read-only f)
    (peg-noweb-parse-files
     (format "markup %s | noidx -delay" f))))

(setq spacemacs-package-dir "/home/bryce/.emacs.d/elpa/30.2/develop/")
(add-to-list 'load-path (expand-file-name "polymode-20260505.1803" spacemacs-package-dir))
(add-to-list 'load-path (expand-file-name "poly-noweb-20200316.1315" spacemacs-package-dir))
(require 'poly-noweb)
