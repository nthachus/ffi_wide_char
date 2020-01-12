# encoding: UTF-8
# frozen_string_literal: true

require 'test_helper'

class FfiWideCharTest < Minitest::Test
  def test_it_has_a_version_number
    assert FfiWideChar::VERSION
  end

  def test_detect_wide_char_encoding
    out = FfiWideChar.detect_encoding

    assert out
    refute_empty out
  end

  TEST_MSG  = 'a中Я'
  TEST_DATA = {
    'UTF-16LE' => [0x61, 0, 0x2D, 0x4E, 0x2F, 0x04],
    'UTF-16BE' => [0, 0x61, 0x4E, 0x2D, 0x04, 0x2F],
    'UTF-32LE' => [0x61, 0, 0, 0, 0x2D, 0x4E, 0, 0, 0x2F, 0x04, 0, 0],
    'UTF-32BE' => [0, 0, 0, 0x61, 0, 0, 0x4E, 0x2D, 0, 0, 0x04, 0x2F]
  }.freeze

  def test_convert_to_wide_string
    out = FfiWideChar.to_wide_string nil
    assert_nil out

    msg = TEST_DATA[FfiWideChar.encoding]
    assert msg

    out = FfiWideChar.to_wide_string TEST_MSG
    assert out
    assert_equal msg, out.each_byte.to_a
  end

  def test_convert_from_wide_string
    out = FfiWideChar.read_wide_string nil
    assert_nil out

    msg = TEST_DATA[FfiWideChar.encoding]
    assert msg

    FFI::MemoryPointer.new(:int8, msg.size + 4) do |ptr|
      ptr.put_array_of_int8(0, msg + [0, 0, 0, 0])

      out = FfiWideChar.read_wide_string ptr
      assert_equal TEST_MSG.encode(FfiWideChar.encoding), out
    end
  end
end
