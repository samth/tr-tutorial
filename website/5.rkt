#lang typed/racket  ; A picture
(require/typed 2htdp/image
               [#:opaque Image image?]
               [triangle (Integer Symbol Symbol -> Image)]
               [above (Image Image -> Image)]
               [beside (Image Image -> Image)]
               [freeze (Image -> Image)])

(let: sierpinski : Image ([n : Integer 8])
  (if (zero? n)
    (triangle 2 'solid 'red)
    (let ([t (sierpinski (- n 1))])
      (freeze (above t (beside t t))))))