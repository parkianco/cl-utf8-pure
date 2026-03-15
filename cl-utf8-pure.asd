;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; cl-utf8-pure.asd
;;;; UTF-8 encoding/decoding with zero external dependencies

(asdf:defsystem #:cl-utf8-pure
  :description "Pure Common Lisp UTF-8 encoding/decoding library"
  :author "Park Ian Co"
  :license "Apache-2.0"
  :version "0.1.0"
  :serial t
  :components ((:file "package")
               (:module "src"
                :serial t
                :components ((:file "utf8")))))

(asdf:defsystem #:cl-utf8-pure/test
  :description "Tests for cl-utf8-pure"
  :depends-on (#:cl-utf8-pure)
  :serial t
  :components ((:module "test"
                :components ((:file "test-utf8-pure"))))
  :perform (asdf:test-op (o c)
             (let ((result (uiop:symbol-call :cl-utf8-pure.test :run-tests)))
               (unless result
                 (error "Tests failed")))))
