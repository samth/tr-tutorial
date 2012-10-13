#lang racket
;; A dice-rolling command-line utility
(command-line
 #:args (dice sides)
 (for ([i (in-range (string->number dice))])
   (displayln
    (+ 1 (random (string->number sides))))))