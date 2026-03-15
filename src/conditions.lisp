;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

(in-package #:cl-utf8-pure)

(define-condition cl-utf8-pure-error (error)
  ((message :initarg :message :reader cl-utf8-pure-error-message))
  (:report (lambda (condition stream)
             (format stream "cl-utf8-pure error: ~A" (cl-utf8-pure-error-message condition)))))
