;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

(in-package #:cl-utf8-pure)

;;; Core types for cl-utf8-pure
(deftype cl-utf8-pure-id () '(unsigned-byte 64))
(deftype cl-utf8-pure-status () '(member :ready :active :error :shutdown))
