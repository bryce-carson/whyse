(setq test-directory (file-name-directory load-file-name)
      build-directory (expand-file-name "../build" test-directory))

(when (and (load-library "peg")
           (load (expand-file-name "whyse.el" build-directory)))
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


(mapc (lambda (package-dir)
        (add-to-list 'load-path (expand-file-name
                                 package-dir
                                 "/home/bryce/.emacs.d/elpa/30.2/develop/")))
      '("dash-20260221.1346"
        "ht-20230703.558"
        "dag-draw-20260627.2238"))
