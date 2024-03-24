# HtmlAttrs

A simple gem to merge HTML attributes in Ruby. It's incredibly useful when you're working with HTML attributes in a Rails app.

For example, you're accepting arguments in a component or partial from somewhere else that you then need to merge smartly (can be tailwind classes, data attributes for stimulus controllers, etc)

## Installation

Install the gem and add to the application's Gemfile by executing:
```shell
$ bundle add html_attrs
```

## Usage

```ruby
html_attrs = {
  class: 'bg-primary-500', data: { controller: 'popover', action: 'click->popover#toggle' }
}

html_attrs = html_attrs.smart_merge(
  class: 'border border-primary-500', data: { controller: 'slideover' }, href: '#'
)

# Will produce:
{
  class: 'bg-primary-500 border border-primary-500',
  data: { controller: 'popover slideover', action: 'click->popover#toggle' },
  href: '#'
}
# Note: #smart_merge returns an HtmlAttrs object which is a subclass of Hash, so you can use it just like a hash.
```

You can use this in helpers that accept HTML attributes as a hash, e.g:
```erb
<%= content_tag(:a, 'Hello', html_attrs) %>

<%# Will produce: %>
<a
  class="bg-primary-500 border border-primary-500"
  data-controller="popover slideover"
  data-action="click->popover#toggle"
  href="#"
>
  Hello
</a>
```


You can also use the `to_s` method to get the string representation of the HTML attributes, if you need to use it in a string context.
```erb
<a <%= html_attrs.to_s %> id='home'>Hello</a>

<%# Will produce: %>
<a
  class="bg-primary-500 border border-primary-500"
  data-controller="popover slideover"
  data-action="click->popover#toggle"
  href="#"
  id='home'
>
  Hello
</a>
```

Merging is done recursively:
 * Strings are merged by concatenating them with a space.
 * Arrays are merged with simple concatenation.
 * Hashes are merged recursively using the above rules.
 * Everything else is merged normally, just like with `Hash#merge`.

Super simple, but super powerful.

If one hash that has a string key and the other has a symbol key or vice-versa, we'll convert everything to whatever the first hash has.

## Configuring mergeable attributes

By default, this gem merges `class`, `style` and `data` attributes recursively. Which should usually be more than enough. You can easily customize this by specifying `mergeable_attributes:` when calling `smart_merge`. e.g:
```ruby
HtmlAttrs.new(class: 'bg-primary-500', id: 'test', aria_label: 'Help')
  .smart_merge(aria_label: 'Another', href: '/test', mergeable_attributes: [:aria_label])
# => { class: 'bg-primary-500', id: 'test', aria_label: 'Help Another', href: '/test' }
```

You can also just set `mergeable_attributes: :all` to merge everything. Or you can just use `smart_merge_all` which merges everything by default.

```ruby
{ class: 'bg-primary-500', id: 'test', aria_label: 'Help' }
  .smart_merge_all(class: 'text-red-500', aria_label: 'Another', href: '/test')
# => { class: 'bg-primary-500 text-red-500', id: 'test', aria_label: 'Help Another', href: '/test' }
```


## Other ways to use
Alternative, you can use the `HtmlAttrs` class directly, e.g:
```ruby
HtmlAttrs.smart_merge(
  { class: 'bg-primary-500', data: { controller: 'popover' } },
  { id: 'test', class: 'border' }
)
# => { class: 'bg-primary-500 border', data: { controller: 'popover' }, id: 'test' }
```

Or, you can also instantiate a new `HtmlAttrs` object and use the `smart_merge` method, e.g:
```ruby
html_attrs = HtmlAttrs.new(class: 'bg-primary-500', data: { controller: 'popover' })
# => { class: 'bg-primary-500', id: 'test', aria_label: 'Help', download: 'test.jpeg' }

html_attrs.smart_merge( id: 'test', class: 'border')
# => { class: 'bg-primary-500 border', data: { controller: 'popover' }, id: 'test' }
```

Under the hood, `HtmlAttrs` is a simple wrapper around `Hash`, so you can use it just like any other hash. The only difference is `#smart_merge`, `#smart_merge_all` and `to_s`.

<br/>

## Interested in a powerful Rails UI library?

I am working on a super-powerful Rails UI library - components as well as templates & patterns.

[Please check this out if you're interested](https://owaiskhan.me/rails-ui-library).
<br/>
<br/>
<br/>

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/owaiswiz/html_attrs.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
