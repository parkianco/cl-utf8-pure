;;;; cl-utf8-pure.asd
;;;; UTF-8 encoding/decoding with zero external dependencies

(asdf:defsystem #:cl-utf8-pure
  :description "Pure Common Lisp UTF-8 encoding/decoding library"
  :author "Parkian Company LLC"
  :license "BSD-3-Clause"
  :version "1.0.0"
  :serial t
  :components ((:file "package")
               (:module "src"
                :serial t
                :components ((:file "utf8")))))
