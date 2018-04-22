;;;; mds.lisp

(cl:in-package :mds)


(defparameter *width* 480)
(defparameter *height* 640)
(defparameter *lives* 5)
(defparameter *score* 0)
(defparameter *level* 1)
(defparameter *level-functions* 
  (make-array 1 :fill-pointer 0 :adjustable t))
(defparameter *player* nil)

(defun make-player ()
  (setf *player* (make-instance 'obj 
				:hp 3 ;lives in this case
				:dead nil
				:color (vec4 0 0 0 1)
				:radius 4
				:pos (vec2 (* *width* .75) (* *height* .20)))))
			       

(defun make-game-container ()
  (make-array 1 :fill-pointer 0 :adjustable t))

(defparameter *enemy-shots* (make-game-container))
(defparameter *enemies* (make-game-container))

(defun reset-game ()
  (make-player)
  (setup-level-functions)
  (funcall (aref *level-functions* 0))
  (setf *lives* 5)
  (setf *score* 0)
  (setf *level* 1))

(gamekit:defgame example () ()
		 (:viewport-width *width*)
		 (:viewport-height *height*)
		 (:viewport-title "Minimal Danmaku Simulator"))

;;; Lotta naughty stuff is going to go down.
;;; This will be complete slop in the name of Getting Shit Done (TM)
;;; Take your design patterns elsewhere-we got shit to get done

(defun direction-to-player (x y)
  (atan (- y (y (pos *player*)))
	(- x (x (pos *player*)))))

(defmethod move ((obj obj))
  (with-slots (pos heading) obj
      (setf pos (add pos heading))))

(defmethod draw ((obj obj))
  (gamekit:draw-circle (pos obj)
		       (radius obj)
		       :fill-paint (color obj)
		       :stroke-paint *black*
		       :fill-paint (vec4 0 0 0 0)
		       :thickness 2))

(defun circles-collide-p (x y radius x2 y2 radius2)
  ;; Yes I know about the faster way of doing this screw it this is shorter
  (<= (point-distance x y x2 y2)
      (radius radius2)))

(defmethod objects-collide-p ((obj1 obj) (obj2 obj))
  (with-slots (pos1 radius1) obj1
    (with-slots (pos2 radius2) obj2
      (circles-collide-p (x pos1) (y pos1) radius1 (x pos2) (y pos2) radius2))))

(defun enemy-shoot (x y speed direction color)
  (vector-push-extend
   (make-instance 'obj 
		  :pos (vec2 x y)
		  :heading (vec2 (* (cos direction) speed) 
				 (* (sin direction) speed))
		  :color color)
   *enemy-shots*))

(defun draw-hud ()
  (draw-text (format nil "Alive ~a" (length *enemy-shots*))
	     (vec2 0.0 0.0))

  (draw-text (format nil "~a" *score*) (vec2 0.0 (- *height*  18)))
  (draw-text (format nil "~a" *lives*) (vec2 0.0 (- *height*  36)))
  (draw-text (format nil "~a" *level*) (vec2 0.0 (- *height*  54))))

(defun draw-player ()
  (draw-circle (pos *player*) 
	       14
	       :fill-paint (vec4 0 0 0 0)
	       :stroke-paint *BLACK*
	       :thickness 2)
  (draw *player*))

(defun move-player
    ;; We allow both keyboard and mouse (for the heathen)
    ())

(defmethod gamekit:draw ((this example))
  (loop for i across *enemies* do (stepf i))
  (loop for i across *enemy-shots* do (move i))
  (loop for i across *enemy-shots* do (draw i))
  (move-player)
  (draw-player)
  (loop for i across *enemy-shots* do
    (with-slots (pos radius dead) i
	 (setf dead
	       (or (> (- (x pos) radius) *width*)
		   (> (- (y pos) radius) *height*)
		   (< (+ (x pos) radius) 0.0)
		   (< (+ (y pos) radius) 0.0)))))

  (setf *enemy-shots* (delete-if (lambda (a) (dead a)) *enemy-shots*))
  (draw-hud)
)

(reset-game)
(gamekit:start 'example)

