;;; Holy cow this is getting to be a mess here is where we shove the emitters
;;; for each level we will populate the enemies list from the main game each level

(cl:in-package :mds)

;TODO (yes it breaks here)
;abstract instance creation into 
;- creation
;- assign shot function
;- pushing into vector

;;; Testing function

;;; TODO define some common patterns that can be pushed into the emitters
;;; This allows for very quick generation

(defun make-emitter (x y)
  ;; Generic function to make a simple version of our emitter
  (make-instance 'emitter 
		 :repeating t
		 :parent-x x
		 :parent-y y
		 :aim-player-func #'direction-to-player
		 :shot-push-func #'shot-adapter-function))

;; Level 1 (single emitter 7 arms swirley :) )
(defun level-1 ()
  (let ((a (make-emitter (half-width) (* *height* .75))))
    (dotimes (i 100)
      (let ((percent (/ i 99.0)))
	(push-burst a 
		    :direction (* i percent)
		     :spread (* TAU 6/7) 
		     :speed 4 
		     :num-shots 7
		     :color (pick *GREEN* *BLUE*)
		     :step 5)))
    
    (dotimes (i 10)
      (push-burst a 
		  :direction 'player
		  :spread TAU
		  :speed 5
		  :num-shots (+ i 10)
		  :color (if (oddp i) *YELLOW* *PURPLE*)
		  :step 3))
    
    (vector-push-extend a *enemies*)))

(defun level-2 ()
    (let ((a (make-emitter (* *width* .20) (* *height* .5)))
	  (b (make-emitter (* *width* .80) (* *height* .5)))
	  (c (make-emitter (half-width) (* *height* .75))))

      (push-burst a :direction 'player :num-shots 4
		  :color *RED* :step 5 :spread (* PI .45)
		  :speed 10)

      (push-burst b :direction 'player :num-shots 4
		  :color *RED* :step 5 :spread (* PI .45)
		  :speed 10)

      (dotimes (i 100)
	(push-burst c :direction (random TAU)
		    :color (pick *YELLOW* *BLACK*)
		    :spread TAU
		    :step 5
		    :num-shots 8
		    :speed 5))

      (vector-push-extend a *enemies*)
      (vector-push-extend b *enemies*)
      (vector-push-extend c *enemies*)))


(defun level-3 ()
  (let ((a (make-emitter (* *width* .25) (* *height* .75)))
	(b (make-emitter (* *width* .75) (* *height* .75))))

    (dotimes (i 10)
      (push-burst a :direction (+ (* pi .5) (* i (* PI .10)))  
		  :spread TAU
		  :speed (lerp 3 7 (/ i 14.0))
		  :num-shots 10
		  :color *RED*
		  :step (lerp 10 2 (round (/ i 14))))
      
      (push-burst b :direction (+ (* pi .5) (* i (* PI -.10)))  
		  :spread TAU
		  :speed (lerp 3 7 (/ i 14.0))
		  :num-shots 10
		  :color *ORANGE*
		  :step (lerp 10 2 (round (/ i 14)))))
    
    (vector-push-extend a *enemies*)
    (vector-push-extend b *enemies*)))

       
(defun setup-level-functions ()
  (setf *level-functions* (make-array 1 :fill-pointer 0 :adjustable t))
  (vector-push-extend #'level-1 *level-functions*)
  (vector-push-extend #'level-2 *level-functions*)
  (vector-push-extend #'level-3 *level-functions*))
