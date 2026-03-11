# cl-utf8-pure

Pure Common Lisp UTF-8 encoding/decoding library with zero external dependencies.

## Installation

```lisp
(asdf:load-system :cl-utf8-pure)
```

## Usage

```lisp
(use-package :cl-utf8-pure)

;; String to bytes
(string-to-utf8-bytes "Hello, World!")
;; => #(72 101 108 108 111 44 32 87 111 114 108 100 33)

;; Bytes to string
(utf8-bytes-to-string #(72 101 108 108 111))
;; => "Hello"

;; Calculate byte length
(utf8-byte-length "Hello")  ; => 5

;; Validate UTF-8
(valid-utf8-p #(72 101 108 108 111))  ; => T

;; Character-level operations
(encode-char-utf8 #\a buffer 0)  ; Returns bytes written
(decode-utf8-char buffer 0)      ; Returns (VALUES char bytes-consumed)
```

## API

- `string-to-utf8-bytes` - Convert string to UTF-8 byte array
- `utf8-bytes-to-string` - Convert UTF-8 bytes to string
- `utf8-byte-length` - Calculate UTF-8 byte length of string
- `valid-utf8-p` - Check if byte array is valid UTF-8
- `utf8-char-length` - Get byte count for UTF-8 sequence from leading byte
- `encode-char-utf8` - Encode single character to buffer
- `decode-utf8-char` - Decode single character from buffer

## License

BSD-3-Clause. Copyright (c) 2024-2026 Parkian Company LLC.
