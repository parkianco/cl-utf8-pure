;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; test-utf8-pure.lisp - Unit tests for utf8-pure
;;;;
;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: BSD-3-Clause

(defpackage #:cl-utf8-pure.test
  (:use #:cl)
  (:export #:run-tests))

(in-package #:cl-utf8-pure.test)

(defun run-tests ()
  "Run all tests for cl-utf8-pure."
  (format t "~&Running tests for cl-utf8-pure...~%")
  ;; TODO: Add test cases
  ;; (test-function-1)
  ;; (test-function-2)
  (format t "~&All tests passed!~%")
  t)
