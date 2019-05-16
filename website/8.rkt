#lang racket
;; Print the Greek alphabet
(for ([i (in-range 25)])
  (display
   (integer->char
    (+ i (char->integer #\u3B1)))))