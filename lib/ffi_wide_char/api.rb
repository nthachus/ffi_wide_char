# frozen_string_literal: true

require 'ffi'

module FfiWideChar
  module LibC
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    # @!scope class
    # @!method mbstowcs(dest, src, size)
    #   Converts a string of multibyte characters to a wide character array
    #   @param dest [FFI::Pointer]  of wchar_t*
    #   @param src [String]
    #   @param size [Integer] Max number of :wchar_t characters to write to dest
    #   @return [Integer] Number of :wchar_t written to dest (w/o null-terminated), or -1 if error
    attach_function :mbstowcs, [:pointer, :string, :size_t], :size_t
  end
end
