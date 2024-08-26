;;;; package.lisp -> wpctl

(uiop:define-package #:wpctl
  (:use #:cl :stumpwm)
  (:local-nicknames (:re :ppcre)
                    (:pf :parse-float))
  (:export #:volume-up
           #:volume-down
           #:set-volume
           #:get-volume
           #:get-mute
           #:mute
           #:unmute
           #:toggle-mute
           #:modeline
           #:ml-bar
           #:ml-volume
           #:*default-sink-id*
           #:*default-source-id*
           #:*mixer-command*
           #:*wpctl-path*
           #:*step*
           #:*modeline-fmt*
           #:*source-modeline-fmt*))
