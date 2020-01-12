# frozen_string_literal: true

begin
  require 'simplecov'
rescue LoadError # rubocop:disable all
else
  SimpleCov.start
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ffi_wide_char'

require 'minitest/autorun'
