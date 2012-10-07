#lang typed/racket ; Sending email from racket
(require typed/net/sendmail)
(sleep (* (- (* 60 4) 15) 60)) ; 4h - 15m
(send-mail-message
 (assert (getenv "EMAIL")) "Parking meter alert!"
 (list (assert (getenv "EMAIL"))) null null
 '("Time to go out and move your car."))