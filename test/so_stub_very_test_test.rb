require "test_helper"

class TestSoStubVeryTest < Minitest::Test
  include SoStubVeryTest

  def teardown
    SoStubVeryTest.default_host = nil
    SoStubVeryTest.clear_custom_stubs
    Excon.stubs.clear
  end

  def test_can_stub_get
    stub_get "/foo", body: [true]
    assert_equal Excon.stubs, [[{ path: /\A\/foo\Z/, method: :get }, body: [true]]]
  end

  def test_can_stub_post
    stub_post "/foo", body: [true]
    assert_equal Excon.stubs, [[{ path: /\A\/foo\Z/, method: :post }, body: [true]]]
  end

  def test_can_stub_put
    stub_put "/foo", body: [true]
    assert_equal Excon.stubs, [[{ path: /\A\/foo\Z/, method: :put }, body: [true]]]
  end

  def test_can_stub_patch
    stub_patch "/foo", body: [true]
    assert_equal Excon.stubs, [[{ path: /\A\/foo\Z/, method: :patch }, body: [true]]]
  end

  def test_can_stub_delete
    stub_delete "/foo", body: [true]
    assert_equal Excon.stubs, [[{ path: /\A\/foo\Z/, method: :delete }, body: [true]]]
  end

  def test_performs_param_substitution
    stub_get "/foo/:bar", body: [true]
    assert_equal Excon.stubs, [[{ path: Regexp.new('\A/foo/[^\/]+\Z'), method: :get }, body: [true]]]
  end

  def test_can_have_default_host
    SoStubVeryTest.default_host = "example.com"
    stub_get "/foo", body: [true]
    assert_equal Excon.stubs, [[{ path: /\A\/foo\Z/, method: :get, host: "example.com" }, body: [true]]]
  end

  def test_can_set_response_options
    stub_get "/foo", body: [true], status: 201
    assert_equal Excon.stubs, [[{ path: /\A\/foo\Z/, method: :get }, body: [true], status: 201]]
  end

  def test_need_not_pass_body_param
    stub_get "/foo", [true]
    assert_equal Excon.stubs, [[{ path: /\A\/foo\Z/, method: :get }, body: [true]]]
  end

  def test_can_pass_block_as_response
    stub_get "/foo" do
      [true]
    end

    assert_equal Excon.stubs[0][0], { path: /\A\/foo\Z/, method: :get }
    assert_equal Excon.stubs[0][1].call, [true]
  end

  def test_raises_exception_when_given_response_and_block
    assert_raises SoStubVeryTest::AmbiguousResponseError do
      stub_get "/foo", "bar" do
        [true]
      end
    end
  end

  def test_raises_exception_when_given_response_and_block_with_no_path
    assert_raises SoStubVeryTest::AmbiguousResponseError do
      namespace "/foo" do
        stub_get true do
          [true]
        end
      end
    end
  end

  def test_can_use_namespaces
    namespace "/foo" do
      stub_get "/bar", true
    end

    assert_equal Excon.stubs, [[{ path: /\A\/foo\/bar\Z/, method: :get }, { body: true }]]
  end

  def test_can_nest_namespaces
    namespace "/foo" do
      namespace "/bar" do
        stub_get "/baz", true
      end
    end

    assert_equal Excon.stubs, [[{ path: /\A\/foo\/bar\/baz\Z/, method: :get }, { body: true }]]
  end

  def test_can_use_no_path_when_in_namespace
    namespace "/foo" do
      stub_get true
    end

    assert_equal Excon.stubs, [[{ path: /\A\/foo\Z/, method: :get }, { body: true }]]
  end

  def test_raises_no_path_when_not_given_path_outside_of_namespace
    assert_raises SoStubVeryTest::NoPathGivenError do
      stub_get true
    end
  end

  def test_clears_namespaces_each_block
    namespace "/foo" do
    end

    namespace "/bar" do
      stub_get true
    end

    assert_equal Excon.stubs, [[{ path: /\A\/bar\Z/, method: :get }, { body: true }]]
  end

  def test_can_define_more_namespaces
    SoStubVeryTest.register_host :foo, "foo.example.com"
    foo_namespace "/foo" do
      stub_get true
    end
    assert_equal Excon.stubs, [[{ path: /\A\/foo\Z/, host: "foo.example.com", method: :get }, { body: true }]]
  end

  def test_new_namespaces_come_with_http_verb_methods
    SoStubVeryTest.register_host :foo, "foo.example.com"
    foo_stub_get "/foo", true
    assert_equal Excon.stubs, [[{ path: /\A\/foo\Z/, host: "foo.example.com", method: :get }, { body: true }]]
  end

  def test_can_not_mismatch_namespaces
    SoStubVeryTest.register_host :foo, "foo.example.com"

    assert_raises SoStubVeryTest::MixedNamespacesError do
      namespace "/foo" do
        foo_namespace "bar" do
        end
      end
    end
  end

  def test_can_not_mismatch_namespaces_and_http_verb_methods
    SoStubVeryTest.register_host :foo, "foo.example.com"

    assert_raises SoStubVeryTest::MixedNamespacesError do
      namespace "/foo" do
        foo_stub_get true
      end
    end
  end

  def test_unsets_stub_host_after_each_namespace
    SoStubVeryTest.register_host :foo, "foo.example.com"

    foo_namespace "/foo" do
      stub_get true
    end

    stub_get "/bar", true

    assert_equal Excon.stubs[0], [{ path: /\A\/bar\Z/, method: :get }, body: true]
  end

  def test_can_have_default_stubs
    SoStubVeryTest.defaults do
      stub_get "/bar", true
    end

    assert_equal Excon.stubs, [[{ path: /\A\/bar\Z/, method: :get }, body: true]]
  end

  def test_can_clear_stubs
    stub_get "/bar", true
    SoStubVeryTest.clear_custom_stubs
    assert_empty Excon.stubs
  end

  def test_does_not_clear_default_stubs
    SoStubVeryTest.defaults do
      stub_get "/foo", true
    end

    stub_get "/bar", true
    SoStubVeryTest.clear_custom_stubs
    assert_equal Excon.stubs, [[{ path: /\A\/foo\Z/, method: :get }, body: true]]
  end
end
