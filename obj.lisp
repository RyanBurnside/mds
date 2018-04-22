(in-package :mds)

;; Game Object (God object? sue me!)
(defclass obj ()
  ((pos       :initarg :pos 
	      :initform (vec2 0.0 0.0)
	      :accessor pos)
   (radius    :initarg :radius 
	      :initform 8.0
	      :accessor radius)
   (color     :initarg :color 
	      :initform (vec4 1 1 1 1)
	      :accessor color)
   (heading   :initarg :heading 
	      :initform (vec2 1.0 0.0))
   (dead      :initarg :dead 
	      :initform nil
	      :accessor dead)
   (HP        :initarg :HP 
	      :initform 1)))
