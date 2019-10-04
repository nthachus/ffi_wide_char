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

  # Detect `wchar_t` encoding.
  # @return [String] Name of the wide-string encoding.
  def self.detect_encoding
    return W_CHAR_ENC if W_CHAR_ENC

    ptr = FFI::MemoryPointer.new(:uint8, 6)
    ret = LibC.mbstowcs(ptr, '!@', 3)
    raise InvalidMultibyteCharError if ret.negative?

    enc = ENCODINGS[str = ptr.get_bytes(0, 6)]
    raise UnsupportedWCharEncodingError, str.inspect unless enc

    redefine_const(:W_CHAR_ENC, enc)
    redefine_const(:W_CHAR_SIZE, enc.include?('32') ? 4 : 2)
    redefine_const(:W_CHAR_FUNC, W_CHAR_SIZE == 4 ? :get_int32 : :get_uint16)

    enc
  end

  # Look for a null terminating characters; if found, read up to that null (exclusive)
  # @param ptr [Pointer] A wide-string pointer.
  # @return [String] Decoded wide-string.
  def self.read_wide_string(ptr)
    return nil unless ptr&.respond_to?(:address) && ptr.address.nonzero?

    sz = (ptr.size || 0) - W_CHAR_SIZE
    len = 0
    len += W_CHAR_SIZE while (sz.negative? || len < sz) && ptr.send(W_CHAR_FUNC, len) != 0

    ptr.get_bytes(0, len).force_encoding(W_CHAR_ENC || DEFAULT_ENC)
  end

  # Convert a Ruby string into a C native wide-string.
  # @param str [String] A Ruby string.
  # @return [String] C native wide-string.
  def self.to_wide_string(str)
    str&.encode(W_CHAR_ENC || DEFAULT_ENC)
  end

  def self.redefine_const(name, value)
    send(:remove_const, name) if const_defined?(name)
    const_set name, value
  end

  private_class_method :redefine_const
end
