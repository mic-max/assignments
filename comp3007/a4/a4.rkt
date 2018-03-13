; -------------------------------------------------------------------------------------
; Name     : Michael Maxwell
; Student #: 10106277
; -------------------------------------------------------------------------------------

; -------------------------------------------------------------------------------------
;                                      Question 1
; -------------------------------------------------------------------------------------

(define (f n)
  (define (iter a b c)
    (if (> a (* n n)) (+ a b c)
      (iter (+ a b c) a b)))       ; line 4
        (if (> n 1)
          (iter n (- n 1) (- n 2)) ; line 6
          n))
(f 5)

; 1a
; contour diagram at the beginning of line 6
; TODO see contour-diagrams.pdf

; 1b
; contour diagram at the beginning of line 4
; TODO see contour-diagrams.pdf

; -------------------------------------------------------------------------------------
;                                      Question 2
; -------------------------------------------------------------------------------------

(define (outer z)
  (define x 2)
  (define (in1)
    (define z (+ 20 x))
    (in2))              ; line 5
  (define (in2)
    (set! z (* z 10))
    z)
  in1)

(define closure (outer 30))
(closure)

; 2a
; contour diagram at the beginning of line 5
; TODO see contour-diagrams.pdf

; 2b
; what is the output of this code using lexical scoping
; TODO

; 2c
; would this code work using dynamic scope, provide output or explain why not.
; TODO

; -------------------------------------------------------------------------------------
;                                      Question 3
; -------------------------------------------------------------------------------------

; purpose: implements a list using object oriented design
; input: N/A
; output: a list object
(define (make-list)
  ; returns an integer equal to the number of items in the list
  (define (size) 0)

  ; returns the item stored at index i in the list
  (define (get i) 1)

  ; modifies index i in the list to hold item x
  (define (set i x) 2)

  ; adds item x at index i in the list
  (define (add i x) 3)

  ; removes and returns the item at index i from the list
  (define (remove i) 4)

  ; displays the list in the standard scheme form
  (define (print) 5)

  (define (dispatch method)
    (cond ((eq? method 'size) size)
          ((eq? method 'get) get)
          ((eq? method 'set) set)
          ((eq? method 'add) add)
          ((eq? method 'remove) remove)
          ((eq? method 'print) print)
          (else (lambda()
            (display "Unknown Request: ")
            (display method)
            (newline)))))
  dispatch)
; TODO invalid indices should be checked
; return #f for any operation that should return a value but fails

; -------------------------------------------------------------------------------------
;                                Documentation & Testing
; -------------------------------------------------------------------------------------

(define (test-val func val exp)
  (display func)
  (display " =>")(newline)
  (display " Expected: ")(display exp)(newline)
  (display " Actual:   ")(display val)(newline)(newline)
)

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

; -------------------------------------------------------------------------------------
;                                    Question 3 Tests
; -------------------------------------------------------------------------------------

(define L1 (make-list))
(define L2 (make-list))
(display "L1: ")((L1 'print)) ; prints => L1: ()
(display "L2: ")((L2 'print)) ; prints => L2: ()
((L1 'add) 0 'a)
((L1 'add) 1 'b)
((L1 'add) 2 'c)
((L1 'add) 3 'd)
(display "L1: ")((L1 'print))	; prints => L1: (a b c d)
((L2 'add) 0 ((L1 'get) 2))
(display "L2: ")((L2 'print))	; prints => L2: (c)
