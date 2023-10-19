;;;; mds.lisp


;;; Lotta naughty stuff is going to go down.
;;; This will be complete slop in the name of Getting Shit Done (TM)
;;; Take your design patterns elsewhere - we got shit to get done

(cl:in-package :mds)

(defparameter *width* 480)
(defparameter *height* 640)
(defparameter *lives* 5)
(defparameter *score* 0)
(defparameter *high-score* 0)
(defparameter *level* 1)
(defparameter *scrape-ticker* (make-ticker :ready-at 750))
(defparameter *boss-warning-ticker* (make-ticker :ready-at 200))

(defun half-width ()
  (* *width* .5))

(defun half-height ()
  (* *height* .5))

(defparameter *player-field-radius* 29)

(defparameter *level-functions*
  (make-array 1 :fill-pointer 0 :adjustable t))

(defparameter *player* nil)

(defun make-player ()
  (setf *player* (make-instance 'obj
                                :hp 3 ;lives in this case
                                :dead nil
                                :color (vec4 0 0 0 1)
                                :radius .5
                                :pos (vec2 (* *width* .75) (* *height* .20)))))

(defun make-game-container ()
  (make-array 1 :fill-pointer 0 :adjustable t))

(defparameter *enemy-shots* (make-game-container))
(defparameter *enemies* (make-game-container))
(defparameter *sparks* (make-game-container))

(defun reposition-player ()
  (setf (pos *player*)
        (vec2 (* *width* .5) (* *height* .20))))

(defun contain-player ()
  (with-accessors ((x x) (y y))
      (pos *player*)
    (setf x (alexandria:clamp x 1 (1- *width*)))
    (setf y (alexandria:clamp y 1 (1- *height*)))))

(defun advance-level-if-done ()
  (when (readyp *scrape-ticker*)
    (if (< *level* (length *level-functions*))
        (incf *level*)
        (setf *level* 1))
    (setf *enemy-shots* (make-game-container))
    (setf *enemies* (make-game-container))
    (reposition-player)
    (funcall (aref *level-functions* (1- *level*)))
    (resetf *scrape-ticker*)
    (resetf *boss-warning-ticker*)))

(defun reset-game (&optional (level 1))
  (setf *enemy-shots* (make-game-container))
  (setf *enemies* (make-game-container))
  (make-player)
  (reposition-player)
  (setup-level-functions)
  (funcall (aref *level-functions* (1- level)))
  (setf *lives* 5)
  (setf *score* 0)
  (resetf *scrape-ticker*)
  (setf *level* 1))

(gamekit:defgame example () ()
  (:viewport-width *width*)
  (:viewport-height *height*)
  (:viewport-title "Minimal Danmaku Simulator"))

(defvar *key-bag* nil)

