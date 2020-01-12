# FfiWideChar [![Build Status](https://travis-ci.org/nthachus/ffi_wide_char.svg?branch=master)](https://travis-ci.org/nthachus/ffi_wide_char)

A Ruby gem helper for FFI binding libraries to convert from/to C native `wchar_t` wide-string.

It provides 2 methods: `read_wide_string` and `to_wide_string` for converting.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ffi_wide_char'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ffi_wide_char

## Usage

Example of calling native library functions using `wide-string` type:

```ruby
require 'ffi_wide_char'

# Unicode Popup Dialog
module Win
  extend FFI::Library

  ffi_lib 'user32'
  ffi_convention :stdcall

  attach_function :message_box, :MessageBoxW, %i[pointer buffer_in buffer_in int], :int
end

msg = FfiWideChar.to_wide_string('a中Я')
Win.message_box(nil, msg, msg, 0)

# Convert multibyte to wide-string
ptr = FFI::MemoryPointer.new(:char, 16)
FfiWideChar::LibC.mbstowcs(ptr, '©Ðõ'.encode('filesystem'), 4)

str = FfiWideChar.read_wide_string ptr
puts str.encode('UTF-8')
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake` to run the tests.
You can also run `irb -r bundler/setup -r ffi_wide_char` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nthachus/ffi_wide_char.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
