;;; Holy cow this is getting to be a mess here is where we shove the emitters
;;; for each level we will populate the enemies list from the main game each level

(cl:in-package :mds)

;; Level 1 (single emitter 7 arms swirley :) )
(defun level-1 ()
  (let ((a (make-instance 'emitter
			  :parent-x (* *width* .5)
			  :aim-player-func #'direction-to-player
			  :parent-y (* *height* .75)
			  :repeating t)))

    (setf (shot-push-func a) #'shot-adapter-function)

    (dotimes (i 100)
      (let ((percent (/ i 99.0)))
	(push-burst a 
		    :direction (* i percent)
		     :spread (* TAU 6/7) 
		     :speed 4 
		     :num-shots 7
		     :color (if (oddp i) *GREEN* *BLUE*)
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
  (let ((a (make-instance 'emitter 
			  :parent-x  (* *width* .25)
			  :parent-y  (* *height* .75)
			  :repeating t))
	(b (make-instance 'emitter 
			  :parent-x  (* *width* .75)
			  :parent-y  (* *height* .75)
			  :repeating t)))

    (setf (shot-push-func a) #'shot-adapter-function)
    (setf (shot-push-func b) #'shot-adapter-function)

    (dotimes (i 15)
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
  (vector-push-extend #'level-2 *level-functions*))
