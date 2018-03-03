; Name     : Michael Maxwell
; Student #: 10106277

; Question 1
; purpose: creates an interval with a start and end (2 element list)
; input: start and end must be numbers, end should be the greater value
; output: 2 element list (start end)
(define (make-interval start end)
  (cons start end))

; purpose: gets the lower bound of an interval
; input: an interval
; output: a number
(define (lower-bound interval)
  (car interval))

; purpose: gets the upper bound of an interval
; input: an interval
; output: a numbers
(define (upper-bound interval)
  (cdr interval))

; purpose: displays the [start, end]
; input: an interval
; output: writes it to the console
(define (display-interval interval)
  (display "[")
  (display (lower-bound interval))
  (display ", ")
  (display (upper-bound interval))
  (display "]"))

; purpose: adds 2 intervals 
; input: x and y are intervals
; output: a new interval: [a+c,b+d]
(define (add-interval x y)
  (let ((a (lower-bound x))
        (b (upper-bound x))
        (c (lower-bound y))
        (d (upper-bound y)))
    (make-interval (+ a c) (+ b d))))
  
; purpose: subtracts 2 intervals
; input: x and y are intervals
; output: a new interval: [a-d,b-c]
(define (subtract-interval x y)
  (let ((a (lower-bound x))
        (b (upper-bound x))
        (c (lower-bound y))
        (d (upper-bound y)))
    (make-interval (- a d) (- b c))))

; purpose: multiplies 2 intervals
; input: x and y are intervals
; output: a new interval: [min(ac,ad,bc,bd), max(ac,ad,bc,bd)]
(define (multiply-interval x y)
  (let ((ac (* (lower-bound x) (lower-bound y)))
        (ad (* (lower-bound x) (upper-bound y)))
        (bc (* (upper-bound x) (lower-bound y)))
        (bd (* (upper-bound x) (upper-bound y))))
    (make-interval (min ac ad bc bd) (max ac ad bc bd))))

; purpose: divides 2 intervals
; input: x and y are intervals
; output: [a,b] * [1/d,1/c] if [c,d] does not contain 0, otherwise error
(define (divide-interval x y)
  (let ((c (lower-bound y))
        (d (upper-bound y)))
    (if (and (< c 0) (> d 0))
      #f
      (multiply-interval x (make-interval (/ 1 d) (/ 1 c))))))

; Question 2
; RESOURCE: https://stackoverflow.com/questions/21769348/use-of-lambda-for-cons-car-cdr-definition-in-sicp
; *******************************************************
(define (special-cons x y)
  (lambda (m) (m x y)))

; 2a
; purpose: custom function to get the first element of a list
; input: a list
; output: the first element
(define (special-car z)
  (z (lambda (p q) p)))

; purpose: custom function to get the list after the first element
; input: a list
; output: the elements [1..n] of that list (not including the car)
(define (special-cdr z)
  (z (lambda (p q) q)))

; 2b
; purpose: generates a triple (3 element list) without using built-in functions
; input: 3 values
; output: a list of the 3 arguments
(define (triple x y z)
  (special-cons x (special-cons y z)))

; purpose: returns the first value of a triple
; input: a triple
; output: the first element
(define (first i)
  (special-car i))

; purpose: returns the second value of a triple
; input: a triple
; output: the second element
(define (second i)
  (special-car (special-cdr i)))

; purpose: returns the third value of a triple
; input: a triple
; output: the third/last element
(define (third i)
  (special-car (special-cdr (special-cdr i))))

; Question 3
; 3a

; purpose: counts how many occurences of x there are in L
; input: a list and a value to count
; output: the number of occurences
(define (count x L)
  (if (null? L)
    0
    (+ (if (eq? (car L) x) 1 0) (count x (cdr L)))))
#|
  (define (help cur L)
    (if (null? L)
      cur
      (help (+ cur (if (eq? (car L) x) 1 0)) (cdr L))))
  (help 0 L))
|#

; 3b
; purpose: returns the most common element in L
; input: a list
; output: a value from the list or #f for an empty list
;         on a tie ****************
(define (mode L) 1)

; 3c
; purpose: returns a list that contains all but the first n items of L
; input: a list and the index to exclude upto
; output: the last |L| - n elements of L
(define (after L n)
  (if (= n 0)
    L
    (after (cdr L) (- n 1))))

; 3d
; purpose: splices the list A into L at index i
; input: a list L, the index to put A, a list A
; output: the resulting list, L[0..i] + A + L[i...]
(define (splice L i A) 1)
; could probably use (after L i)

; 3e
; purpose: splices the list A into L at index i, also removing n elements from L starting at i
; input: a list L, the index to put A, how many elements to delete from L, a list A
; output: the resulting list, L[0..i-n] + A + L[i...]
(define (splice2 L i n A) 1)

; Question 4
; 4a
; purpose: returns the maximum depth of a list
; input: a list, with nested sublists
; output: an integer
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
;(define a (triple 1 2 3))
;(test first a 1)
;(test second a 2)
;(test third a 3)

; 3a
(test2 count 3 '(1 4 3 6 2 3 3 1 4 3 5 7) 4)
(test2 count 'b '(4 b a 3 2 c b 1 b 2 d a) 3)

; 3b
(test mode '(a b a c a d d a b c a b) 'a)
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







#|(define (make-interval start end)
  (define (help cur L)
    (if (> cur end)
        L
        (help (+ cur 1) (cons L cur))))
  (help start '()))|#








