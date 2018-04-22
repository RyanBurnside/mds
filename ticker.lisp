(cl:in-package :mds)

;;TODO MAKE MAKE-COPY METHOD

(defclass ticker ()
  ((value :accessor value :initform 0 :initarg :value)
   (ready-at :accessor ready-at :initform 0 :initarg :ready-at 
	     :documentation "Stop counting upon reaching this value, set to -1 to tick forever"))
  (:documentation "A class that ticks from 0 to ready-at then stops"))

(defun make-ticker (&key ((:value a) 0) ((:ready-at b) 0))
  (make-instance 'ticker :value a :ready-at b))

(defmethod readyp ((ticker ticker))
  (= (value ticker)
     (ready-at ticker)))

(defmethod tickf ((ticker ticker))
  (unless (readyp ticker)
    (incf (value ticker))))

(defmethod resetf ((ticker ticker))
  (setf (value ticker) 0))

(defclass ticker-action (ticker)
  ((on-ready :accessor on-ready  :initform (lambda()())
	     :initarg :on-ready :documentation "Action done on trigger"))
   (:documentation "Calls action on-ready then resets timer to 0"))

(defmethod tickf :after ((ticker-action ticker-action))
  (when (readyp ticker-action)
    (funcall (on-ready ticker-action))
    (resetf ticker-action)))
