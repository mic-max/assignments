Author: Michael Maxwell
Student #: 101006277

Files:
	a4.rkt
	mci-let.rkt
	readme.txt

Instructions:
	Run using Dr. Racket R5RS custom
        mci-let.rkt changes made on lines 10-36 and 54-59.

Assumptions:
	User enters the correct data type
	Could check for this with an extra `and` and `number?` procedures
	All other assumptions stated in procedure documentation

----- MCI Testing -----

;;; M-Eval input:
(let ((a 3) (b 4)) (+ a b))

;;; M-Eval value:
7

;;; M-Eval input:
(let ((a (+ 1 3)) (b 4)) (- a b))

;;; M-Eval value:
0

;;; M-Eval input:
(let () 1)

;;; M-Eval value:
1