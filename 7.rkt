#lang typed/racket
;; A dice-rolling command-line utility
(command-line
 #:args (#{dice : String} #{sides : String})
 (for ([i (in-range (assert (string->number dice) exact-integer?))])
   (displayln
    (+ 1 (random (assert (string->number sides) exact-integer?))))))