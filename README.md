# HtmlAttrs

A simple gem to merge HTML attributes in Ruby. It's incredibly useful when you're working with HTML attributes in a Rails app.

For example, you're accepting arguments in a component or partial from somewhere else that you then need to merge smartly (can be tailwind classes, stimulus attributes, etc)


## Installation

Install the gem and add to the application's Gemfile by executing:
```shell
$ bundle add html_attrs
```

## Usage

```ruby
html_attrs = {
  class: 'bg-primary-500', data: { controller: 'popover', action: 'click->popover#toggle' }
}.as_html_attrs

html_attrs = html_attrs.smart_merge(
  class: 'border border-primary-500', data: { controller: 'slideover' }, href: '#'
)

# You can use this in helpers that accept HTML attributes as a hash, e.g content_tag(:a, 'Hello', html_attrs)
puts html_attrs
# => { class: 'bg-primary-500 border border-primary-500', data: { controller: 'popover slideover', action: 'click->popover#toggle' }, href: '#' }


# You can also use the `to_s` method to get the string representation of the HTML attributes, if you need to use it in a string context.
puts html_attrs.to_s
# => 'class="bg-primary-500 border border-primary-500" data-controller="popover slideover" data-action="click->popover#toggle" href="#"'
# e.g, in an ERB template:
# <a <%= html_attrs.to_s %> id='home'>Hello</a>
# => <a class="bg-primary-500 border border-primary-500" data-controller="popover slideover" data-action="click->popover#toggle" href="#" id='home'>Hello</a>
```

Alternative, you can use the `HtmlAttrs` class directly, e.g:
```ruby
HtmlAttrs.smart_merge({ class: 'bg-primary-500', data: { controller: 'popover' } }, { id: 'test', class: 'border' })
# => { class: 'bg-primary-500 border', data: { controller: 'popover' }, id: 'test' }
```

Or, you can also instantiate a new `HtmlAttrs` object and use the `smart_merge` method, e.g:
```ruby
html_attrs = HtmlAttrs.new(class: 'bg-primary-500', id: 'test', aria_label: 'Help', download: 'test.jpeg')
# => { class: 'bg-primary-500', id: 'test', aria_label: 'Help', download: 'test.jpeg' }
html_attrs.smart_merge(class: 'border', id: 'another', aria_label: 'Another', href: '/test')
# => { class: 'bg-primary-500 border', id: 'another', aria_label: 'Help Another', download: 'test.jpeg', href: '/test' }
```

Merging is done recursively. Strings are merged by concatenating them with a space. Arrays are merged with simple concatenation. Hashes are merged recursively using the above rules.

Very simple, yet very useful - especially if you're dealing with a lot of components/stimulus stuff where you often find yourself merging things manually.

## Advanced Usage

You can also directly use the `smart_merge` method to merge hashes, e.g:

By default, this gem merges `class`, `style` and `data` attributes recursively. Which should usually be more than enough. You can easily customize this by passing an array of attribute names to the smart_merge method, if you need to. e.g:
```ruby
HtmlAttrs.new(class: 'bg-primary-500', id: 'test', aria_label: 'Help', download: 'test.jpeg')
  .smart_merge(class: 'bg-primary-100', id: 'another', aria_label: 'Another', href: '/test', mergeable_attributes: [:aria_label])
# => { class: 'bg-primary-100', id: 'another', aria_label: 'Help Another', download: 'test.jpeg', href: '/test' }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/owaiswiz/html_attrs.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