(defun update-pos ()
  (let ((move-speed (if (intersection '(:z :y) *key-bag*) 2.0 4.0)))
    (when (intersection '(:left :a) *key-bag*)
      (decf (x (pos *player*)) move-speed))
    (when (intersection '(:right :d) *key-bag*)
      (incf (x (pos *player*)) move-speed))
    (when (intersection '(:up :w) *key-bag*)
      (incf (y (pos *player*)) move-speed))
    (when (intersection '(:down :s) *key-bag*)
      (decf (y (pos *player*)) move-speed))
    (contain-player)))

(defun bind-movement-button (button)
  (gamekit:bind-button button :pressed
                       (lambda ()
                         (push button *key-bag*)))
  (gamekit:bind-button button :released
                       (lambda ()
                         (deletef *key-bag* button))))

(defmethod gamekit:post-initialize ((app example))
  (loop :for key :in '(:z :y :w :s :a :d :left :right :up :down)
        :do (bind-movement-button key))
  (reset-game))

(defun direction-to-player (x y)
  (atan (- (y (pos *player*)) y)
        (- (x (pos *player*)) x)))

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

(defun draw-shot (obj)
  (with-accessors ((pos pos) (radius radius) (color color) (hp hp))
      obj
    (gamekit:draw-circle pos
                         radius
                         :fill-paint color
                         :stroke-paint (if (> hp 0) color *black*)
                         :fill-paint (vec4 0 0 0 0)
                         :thickness 2)))


(defun circles-collide-p (x y radius x2 y2 radius2)
  ;; Yes I know about the faster way of doing this screw it this is shorter
  (<= (point-distance x y x2 y2)
      (+ radius radius2)))

(defmethod objects-collide-p ((obj1 obj) (obj2 obj))
  (with-slots ((pos1 pos) (radius1 radius)) obj1
    (with-slots ((pos2 pos) (radius2 radius)) obj2
      (circles-collide-p (x pos1) (y pos1) radius1 (x pos2) (y pos2) radius2))))

(defun player-collide-bullet ()
  (let ((collided nil))
    (do-vector (s *enemy-shots*)
      (when (objects-collide-p *player* s)
        (setf collided t))
      (when (and (circles-collide-p (x (pos s))
                                    (y (pos s))
                                    (radius s)
                                    (x (pos *player*))
                                    (y (pos *player*))
                                    *player-field-radius*)
                 (> (hp s) 0))
        (incf *score* 300)
        (draw-lightning)
        (tickf *scrape-ticker*)
        (when (> *score* *high-score*)
          (setf *high-score* *score*))
        (setf (hp s) 0)))
    (when collided
      (decf *lives*)
      (setf *enemy-shots* (make-game-container))
      (when (< *lives* 0)
        (reset-game)))))

(defun enemy-shoot (x y speed direction color)
  (vector-push-extend
   (make-instance 'obj
                  :pos (vec2 x y)
                  :heading (vec2 (* (cos direction) speed)
                                 (* (sin direction) speed))
                  :color color)
   *enemy-shots*))

(defun shot-adapter-function (&key x y num-shots direction speed spread (color *BLACK*))
  (when (not (numberp num-shots))
    (return-from shot-adapter-function))
  (do-burst ((x-pos x)
             (y-pos y)
             (n num-shots)
             (dir direction)
             (spd speed)
             spread)
    (enemy-shoot x-pos y-pos spd dir color)))

(defun draw-hud ()
  (draw-text (format nil "Highscore:~a" *high-score*) (vec2 0.0 (- *height*  18)))
  (draw-text (format nil "Score:~a" *score*) (vec2 0.0 (- *height* 36)))
  (draw-text (format nil "Lives:~a" *lives*) (vec2 0.0 (- *height* 54)))
  (draw-text (format nil "Level:~a" *level*) (vec2 0.0 (- *height* 72)))
  (draw-text (format nil "Percent:~a" (round
                                       (* 100.0
                                          (percent-done *scrape-ticker*))))
             (vec2 0.0 (- *height* 90)))
  (do-vector (i *enemies*)
    (let* ((max-width 100.0)
           (width (* max-width (- 1 (percent-done *scrape-ticker*))))
           (half-width (* width .5))
           (y-offset 32)
           (pos (vec2 (parent-x i)
                      (parent-y i))))
      (draw-line (add pos (vec2 (- half-width) y-offset))
                 (add pos (vec2 half-width y-offset))
                 *RED*
                 :thickness 6))))

(defun lightning-point ()
  (mult (normalize (vec2 (* (expt -1.0 (random 2)) (random 1.0))
                         (* (expt -1.0 (random 2)) (random 1.0))))
        (float *player-field-radius*)))

(defun draw-lightning (&optional (color *BLACK*))
  (do-vector (i *enemies*)
    (draw-curve (pos *player*)
                (vec2 (parent-x i) (parent-y i))
                (subt (pos *player*) (lightning-point))
                (subt (pos *player*) (lightning-point))
                color
                :thickness 4)))

(defun draw-player ()
  (draw-circle (pos *player*)
               *player-field-radius*
               :fill-paint (vec4 0 0 0 0)
               :stroke-paint *BLACK*
               :thickness 2)
  (draw *player*))

(defun draw-emitters ()
  (do-vector (i *enemies*)
    (draw-circle (vec2 (parent-x i)
                       (parent-y i))
                 24
                 :thickness 3
                 :fill-paint *WHITE*
                 :stroke-paint *RED*)))

(defmethod gamekit:act ((this example))
  (update-pos))

(defmethod gamekit:draw ((this example))
  (cond ((readyp *boss-warning-ticker*)
         (do-vector (i *enemies*) (stepf i))
         (do-vector (i *enemy-shots*) (move i))
         (do-vector (i *enemy-shots*) (draw-shot i))
         (draw-emitters)
         (player-collide-bullet)
         (draw-player)

         (do-vector (i *enemy-shots*)
           (with-slots (pos radius dead) i
             (setf dead
                   (or (> (- (x pos) radius) *width*)
                       (> (- (y pos) radius) *height*)
                       (< (+ (x pos) radius) 0.0)
                       (< (+ (y pos) radius) 0.0)))))

         (setf *enemy-shots* (delete-if (lambda (a) (dead a)) *enemy-shots*))
         (advance-level-if-done))
        (t
         (dotimes (i 4)
           (draw-text "W A R N I N G !!!"
                      (vec2 (* *width* .35)
                            (- (* *height* .75) (* i 24)))
                      :fill-color (nth i `(,*BLACK*
                                           ,*RED*
                                           ,*ORANGE*
                                           ,*YELLOW*))))

         (tickf *boss-warning-ticker*)))
  (draw-hud))

(defun run ()
  (gamekit:start 'example))
