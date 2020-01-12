# encoding: UTF-8
# frozen_string_literal: true

require 'test_helper'
require 'tmpdir'

class UnicodeFileTest < Minitest::Test
  module StdIO
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    # @!scope class
    begin
      # @!method wfopen(filename, mode)
      #   @param filename [String]
      #   @param mode [String] of wchar_t*
      #   @return [FFI::Pointer] of FILE*
      attach_function :wfopen, :_wfopen, [:buffer_in, :buffer_in], :pointer
    rescue FFI::NotFoundError
      # @!method fopen(filename, mode)
      #   @param filename [String]
      #   @param mode [String]
      #   @return [FFI::Pointer] of FILE*
      attach_function :fopen, [:string, :string], :pointer
    end

    # @!method fclose(stream)
    #   @param stream [FFI::Pointer] of FILE*
    #   @return [Integer]
    attach_function :fclose, [:pointer], :int

    # @!method fputws(ws, stream)
    #   @param ws [String] of wchar_t*
    #   @param stream [FFI::Pointer] of FILE*
    #   @return [Integer]
    attach_function :fputws, [:buffer_in, :pointer], :int
  end

  def test_detect_wide_char_encoding
    out = FfiWideChar.detect_encoding

    assert out
    refute_empty out
  end

  TEST_MSG = 'a中Я'

  def test_create_unicode_file_data
    fn = File.join Dir.tmpdir, "#{TEST_MSG}-#{Time.now.to_f}"

    open_unicode_file(fn) do |fp|
      refute fp.null?
      rc = StdIO.fputws FfiWideChar.to_wide_string(TEST_MSG), fp

      assert_operator 0, :<=, rc
    end

    assert_operator 6, :<=, File.size(fn)
  end

  TEST_STR = '©Ðõ'

  def test_convert_to_wide_string
    FFI::MemoryPointer.new(:char, 16) do |ptr|
      rc = FfiWideChar::LibC.mbstowcs(ptr, TEST_STR.encode('filesystem'), 4)

      assert_equal 3, rc
      str = FfiWideChar.read_wide_string ptr

      assert_equal TEST_STR.encode(FfiWideChar.encoding), str
    end
  end

  private

  # Open Unicode filename
  def open_unicode_file(filename, mode = 'wb')
    fp =
      if StdIO.respond_to?(:wfopen)
        StdIO.wfopen FfiWideChar.to_wide_string(filename), FfiWideChar.to_wide_string(mode)
      else
        StdIO.fopen filename, mode
      end

    yield fp
  ensure
    assert_equal 0, StdIO.fclose(fp) if fp
  end
end
