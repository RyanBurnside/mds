# mds
### Ryan Burnside (Pixel_Outlaw)

Note: This is /not/ a good example of how to write clean code.
This is a rushed mess of spread logic and spaghetti code, don't use as a base for your project...please.

This is my entry for the Lisp Game Jam (Spring 2018)
Special thanks to "borodust" for trivial-gamekit
https://github.com/borodust

Requires Quicklisp and trivial-gamekit

Then unzip the source code to your "~/quicklisp/local-projects/" folder
(ql:quickload :mds)
(mds:run)

*Note* The game is locked to the monitor refresh rate.
Please purchase a 60hz monitor to play the game as intended. :P

How To Play:
Move your player (circle) around and touch enemy bullets with the outside ring.
If the dot inside touches an enemy shot you lose a life.

- W A S D or ARROW KEYS (movement)
- Z or Y (slow ship speed for precision)

There are 3 sloppily made levels. (Feel free to toy with levels.lisp to make more)

## License 
Released under GPL v3


