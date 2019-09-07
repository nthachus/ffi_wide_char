# FfiWideChar
A Ruby gem helper for FFI binding libraries to convert from/to C native `wchar_t` wide-string.
It provides 2 methods: `read_wide_string` and `to_wide_string` for converting.

## Installation
Add this line to your application's Gemfile:
```ruby
gem 'ffi_wide_char'
```

And then execute:
```bash
bundle
```

Or install it yourself as:
```bash
gem install ffi_wide_char
```

## Usage
Example of calling native library functions using `wide-string` type:

```ruby
require 'ffi_wide_char'

# Detect wide-string encoding
FfiWideChar.detect_encoding

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
ptr = FFI::MemoryPointer.new(:pointer)
FfiWideChar::LibC.mbstowcs(ptr, '©Ðõ'.encode('filesystem'), 3)

str = FfiWideChar.read_wide_string ptr
puts str.encode('UTF-8')
```

## Development
After checking out the repo, run `bundle install` to install dependencies. Then, run `rake test` to run the tests.
You can also run `irb` with `require 'bundler/setup'` and `require 'ffi_wide_char'` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`,
which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/nthachus/ffi_wide_char.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
