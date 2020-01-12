# frozen_string_literal: true

require 'ffi_wide_char/version'
require 'ffi_wide_char/api'

module FfiWideChar
  class Error < StandardError; end

  ENCODINGS = {
    'UTF-16LE' => "!\x00@\x00\x00\x00",
    'UTF-16BE' => "\x00!\x00@\x00\x00",
    'UTF-32LE' => "!\x00\x00\x00@\x00",
    'UTF-32BE' => "\x00\x00\x00!\x00\x00"
  }.freeze

  # All methods in this block are static
  class << self
    # Detect `wchar_t` encoding.
    # @return [String] Encoding name of the wide-string .
    def encoding
      @encoding ||=
        begin
          ptr = FFI::MemoryPointer.new(:char, 12)
          rc  = LibC.mbstowcs(ptr, '!@', 3)
          raise Error, 'Invalid multibyte character' unless rc.is_a?(Integer) && rc >= 0

          str = ptr.get_bytes(0, 6)
          enc = ENCODINGS.key(str)
          raise Error, "Unsupported wide-character encoding #{str.inspect}" unless enc

          enc
        end
    end

    alias detect_encoding encoding

    # Look for a null-terminated characters; if found, read up to that null (exclusive)
    # @param ptr [FFI::Pointer] A wide-string pointer.
    # @return [String] Decoded wide-string.
    def read_wide_string(ptr)
      return nil if !ptr.respond_to?(:null?) || ptr.null?

      @size ||= encoding.include?('32') ? 4 : 2
      @func ||= @size == 4 ? :get_int32 : :get_int16

      len = get_wide_string_len ptr
      ptr.get_bytes(0, len).force_encoding(encoding)
    end

    # Convert a Ruby string into a C native wide-string.
    # @param str [String] A Ruby string.
    # @return [String] C native wide-string.
    def to_wide_string(str)
      str ? str.encode(encoding) : str
    end

    private

    # Detect wide-string length in bytes
    # @param ptr [FFI::Pointer]
    # @return [Integer]
    def get_wide_string_len(ptr)
      sz = ptr.size
      sz -= @size if sz

      len = 0
      len += @size while (!sz || len < sz) && ptr.send(@func, len) != 0

      len
    end
  end
end
