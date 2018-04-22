;;;; This is a file for odds n ends that don't really fit into a library at the moment

(in-package :mds)

(defparameter TAU (* 2.0 PI))

(defmacro do-burst (((x-var x)
                     (y-var y)
                     (num-shots-var num-shots)
                     (direction-var direction)
                     (speed-var speed)
                     spread) &body body)
  "A macro that iterates through burst directions with user provided symbols"
  (alexandria:with-gensyms (start-angle step-angle i)
    (alexandria:once-only (spread)
      `(let ((,x-var ,x)
	     (,y-var ,y)
	     (,num-shots-var ,num-shots)
	     (,direction-var ,direction)
	     (,speed-var ,speed))
	 (cond
	   ((= ,num-shots-var 1)
	    ,@body)
	   ((>= ,num-shots-var 2)
	    (let ((,start-angle (- ,direction-var (* ,spread .5)))
		  (,step-angle (/ ,spread (1- (float ,num-shots-var)))))
	      (dotimes (,i ,num-shots-var)
		(setf ,num-shots-var ,i) ;Allow per shot number ID
		(setf ,direction-var (+ ,start-angle (* ,step-angle ,i)))
		,@body))))))))

(defmacro do-line ((x-var y-var iter-var x y x2 y2 num-steps) &body body)
  "Move along a line stop at steps to preform body actions"
  (alexandria:with-gensyms (i)
    (alexandria:once-only (x y x2 y2 num-steps)
      `(let ((,x-var 0)
	     (,y-var 0)
	     (,iter-var 0))
	 (dotimes (,i ,num-steps)
	   (setf ,x-var (alexandria:lerp (/ ,i (1- ,num-steps)) ,x ,x2))
	   (setf ,y-var (alexandria:lerp (/ ,i (1- ,num-steps)) ,y ,y2))
	   (setf ,iter-var ,i)
	   ,@body)))))



(defun point-distance (x y x2 y2)
  (sqrt (+ (expt (- x2 x) 2) 
	   (expt (- y2 y) 2))))

(defun point-direction (x y x2 y2)
  (let ((dx (- x2 x))
	(dy (- y2 y)))
    (if (and (= 0 dx) (= 0 dy))
	0.0
	(atan dy dx))))
