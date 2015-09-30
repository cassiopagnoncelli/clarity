# https://en.wikipedia.org/wiki/Five-point_stencil
# https://en.wikipedia.org/wiki/Finite_difference
# http://www.geometrictools.com/Documentation/FiniteDifferences.pdf
# http://ocw.mit.edu/courses/mechanical-engineering/2-29-numerical-fluid-mechanics-fall-2011/lecture-notes/MIT2_29F11_lect_12.pdf
# http://www.uio.no/studier/emner/matnat/ifi/INF2340/v05/foiler/sim01.pdf

first_derivative <- function(f, x, h) {
  (-f(x+2*h) + 8*f(x+h) - 8*f(x-h) + f(x-2*h)) / (12*h)
}

second_derivative <- function(f, x, h) {
  (-f(x+2*h) + 16*f(x+h) - 30*f(x) + 16*f(x-h) - f(x-2*h)) / (12*h^2)
}

third_derivative <- function(f, x, h) {
  (f(x+2*h) - 2*f(x+h) + 2*f(x-h) - f(x-2*h)) / (12*h^3)
}
