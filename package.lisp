;;;; package.lisp
;;;; Package definition for cl-utf8-pure

(defpackage #:cl-utf8-pure
  (:use #:cl)
  (:export
   ;; Encoding/Decoding
   #:string-to-utf8-bytes
   #:utf8-bytes-to-string
   ;; Length calculations
   #:utf8-byte-length
   #:utf8-char-length
   ;; Validation
   #:valid-utf8-p
   ;; Character-level operations
   #:encode-char-utf8
   #:decode-utf8-char
   ;; Conditions
   #:utf8-error
   #:invalid-utf8-sequence
   #:invalid-code-point))
