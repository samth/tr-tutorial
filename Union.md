# Union Types and Occurrence Typing

How do you report failure in Racket?

```
(string->number "2012")
(string->number "RacketCon")
```

```
(define v (string->number (read-string)))
(cond [(number? v) (* v 2)]
      [else (error 'whoops)])
```

This is called _occurrence typing_.  The basic idea is that predicates
like `number?` change how the type system treats `v` on the right hand
side of the `cond`.

We can also just test the variable, since it's either a `Number` or
`#f`:

```
(define v (string->number (read-string)))
(cond [v (* v 2)]
      [else (error 'whoops)])
```

We can also combine conditions with `and` and `or`, or nest them.

We can even abstract over predicates:

```
(: loi? : (Listof Any) -> Boolean : (Listof Integer))
(define (loi? n) (andmap exact-integer? n))
```

