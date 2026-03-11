;;;; utf8.lisp
;;;; UTF-8 encoding/decoding implementation

(in-package #:cl-utf8-pure)

;;; Conditions

(define-condition utf8-error (error)
  ((position :initarg :position :reader utf8-error-position))
  (:documentation "Base condition for UTF-8 errors."))

(define-condition invalid-utf8-sequence (utf8-error)
  ((byte :initarg :byte :reader invalid-utf8-sequence-byte))
  (:report (lambda (c s)
             (format s "Invalid UTF-8 byte #x~2,'0X at position ~D"
                     (invalid-utf8-sequence-byte c)
                     (utf8-error-position c)))))

(define-condition invalid-code-point (utf8-error)
  ((code-point :initarg :code-point :reader invalid-code-point-value))
  (:report (lambda (c s)
             (format s "Invalid Unicode code point #x~X at position ~D"
                     (invalid-code-point-value c)
                     (utf8-error-position c)))))

;;; UTF-8 Byte Length Calculation

(defun utf8-char-length (byte)
  "Return the number of bytes in a UTF-8 sequence starting with BYTE.
   Returns NIL if BYTE is not a valid leading byte."
  (declare (type (unsigned-byte 8) byte)
           (optimize (speed 3) (safety 1)))
  (cond
    ((< byte #x80) 1)          ; 0xxxxxxx - ASCII
    ((< byte #xC0) nil)        ; 10xxxxxx - continuation byte (invalid as lead)
    ((< byte #xE0) 2)          ; 110xxxxx
    ((< byte #xF0) 3)          ; 1110xxxx
    ((< byte #xF8) 4)          ; 11110xxx
    (t nil)))                  ; Invalid

(defun utf8-byte-length (string &key (start 0) end)
  "Return the number of bytes needed to encode STRING as UTF-8."
  (declare (type string string)
           (type fixnum start)
           (optimize (speed 3) (safety 1)))
  (let ((end (or end (length string)))
        (count 0))
    (declare (type fixnum end count))
    (loop for i from start below end
          for code = (char-code (char string i))
          do (incf count
                   (cond
                     ((< code #x80) 1)
                     ((< code #x800) 2)
                     ((< code #x10000) 3)
                     (t 4))))
    count))

;;; Character Encoding

(defun encode-char-utf8 (char buffer index)
  "Encode CHAR as UTF-8 bytes into BUFFER starting at INDEX.
   Returns the number of bytes written."
  (declare (type character char)
           (type (simple-array (unsigned-byte 8) (*)) buffer)
           (type fixnum index)
           (optimize (speed 3) (safety 1)))
  (let ((code (char-code char)))
    (declare (type (unsigned-byte 32) code))
    (cond
      ((< code #x80)
       (setf (aref buffer index) code)
       1)
      ((< code #x800)
       (setf (aref buffer index) (logior #xC0 (ash code -6)))
       (setf (aref buffer (1+ index)) (logior #x80 (logand code #x3F)))
       2)
      ((< code #x10000)
       (setf (aref buffer index) (logior #xE0 (ash code -12)))
       (setf (aref buffer (+ index 1)) (logior #x80 (logand (ash code -6) #x3F)))
       (setf (aref buffer (+ index 2)) (logior #x80 (logand code #x3F)))
       3)
      (t
       (setf (aref buffer index) (logior #xF0 (ash code -18)))
       (setf (aref buffer (+ index 1)) (logior #x80 (logand (ash code -12) #x3F)))
       (setf (aref buffer (+ index 2)) (logior #x80 (logand (ash code -6) #x3F)))
       (setf (aref buffer (+ index 3)) (logior #x80 (logand code #x3F)))
       4))))

;;; Character Decoding

(defun decode-utf8-char (buffer index)
  "Decode a UTF-8 character from BUFFER starting at INDEX.
   Returns (VALUES character bytes-consumed)."
  (declare (type (simple-array (unsigned-byte 8) (*)) buffer)
           (type fixnum index)
           (optimize (speed 3) (safety 1)))
  (let* ((b0 (aref buffer index))
         (len (utf8-char-length b0)))
    (declare (type (unsigned-byte 8) b0))
    (unless len
      (error 'invalid-utf8-sequence :byte b0 :position index))
    (let ((code
            (case len
              (1 b0)
              (2 (logior (ash (logand b0 #x1F) 6)
                         (logand (aref buffer (+ index 1)) #x3F)))
              (3 (logior (ash (logand b0 #x0F) 12)
                         (ash (logand (aref buffer (+ index 1)) #x3F) 6)
                         (logand (aref buffer (+ index 2)) #x3F)))
              (4 (logior (ash (logand b0 #x07) 18)
                         (ash (logand (aref buffer (+ index 1)) #x3F) 12)
                         (ash (logand (aref buffer (+ index 2)) #x3F) 6)
                         (logand (aref buffer (+ index 3)) #x3F))))))
      (when (or (> code #x10FFFF)
                (and (>= code #xD800) (<= code #xDFFF)))
        (error 'invalid-code-point :code-point code :position index))
      (values (code-char code) len))))

;;; String to Bytes

(defun string-to-utf8-bytes (string &key (start 0) end)
  "Convert STRING to a byte array containing UTF-8 encoded bytes."
  (declare (type string string)
           (type fixnum start)
           (optimize (speed 3) (safety 1)))
  (let* ((end (or end (length string)))
         (byte-length (utf8-byte-length string :start start :end end))
         (buffer (make-array byte-length :element-type '(unsigned-byte 8)))
         (pos 0))
    (declare (type fixnum end byte-length pos))
    (loop for i from start below end
          for char = (char string i)
          do (incf pos (encode-char-utf8 char buffer pos)))
    buffer))

;;; Bytes to String

(defun utf8-bytes-to-string (bytes &key (start 0) end)
  "Convert UTF-8 encoded BYTES to a string."
  (declare (type (simple-array (unsigned-byte 8) (*)) bytes)
           (type fixnum start)
           (optimize (speed 3) (safety 1)))
  (let* ((end (or end (length bytes)))
         (chars (make-array (- end start) :element-type 'character
                                          :adjustable t
                                          :fill-pointer 0))
         (pos start))
    (declare (type fixnum end pos))
    (loop while (< pos end)
          do (multiple-value-bind (char consumed)
                 (decode-utf8-char bytes pos)
               (vector-push-extend char chars)
               (incf pos consumed)))
    (coerce chars 'simple-string)))

;;; Validation

(defun valid-utf8-p (bytes &key (start 0) end)
  "Return T if BYTES contains valid UTF-8, NIL otherwise."
  (declare (type (simple-array (unsigned-byte 8) (*)) bytes)
           (type fixnum start)
           (optimize (speed 3) (safety 1)))
  (let ((end (or end (length bytes)))
        (pos start))
    (declare (type fixnum end pos))
    (handler-case
        (loop while (< pos end)
              do (let* ((b0 (aref bytes pos))
                        (len (utf8-char-length b0)))
                   (unless len
                     (return-from valid-utf8-p nil))
                   (when (> (+ pos len) end)
                     (return-from valid-utf8-p nil))
                   ;; Check continuation bytes
                   (loop for i from 1 below len
                         for b = (aref bytes (+ pos i))
                         unless (and (>= b #x80) (< b #xC0))
                           do (return-from valid-utf8-p nil))
                   ;; Check for overlong encodings and invalid code points
                   (let ((code
                           (case len
                             (1 b0)
                             (2 (logior (ash (logand b0 #x1F) 6)
                                        (logand (aref bytes (+ pos 1)) #x3F)))
                             (3 (logior (ash (logand b0 #x0F) 12)
                                        (ash (logand (aref bytes (+ pos 1)) #x3F) 6)
                                        (logand (aref bytes (+ pos 2)) #x3F)))
                             (4 (logior (ash (logand b0 #x07) 18)
                                        (ash (logand (aref bytes (+ pos 1)) #x3F) 12)
                                        (ash (logand (aref bytes (+ pos 2)) #x3F) 6)
                                        (logand (aref bytes (+ pos 3)) #x3F))))))
                     ;; Check overlong encoding
                     (when (or (and (= len 2) (< code #x80))
                               (and (= len 3) (< code #x800))
                               (and (= len 4) (< code #x10000)))
                       (return-from valid-utf8-p nil))
                     ;; Check surrogate pairs and out-of-range
                     (when (or (> code #x10FFFF)
                               (and (>= code #xD800) (<= code #xDFFF)))
                       (return-from valid-utf8-p nil)))
                   (incf pos len))
              finally (return t))
      (error () nil))))
