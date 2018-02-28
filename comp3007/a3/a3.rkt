; Name     : Michael Maxwell
; Student #: 10106277

; Question 1
; purpose: 
; input: 
; output: 
(define (make-interval) 5)

; purpose: 
; input: 
; output: 
(define (lower-bound interval) 0)

; purpose: 
; input: 
; output: 
(define (upper-bound interval) 100)

; purpose: 
; input: 
; output: 
(define (display-interval interval) 0)

; purpose: 
; input: 
; output: 
(define (add-interval) 5)

; purpose: 
; input: 
; output: 
(define (subtract-interval) 5)

; purpose: 
; input: 
; output: 
(define (multiply-interval) 5)

; purpose: 
; input: 
; output: 
(define (divide-interval) 5) ; can error when 

; Question 2
(define (special-cons x y)
  (lambda (m) (m x y)))

; 2a
; purpose: 
; input: 
; output: 
(define (special-car) 1)

; purpose: 
; input: 
; output: 
(define (special-cdr) 1)

; 2b
; purpose: 
; input: 
; output: 
(define (triple x y z) 1)

; purpose: 
; input: 
; output: 
(define (first i) 1)

; purpose: 
; input: 
; output: 
(define (second i) 1)

; purpose: 
; input: 
; output: 
(define (third i) 1)

; Question 3
; 3a

; purpose: 
; input: 
; output: 
(define (count x L) 1)

; 3b
; purpose: 
; input: 
; output: 
(define (mode L) 1)

; 3c
; purpose: 
; input: 
; output: 
(define (after L n) 1)

; 3d
; purpose: 
; input: 
; output: 
(define (splice L i A) 1)

; 3e
; purpose: 
; input: 
; output: 
(define (splice2 L i n A) 1)

; Question 4
; 4a
; purpose: 
; input: 
; output: 
(define (height L) 1)

; 4b
; purpose: 
; input: 
; output: 
(define (tree-filter pred L) 1)

; 4c
; purpose: 
; input: 
; output: 
(define (flatten-list L) 1)

; 4d
; purpose: 
; input: 
; output: 
(define (level i A) 1)

; Question 5
(define-syntax stream-cons
  (syntax-rules ()
    ((stream-cons a b)(cons a (delay b)))))

(define (stream-car s)(car s))
(define (stream-cdr s)(force (cdr s)))

; 5a i
; purpose: 
; input: 
; output: 
(define (stream-first n str) 1)

; 5a ii
; purpose: 
; input: 
; output: 
(define (list->stream lis) 1)

; 5a iii
; purpose: 
; input: 
; output: 
(define (stream->list str) 1)

; 5b i
; purpose: 
; input: 
; output: 
; infinite stream of 1's

; 5b ii
; purpose: 
; input: 
; output: 
; infinite stream of all odd integers

; 5b iii
; purpose: 
; input: 
; output: 
; infinite stream of the values of function
; f(n) = f(n-1) + 2f(n-2) + 3f(n-3) (given f(n) = n iff n < 4)

; 5c
; purpose: 
; input: 
; output: 
(define (combine f s1 s2) 1)

; -----------------------
; Documentation & Testing
; -----------------------

(define (test func a exp)
  (display func)
  (display a)
  (display " =>")(newline)
  (display " Expected: ")(display exp)(newline)
  (display " Actual:   ")(display (func a))(newline)(newline)
)

(define (test2 func a b exp)
  (display func)
  (display a)
  (display ", ")
  (display b)
  (display " =>")(newline)
  (display " Expected: ")(display exp)(newline)
  (display " Actual:   ")(display (func a b))(newline)(newline)
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

(define (test4 func a b c d exp)
  (display func)
  (display a)
  (display ", ")
  (display b)
  (display ", ")
  (display c)
  (display ", ")
  (display d)
  (display " =>")(newline)
  (display " Expected: ")(display exp)(newline)
  (display " Actual:   ")(display (func a b c d))(newline)(newline)
)

; 2a
;(test special-car (special-cons 1 2) 1)
;(test special-car (special-cons 1 2) 2)

; 2b
(define a (triple 1 2 3))
(test first a 1)
(test second a 2)
(test third a 3)

; 3a
(test2 count 3 '(1 4 3 6 2 3 3 1 4 3 5 7) 4)
(test2 count 'b '(4 b a 3 2 c b 1 b 2 d a) 3)

; 3b
(test mode '(a b a c a d d a b c a b) a)
(test mode '(2 b a 3 2 c b 1 b 2 d a) 2)

; 3c
(test2 after '(a b c d e f g h) 3 '(d e f g h))
(test2 after '(a b c d e f g h) 0 '(a b c d e f g h))

; 3d
(test3 splice '(1 2 3 4 5) 2 '(a b c) '(1 2 a b c 3 4 5))
(test3 splice '(1 2 3 4 5) 0 '(a b c) '(a b c 1 2 3 4 5))

; 3e
(test4 splice2 '(1 2 3 4 5) 2 1 '(a b c) '(1 2 a b c 4 5))
(test4 splice2 '(1 2 3 4 5) 2 0 '(a b c) '(1 2 a b c 3 4 5))
(test4 splice2 '(1 2 3 4 5) 3 4 '(a b c) '(1 2 3 a b c))

; 4a
(test height 'a 0)
(test height '(a) 1)
(test height '(a (b) c) 2)
(test height '(((((a(((b)))))))) 8)

; 4b
(test2 tree-filter even? '(1 (2 3) ((4 5) (6 7)) (((8 (9))))) '((2) ((4) (6)) (((8 ())))))

; 4c
(test flatten-list '(1 (2 3) ((4 5 6 (7)))(((8 (9))))) '(1 2 3 4 5 6 7 8 9))

; 4d
(test2 level 1 '(1 (2 3 4) 5 (6 (7 8) 9)) '(1 5))
(test2 level 2 '(1 (2 3 4) 5 (6 (7 8) 9)) '(2 3 4 6 9))
(test2 level 3 '(1 (2 3 4) 5 (6 (7 8) 9)) '(7 8))

; 5a
















