# SoStubVeryTest

```doge
so stub

            very test

much excon
              wow
```

SoStubVeryTest provides a simpler method for stubbing Excon in your tests, because
typing `Excon.stub({}, {})` over and over again is like taking the first train to
Repetitive Stress Injury town.

Further, it provides an easy way to set up default stubs for your test suite, so
that you can clear out the Excon stubs that were stubbed in your individual test
setup, but still have useful default ones around (they usually return empty arrays
and hashes).

## Installation

Add this line to your application's Gemfile:

    gem 'so_stub_very_test'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install so_stub_very_test

## Usage

### HTTP Verb Stubs

SoStubVeryTest is a module that you include to provide some handy methods for
stubbing Excon requests. Here's a random smattering of examples:

```ruby
stub_get "/foo", [1,2,3]
# Equivalent: Excon.stub({ path: /\A\/foo\Z/, method: :get }, { body: [1,2,3] })
#                     ^ so stubbed

stub_post "/foo", body: [1,2,3], status: 201
# Equivalent: Excon.stub({ path: /\A\/foo\Z/, method: :post }, { body: [1,2,3], status: 201 })
#                                                         ^ very protocol
```

You can use blocks for your response body:

```ruby
stub_get "/foo" do
  {
    body: "no meme here"
  }
end
# Equivalent: Excon.stub({ path: /\A\/foo\Z/, method: :get }, { body: "no meme here" })
```

SoStubVeryTest will naïvely turn path parameters (any group of non-`/` preceded
by a colon) into regex thingies:

```ruby
stub_get "/foo/:bar", [1,2,3]
# Equivalent: Excon.stub({ path: /\A\/foo\/[^\/]+\Z/, method: :get }, { body: [1,2,3] })
#                                          ^ much regular expression
```

### Namespacing

You can namespace things:

```ruby
namespace "/doges" do
  stub_get [] # no path stubs the namespace's path
  stub_post "/wow", [1,2,3]

  namespace "/very" do
    stub_get "/much", {}
  end
end

# Equivalent:
#   Excon.stub({ path: /\A\/doges\Z/, method: :get }, { body: [] })
#   Excon.stub({ path: /\A\/doges\/wow\Z/, method: :post }, { body: [1,2,3] })
#   Excon.stub({ path: /\A\/doges\/very\/much\Z/, method: :get }, { body: {} })
```

### Default Host Setting Upping

You can set a default host:

```ruby
SoStubVeryTest.default_host = "doge.example.com"
stub_get "/foo", [1,2,3]
# Equivalent: Excon.stub({ path: /\A\/foo\Z/, method: :get, host: "doge.example.com" }, { body: [1,2,3] })
```

### Extra Host Setting Upping

```ruby
SoStubVeryTest.register_host :doge, "doge.example.com"

# Use namespaces
doge_namespace "/w00t" do
  stub_get "/cool", [] # the host prefix isn't necessary when in a namespace block
end

# Or don't use namespaces
doge_stub_get "/twinkie", []

# Excon.stub({ path: /\A\/w00t\/cool\Z/, method: :get, host: "doge.example.com"})
# Excon.stub({ path: /\A\/twinkie\Z/, method: :get, host: "doge.example.com"})
```

### Providing Default Stubs

You can provide default stubs that will not be cleared when calling
`SoStubVeryTest.clear_custom_stubs` by creating them in a special `defaults`
block:

```ruby
# Ensures that unless you manually call `Excon.stubs.clear` or override the stub,
# GETing /woot will always be stubbed with a `[]` response.
SoStubVeryTest.defaults do
  namespace "/woot" do
    stub_get []
  end
end
```

### Clearing the Stubs

You can clear any non-default stubs with this cool method:

```ruby
SoStubVeryTest.clear_custom_stubs
# congratulations you have defeated the stubs
```

## Testing with SoStubVeryTest

### For RSpec

In your `spec_helper.rb`, you'll probably want something like this:

```ruby
require "so_stub_very_test"

RSpec.configure do |config|
  config.include SoStubVeryTest

  before :all do
    Excon.defaults[:mock] = true
  end

  after :each do
    SoStubVeryTest.clear_custom_stubs
  end
end
```

Then you can spend less time writing stubs for your specs:

```ruby
before do
  stub_get "/doge", "hi from doge"
end

it "gets the doge" do
  # ...
end
```

### For Minitest

I don't really use Minitest much (lol i know i'm using it in this very repo),
but you'd probs do this:

```ruby
require "so_stub_very_test"

class TestDoges < Minitest::Test
  def setup
    Excon.defaults[:mock] = true
  end

  def teardown
    SoStubVeryTest.clear_custom_stubs
  end

  def test_the_doge
    stub_get "/doge", "hi from doge"
    assert_equal "hi from doge", Excon.get({ path: "/doge" })
  end
end
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/so_stub_very_test/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
