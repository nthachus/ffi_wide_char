# encoding: UTF-8
# frozen_string_literal: true

require 'test_helper'

class UnicodeFileTest < Minitest::Test
  module StdIO
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    begin
      # FILE *_wfopen (const wchar_t *filename, const wchar_t *mode)
      attach_function :_wfopen, [:buffer_in, :buffer_in], :pointer
    rescue FFI::NotFoundError # rubocop:disable Lint/HandleExceptions
    end

    # FILE *fopen (const char *filename, const char *mode)
    attach_function :fopen, [:string, :string], :pointer
    # int fclose (FILE *stream)
    attach_function :fclose, [:pointer], :int

    # int fputws (const wchar_t *ws, FILE *stream)
    attach_function :fputws, [:buffer_in, :pointer], :int
    # wchar_t *fgetws (wchar_t *ws, int num, FILE *stream)
    attach_function :fgetws, [:pointer, :int, :pointer], :pointer
  end

  i_suck_and_my_tests_are_order_dependent!

  def test_1_detect_wchar_encoding
    out = FfiWideChar.detect_encoding

    refute_nil out
    assert_equal out, FfiWideChar::W_CHAR_ENC
  end

  TEST_MSG = 'a中Я'

  def test_2_create_unicode_file_data
    require 'tmpdir'
    fn = Dir::Tmpname.create(TEST_MSG) {}

    fp = open_unicode_file fn
    begin
      i = StdIO.fputws FfiWideChar.to_wide_string(TEST_MSG), fp
      assert_operator i, :>=, 0
    ensure
      assert_equal 0, StdIO.fclose(fp)
    end

    assert_operator File.size?(fn), :>, 0
  end

  TEST_STR = '©Ðõ'

  def test_3_convert_to_wide_string
    ptr = FFI::MemoryPointer.new(:uint8, 16)
    i = FfiWideChar::LibC.mbstowcs(ptr, TEST_STR.encode('filesystem'), 3)

    assert_operator i, :>, 0

    str = FfiWideChar.read_wide_string ptr
    assert_equal TEST_STR, str.encode(TEST_STR.encoding)
  end

  private

  # Open Unicode filename
  def open_unicode_file(filename, mode = 'wb')
    fp =
      if StdIO.respond_to?(:_wfopen)
        StdIO._wfopen FfiWideChar.to_wide_string(filename), FfiWideChar.to_wide_string(mode)
      else
        StdIO.fopen filename, mode
      end

    refute_nil fp
    fp
  end
end
