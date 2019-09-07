# frozen_string_literal: true

require 'test_helper'

class FfiWideCharTest < Minitest::Test
  i_suck_and_my_tests_are_order_dependent!

  def test_1_has_a_version_number
    refute_nil FfiWideChar::VERSION
  end

  def test_2_detect_wchar_encoding
    # assert_nil FfiWideChar::W_CHAR_ENC

    out = FfiWideChar.detect_encoding

    refute_nil out
    assert_equal out, FfiWideChar::W_CHAR_ENC
  end

  TEST_MSG  = 'a中Я'
  TEST_DATA = {
    'UTF-16LE' => [0x61, 0, 0x2D, 0x4E, 0x2F, 0x04],
    'UTF-16BE' => [0, 0x61, 0x4E, 0x2D, 0x04, 0x2F],
    'UTF-32LE' => [0x61, 0, 0, 0, 0x2D, 0x4E, 0, 0, 0x2F, 0x04, 0, 0],
    'UTF-32BE' => [0, 0, 0, 0x61, 0, 0, 0x4E, 0x2D, 0, 0, 0x04, 0x2F]
  }.freeze

  def test_3_convert_to_wide_string
    out = FfiWideChar.to_wide_string nil
    assert_nil out

    msg = TEST_DATA[FfiWideChar::W_CHAR_ENC]
    refute_nil msg

    out = FfiWideChar.to_wide_string TEST_MSG
    refute_nil out
    assert_equal msg, out.bytes
  end

  def test_4_convert_from_wide_string
    out = FfiWideChar.read_wide_string nil
    assert_nil out

    msg = TEST_DATA[FfiWideChar::W_CHAR_ENC]
    refute_nil msg

    FFI::MemoryPointer.new(:uint8, msg.size + 4) do |ptr|
      ptr.write_array_of_uint8(msg + [0, 0, 0, 0])

      out = FfiWideChar.read_wide_string ptr

      refute_nil out
      assert_equal TEST_MSG, out.encode(TEST_MSG.encoding)
    end
  end
end
