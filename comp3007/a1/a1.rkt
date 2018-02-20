; Author: Michael Maxwell
; Student #: 101006277

; 1a
(+ 1 -2 3 -4 5 -6)

; 1b
(+ 7 (- (* 12 5) (* (+ 8/2) 3) (- 9/3 1)))

; 1c
(* (+ (* 36/9 (+ 6/2 6/3) 5 10) 9) 2)

; 1d
(+ (* (+ 1/4 3/7) 4.5) 2.7)

; 2a
; purpose: returns the reciprocal of the input, that is 1/x
; input: x must be a number
; output: 1/x or #f if x = 0
(define (reciprocal x)
  (if (= x 0) #f (/ 1 x))
)

; 2b
; purpose: returns [3x + 12 / (x + 1)]
; input: x must be a number (not -1)
; output: the result of the expression
(define (f x)
  (+ (* 3 x) (/ 12 (+ x 1)))
)

; 2c
; purpose: returns 0.25x
; input: x must be a number
; output: result of the expression
(define (g x)
  (* x (reciprocal 4))
)

; 2d
; (+ (f (- (* 3 2) 1))(g (reciprocal (/ 1 12))))
; (+ (f (- 6 1))(g (reciprocal (/ 1 12))))
; (+ (f 5)(g (reciprocal (/ 1 12))))
; (+ (+ (* 3 5) (/ 12 (+ 5 1)))(g (reciprocal (/ 1 12))))
; (+ (+ 15 (/ 12 (+ 5 1)))(g (reciprocal (/ 1 12))))
; (+ (+ 15 (/ 12 6))(g (reciprocal (/ 1 12))))
; (+ (+ 15 2)(g (reciprocal (/ 1 12))))
; (+ 17 (g (reciprocal (/ 1 12))))
; (+ 17 (g (reciprocal 1/12)))
; (+ 17 (g (if (= 1/12 0) #f (/ 1 1/12))))
; (+ 17 (g (/ 1 1/12)))
; (+ 17 (g 12))
; (+ 17 (* 12 (reciprocal 4)))
; (+ 17 (* 12 (if (= 4 0) #f (/ 1 4))))
; (+ 17 (* 12 (/ 1 4)))
; (+ 17 (* 12 1/4))
; (+ 17 3)
; 20

; 2e
; (+ (f (- (* 3 2) 1))(g (reciprocal (/ 1 12))))
; (+ (+ (* 3 (- (* 3 2) 1)) (/ 12 (+ (- (* 3 2) 1) 1)))(g (reciprocal (/ 1 12))))
; (+ (+ (* 3 (- 6 1)) (/ 12 (+ (- (* 3 2) 1) 1)))(g (reciprocal (/ 1 12))))
; (+ (+ (* 3 5) (/ 12 (+ (- (* 3 2) 1) 1)))(g (reciprocal (/ 1 12))))
; (+ (+ 15 (/ 12 (+ (- (* 3 2) 1) 1)))(g (reciprocal (/ 1 12))))
; (+ (+ 15 (/ 12 (+ (- 6 1) 1)))(g (reciprocal (/ 1 12))))
; (+ (+ 15 (/ 12 (+ 5 1)))(g (reciprocal (/ 1 12))))
; (+ (+ 15 (/ 12 6))(g (reciprocal (/ 1 12))))
; (+ (+ 15 2)(g (reciprocal (/ 1 12))))
; (+ 17 (g (reciprocal (/ 1 12))))
; (+ 17 (g (if (= (/ 1 12) 0) #f (/ 1 (/ 1 12)))))
; (+ 17 (g (/ 1 (/ 1 12))))
; (+ 17 (* (/ 1 (/ 1 12)) (reciprocal 4)))
; (+ 17 (* (/ 1 1/12) (reciprocal 4)))
; (+ 17 (* 12 (reciprocal 4)))
; (+ 17 (* 12 (if (= 4 0) #f (/ 1 4))))
; (+ 17 (* 12 (/ 1 4)))
; (+ 17 (* 12 1/4))
; (+ 17 3)
; 20

; 3
; purpose: returns one of the roots to a quadratic function
; input: a, b, c must all be numbers corresponding to the coefficients
; output: a root or false if the discriminant is negative or a is 0
(define (quadratic a b c)
  (define dis (- (* b b) (* 4 a c)))
  (if (or (= a 0) (< dis 0)) #f (/ (+ (- b) (sqrt dis)) (* 2 a)))
)

; 4a
; purpose: returns an estimate for the nth fibonacci number
; input: n must be a positive integer
; output: nth fibonacci approximation
(define s5 (sqrt 5))
(define rs5 (/ 1 s5))
(define (fib n)
  (- (* rs5 (expt (/ (+ 1 s5) 2) n)) (* rs5 (expt (/ (- 1 s5) 2) n)))
)

; 4b
; purpose: returns the nth fibonacci number by means of recusion
; input: n must be a positive integer
; output: nth fibonacci value
(define (fibrec n)
  (cond ((= n 0) 0)
        ((= n 1) 1)
        (else (+ (fibrec (- n 1)) (fibrec (- n 2))))
))

; 4c
; purpose: checks that the fibonacci estimation is within a given range of the actual value
; input: n must be a positive integer, e must be a positive value
; output: true if fib's value (estimated value) is at most e from fibrec (the actual value)
(define (testfib n e)
  (define x (fib n))
  (define y (fibrec n))
  (<= (abs (- x y)) e)
)

; 5a
; The code would never finish execution. It would have to keep evaluating the recursive p procedure.
; This happens because when (test 0 (p)) is called it evaluates test, then 0, then (p), and all the
; procedure p does is call itself.

; 5b
; The code would simply return 0. It works in normal-order evaluation because it never has to evaluate the
; value of y, since the conditional [x = 0] is true. In normal-order the arguments are inserted and evaluated
; when needed rather than applicative-order where it has to evaluate first.

; 6
; The following procedure will either add, subtract or multiply the arguments named `a` and `b`.
; If `b > 0` then return (+ a b), if `b = 0` then return (- a b) which is simply `a`. Else the procedure
; will return (* a b) when `b` is a negative value.


;(define a 5)
;(define b 2)
; a = 5, b = 2
;((cond ((> b 0) +) ((= b 0) -) (else *)) a b)
;((cond (#t +) ((= b 0) -) (else *)) a b)
;(+ a b)

;(define b 0)
; a = 5, b = 0
;((cond ((> b 0) +)((= b 0) -)(else *)) a b)
;((cond (#f +) ((= b 0) -) (else *)) a b)
;((cond (#f +) (#t -) (else *)) a b)
;(- a b)

;(define b -2)
; a = 5, b = -2
;((cond ((> b 0) +)((= b 0) -)(else *)) a b)
;((cond (#f +) ((= b 0) -) (else *)) a b)
;((cond (#f +) (#f -) (else *)) a b)
;(* a b)

; Documentation & Testing

(define (test func n exp)
  (display func)
  (display n)
  (display " =>")(newline)
  (display " Expected: ")(display exp)(newline)
  (display " Actual:   ")(display (func n))(newline)(newline)
)

(define (test3 func a b c exp)
  (display func)
  (display a)
  (display ", ")
  (display b)
  (display ", ")
  (display c)
  (display " =>")(newline)
  (display " Expected: ")(display exp)(newline)
  (display " Actual:   ")(display (func a b c))(newline)(newline)
)

(test reciprocal 3 1/3)
(test reciprocal 1 1)
(test reciprocal -3 -1/3)
(test reciprocal 5 1/5)
(test reciprocal 100 1/100)
(test reciprocal 1/10 10)
(test reciprocal 4/3 3/4)

(test f 3 12)
(test f 1 9)
(test f -3 -15)
(test f 5 1/5)
(test f 100 17)
(test f 1/10 1233/110)
(test f 4/3 64/7)
;(test f -1 64/7)

(test g 3 3/4)
(test g 1 1/4)
(test g -3 -3/4)
(test g 5 5/4)
(test g 100 25)
(test g 1/10 1/40)
(test g 4/3 1/3)
(test g -1 -1/4)

(test3 quadratic 1 2 0 0)
(test3 quadratic 0 2 3 #f)
(test3 quadratic 4 5 9 #f)
(test3 quadratic -3 5 9 -1.08876043)
(test3 quadratic 0.2 -1.4 1 6.192582403)
(test3 quadratic 3 0 -48 4)
(test3 quadratic 1 -8 12 6)
(test3 quadratic 6 2 0.4 #f)

(testfib 40 0.000000001) ;#f
(testfib 15 0) ;#t
(testfib 20 0) ;#f
(testfib 1 0.2) ;#t