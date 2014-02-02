require "so_stub_very_test/version"
require "excon"

module SoStubVeryTest
  extend self

  class AmbiguousResponseError < StandardError; end
  class MixedNamespacesError   < StandardError; end
  class NoPathGivenError       < StandardError; end

  def namespace(path, host = nil, &block)
    if stub_paths.any? && host && stub_host != host
      raise MixedNamespacesError, "Namespaces can't be mixed (#{stub_host} and #{host == nil ? "nil" : host})"
    end

    stub_paths << path
    self.stub_host = host || default_host
    yield
  ensure
    stub_paths.pop

    if stub_paths.empty?
      self.stub_host = nil
    end
  end

  Excon::HTTP_VERBS.each do |verb|
    define_method "stub_#{verb}" do |path, response = nil, &block|
      validate_path_given(path)

      unless path.is_a? String
        response = path
        path     = ""
      end

      validate_single_response(block, response)

      if block
        response = block
      end

      path = stub_path + path
      path = replace_path_params(path)
      path = create_path_regexp(path)

      request = { method: verb, path: path }

      if stub_host || default_host
        request[:host] = stub_host || default_host
      end

      unless response.is_a?(Proc) || (response.is_a?(Hash) && response.has_key?(:body))
        response = { body: response }
      end

      unless SoStubVeryTest.defining_default_stubs
        SoStubVeryTest.custom_stubs << [request, response]
      end

      Excon.stub(request, response)
    end
  end

  class << self
    attr_accessor :default_host

    def clear_custom_stubs
      custom_stubs.each do |stub|
        Excon.stubs.delete stub
      end

      custom_stubs.clear
    end

    def custom_stubs
      @custom_stubs ||= []
    end

    def defining_default_stubs
      @defining_default_stubs ||= false
    end

    def register_host(name, host)
      define_method "#{name}_namespace" do |path, &block|
        namespace path, host, &block
      end

      Excon::HTTP_VERBS.each do |verb|
        define_method "#{name}_stub_#{verb}" do |path, response = nil|
          namespace path, host do
            send "stub_#{verb}", response
          end
        end
      end
    end

    def defaults(&block)
      @defining_default_stubs = true
      instance_exec &block
    ensure
      @defining_default_stubs = false
    end
  end

  private

  def create_path_regexp(path)
    Regexp.new '\A' + path + '\Z'
  end

  def default_host
    SoStubVeryTest.default_host
  end

  def replace_path_params(path)
    path.gsub /:[^\/]+/, '[^\/]+'
  end

  def stub_host=(host)
    @stub_host = host
  end

  def stub_host
    @stub_host
  end

  def stub_path
    stub_paths.join
  end

  def stub_paths
    @stub_paths ||= []
  end

  def validate_path_given(path)
    if stub_paths.empty? && !path.is_a?(String)
      raise NoPathGivenError, "Must provide a path to stub requests for"
    end
  end

  def validate_single_response(block, response)
    if block && response
      raise AmbiguousResponseError, "Must provide only either a response object or a block"
    end
  end
end
