# frozen_string_literal: true

module FfiWideChar
  module LibC
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    # Converts a string of multibyte characters to a wide character array
    # size_t mbstowcs (wchar_t *wstring, const char *string, size_t size)
    attach_function :mbstowcs, [:pointer, :string, :size_t], :size_t
  end
end
