;;; Simply holds some color data shared over the game
;;; I don't want that garbage cluttering up my main file

(cl:in-package :mds)

(defparameter *white*  (vec4 1 1 1 1))
(defparameter *black*  (vec4  0 0 0 1)) 
(defparameter *red*    (vec4 (/ 226 255.0) (/ 27  255.0) (/ 27  255.0) 1))
(defparameter *orange* (vec4 (/ 225 255.0) (/ 135 255.0) (/ 45  255.0) 1))
(defparameter *yellow* (vec4 (/ 226 255.0) (/ 228 255.0) (/ 15  255.0) 1))
(defparameter *green*  (vec4 (/ 53  255.0) (/ 214 255.0) (/ 53  255.0) 1))
(defparameter *teal*   (vec4 (/ 0   255.0) (/ 222 255.0) (/ 236 255.0) 1))
(defparameter *blue*   (vec4 (/ 50  255.0) (/ 116 255.0) (/ 225 255.0) 1))
(defparameter *purple* (vec4 (/ 214 255.0) (/ 88  255.0) (/ 234 255.0) 1))


(defparameter *color-list*
  (list *white* *black* *red* *orange* *yellow* *green* *teal* *blue* *purple*))

(defun rand-color ()
  (nth (random (length *color-list*))
       *color-list*))

