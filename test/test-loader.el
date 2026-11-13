(setq test-directory (file-name-directory load-file-name)
      build-directory (expand-file-name "../build" test-directory))

(when (and (load-library "peg")
           (load (expand-file-name "whyse.el" build-directory))
           (mapc (lambda (package-dir)
                   (add-to-list 'load-path (expand-file-name
                                            package-dir
                                            "/home/bryce/.emacs.d/elpa/30.2/develop/")))
                 '("dash-20260221.1346"
                   "ht-20230703.558"
                   "dag-draw-20260627.2238"))
           (require 'dag-draw)
           (toggle-debug-on-error))
  (load-file (expand-file-name "test.el" test-directory)))
