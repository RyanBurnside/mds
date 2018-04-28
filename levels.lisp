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
  (setf (ready-at *scrape-ticker*) 50)
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
  (setf (ready-at *scrape-ticker*) 70)
  (let ((a (make-emitter (* *width* .20) (* *height* .75)))
	(b (make-emitter (* *width* .80) (* *height* .75)))
	(c (make-emitter (half-width) (* *height* .75))))

    (push-burst a :direction 'player :num-shots 4
		:color *RED* :step 5 :spread (* PI .45)
		:speed 10)
    
    (push-burst b :direction 'player :num-shots 4
		:color *BLUE* :step 5 :spread (* PI .45)
		:speed 10)

    (push-burst c :num-shots 1
		:color *PURPLE*
		:direction 'player
		:step 50
		:speed 1)

    (dotimes (i 100)
      (let ((dir (random TAU)))
	(dotimes (j 4)
	  (push-burst c :direction dir
		      :color (pick *ORANGE* *YELLOW* *BLACK*)
		      :spread (* TAU 6/7)
		      :step 3
		      :num-shots 6
		      :speed 6))))
    
    (vector-push-extend a *enemies*)
    (vector-push-extend b *enemies*)
    (vector-push-extend c *enemies*)))

(defun level-3 ()
  (setf (ready-at *scrape-ticker*) 50)
  (let ((a (make-emitter (* *width* .25) (* *height* .95)))
	(b (make-emitter (* *width* .75) (* *height* .95)))
	(sniper (make-emitter (half-width) (* *height* .80))))

    (dotimes (line-count 100)
      (push-burst a 
		  :direction (random TAU)
		  :spread (* TAU 7/8)
		  :speed 5
		  :num-shots 7
		  :color (pick *BLUE* *TEAL*)
		  :step 6)
      
      (push-burst b
		  :direction (random TAU)
		  :spread (* TAU 7/8)
		  :speed 5
		  :num-shots 7
		  :color (pick *YELLOW* *PURPLE*)
		  :step 6))
    
    (push-burst sniper
		:direction 'player
		:spread 1
		:speed 7
		:num-shots 1
		:color *RED*
		:step 100)
    
    (vector-push-extend sniper *enemies*)
    (vector-push-extend a *enemies*)
    (vector-push-extend b *enemies*)))

(defun setup-level-functions ()
  (setf *level-functions* (make-array 1 :fill-pointer 0 :adjustable t))
  (vector-push-extend #'level-1 *level-functions*)
  (vector-push-extend #'level-2 *level-functions*)
  (vector-push-extend #'level-3 *level-functions*))
