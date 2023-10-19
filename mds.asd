;;;; mds.asd

(asdf:defsystem :mds
  :description "Minimal Danmaku Simulator"
  :author "Pixel_Outlaw"
  :license  "GPLv3"
  :version "0.0.1"
  :serial t
  :depends-on (alexandria trivial-gamekit)
  :components ((:file "package")
	       (:file "color-data")
	       (:file "ticker")
	       (:file "emitter")
	       (:file "obj")
	       (:file "levels")
	       (:file "misc-functions")
               (:file "mds")))
