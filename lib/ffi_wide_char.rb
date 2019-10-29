# frozen_string_literal: true

require 'ffi'

require 'ffi_wide_char/api'
require 'ffi_wide_char/version'

module FfiWideChar
  class InvalidMultibyteCharError < StandardError; end
  class UnsupportedWCharEncodingError < StandardError; end

  DEFAULT_ENC = 'UTF-16LE'
  ENCODINGS   = {
    "!\x00@\x00\x00\x00" => DEFAULT_ENC,
    "\x00!\x00@\x00\x00" => 'UTF-16BE',
    "!\x00\x00\x00@\x00" => 'UTF-32LE',
    "\x00\x00\x00!\x00\x00" => 'UTF-32BE'
  }.freeze

  W_CHAR_ENC  = nil
  W_CHAR_SIZE = 2
  W_CHAR_FUNC = :get_uint16

  # All methods in this block are static
  class << self
    # Detect `wchar_t` encoding.
    # @return [String] Name of the wide-string encoding.
    def detect_encoding
      return W_CHAR_ENC if W_CHAR_ENC

      ptr = FFI::MemoryPointer.new(:uint8, 6)
      ret = LibC.mbstowcs(ptr, '!@', 3)
      raise InvalidMultibyteCharError unless ret.is_a?(Numeric) && ret >= 0

      enc = ENCODINGS[str = ptr.get_bytes(0, 6)]
      raise UnsupportedWCharEncodingError, str.inspect unless enc

      redefine_consts enc
    end

    # Look for a null terminating characters; if found, read up to that null (exclusive)
    # @param ptr [Pointer] A wide-string pointer.
    # @return [String] Decoded wide-string.
    def read_wide_string(ptr)
      return nil unless ptr && (get_object_attr(ptr, :address) || 0) != 0

      len = get_wide_string_len ptr
      ptr.get_bytes(0, len).force_encoding(W_CHAR_ENC || DEFAULT_ENC)
    end

    # Convert a Ruby string into a C native wide-string.
    # @param str [String] A Ruby string.
    # @return [String] C native wide-string.
    def to_wide_string(str)
      str ? str.encode(W_CHAR_ENC || DEFAULT_ENC) : str
    end

    private

    # @param enc [String]
    # @return [String]
    def redefine_consts(enc)
      [:W_CHAR_ENC, :W_CHAR_SIZE, :W_CHAR_FUNC].each { |name| send :remove_const, name }

      const_set :W_CHAR_ENC, enc
      const_set :W_CHAR_SIZE, enc.include?('32') ? 4 : 2
      const_set :W_CHAR_FUNC, W_CHAR_SIZE == 4 ? :get_int32 : :get_uint16

      enc
    end

    # @param obj [Object]
    # @param name [Symbol]
    # @return [Object]
    def get_object_attr(obj, name)
      obj.respond_to?(name) ? obj.send(name) : nil
    end

    # @param ptr [Pointer]
    # @return [Integer]
    def get_wide_string_len(ptr)
      sz = get_object_attr(ptr, :size)
      sz -= W_CHAR_SIZE if sz

      len = 0
      len += W_CHAR_SIZE while (!sz || len < sz) && ptr.send(W_CHAR_FUNC, len) != 0

      len
    end
  end
end
