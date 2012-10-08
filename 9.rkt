#lang typed/racket   
; draw a graph of cos
; and deriv^3(cos)
(require/typed plot/utils
               [#:opaque Renderer2D renderer2d?])
(require/typed plot
               [function ((Real -> Real) Integer Integer [#:color Symbol] -> Renderer2D)]
               [plot ((Listof Renderer2D) -> Any)]) 
(: deriv : (Real -> Real) -> Real -> Real)
(define ((deriv f) x)
  (/ (- (f x) (f (- x 0.001))) 0.001))
(: thrice : (All (A) (A -> A) -> (A -> A)))
(define (thrice f) (lambda (x) (f (f (f x)))))
(plot (list (function ((thrice deriv) sin) -5 5)
            (function cos -5 5 #:color 'blue)))