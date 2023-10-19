(cl:in-package :mds)

(defclass emitter (ticker)
  ((parent-x :accessor parent-x
             :initarg :parent-x
             :initform 0)

   (parent-y :accessor parent-y
             :initarg :parent-y
             :initform 0)

   (action-map :accessor action-map
               :initarg :action-map
               :initform (make-hash-table :test #'equalp)
               :documentation "A hash with int keys, burst shot parameters mapped to key")

   (shot-push-func :accessor shot-push-func
                   :initarg :shot-push-func
                   :initform (constantly nil)
                   :documentation "Function to push x y speed direction spread into for a new shot to be created")

   (aim-player-func :accessor aim-player-func
                    :initarg :aim-player-func
                    :initform (constantly (* PI .5))
                    :allocation :class
                    :documentation "Function to pass the emitter's x and y, and get the player's direction for aiming")

   (offset-x :accessor offset-x :initarg :offset-x :initform 0
             :documentation "Mounted position relative to enemy object")

   (offset-y :accessor offset-y :initarg :offset-y :initform 0
             :documentation "Mounted position relative to enemy object")

   (repeating :accessor repeating :initarg :repeating :initform nil
              :documentation "Reset timer upon having no actions left to take")))


(defmethod get-largest-key ((emitter emitter))
  "Returns 0 if no key exists else returns largest key"
  (let ((val (loop :for key :being :the :hash-keys :of (action-map emitter)
                   :maximize key)))
    ;; sbcl will use 0 for empty list clisp uses NIL
    (if val val 0)))

(defmethod push-burst ((emitter emitter)
                       &key (step 0)
                         (relative t)
                         num-shots
                         speed
                         spread
                         (direction (* PI .5))
                         color)
  "Inserts a burst parameter list into an emitter,
aim may be a direction or 'player to call the assigned player targeting
function. Step is the current index which is inserted by adding on to the last
index if relative is t otherwise it uses the value of step and clobbers any
previous data held at index step"
  (let* ((largest (get-largest-key emitter))
         (index (if relative
                    (+ largest step)
                    step)))
    (setf (gethash index (action-map emitter))
          (list :num-shots num-shots
                :spread spread
                :speed speed
                :color color
                :direction direction))
    (setf (ready-at emitter) (get-largest-key emitter))))

(defmethod stepf ((emitter emitter))
  (with-accessors ((value value)
                   (action-map action-map)
                   (parent-x parent-x)
                   (parent-y parent-y)
                   (offset-x offset-x)
                   (offset-y offset-y)
                   (ready-at ready-at)
                   (shot-push-func shot-push-func)
                   (aim-player-func aim-player-func)
                   (repeating repeating))
      emitter

    ;; If the tick value matches a key call the bound burst function with plist
    (when (gethash value action-map)
      (let* ((h (gethash value action-map))
             (final-direction (if (numberp (getf h :direction))
                                  (getf h :direction)
                                  (funcall aim-player-func
                                           (+ parent-x offset-x)
                                           (+ parent-y offset-y)))))

        (funcall shot-push-func
                 :x (+ parent-x offset-x)
                 :y (+ parent-y offset-y)
                 :direction final-direction
                 :speed (getf h :speed)
                 :spread (getf h :spread)
                 :num-shots (getf h :num-shots)
                 :color (getf h :color))))

    ;; Now see if the tick count needs to reset
    (when (= ready-at value)
      (if repeating
          (resetf emitter)
          (setf ready-at -1)))

    (tickf emitter)))
