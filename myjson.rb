require 'oj'

# This module implements a lazy JSON reader, which parses the JSON-String
# when a property is being accessed
module MyJSON
  def self.parse(json, position = nil)
    instance = MyJSON::Any.new(json, position)
    case instance.type
    when 'Array'
      MyJSON::Array.new(json, position)
    when 'Hash'
      MyJSON::Hash.new(json, position)
    else
      instance
    end
  end

  class Any
    # json: JSON String
    # position: starting element in the json string (eg '/3/user/login')
    def initialize(json, position = nil)
      @json = json
      @position = position
    end

    # dumps the original json string
    def dump
      execute_within_oj(&:dump)
    end

    def fetch
      execute_within_oj(&:fetch)
    end

    def [](name = nil)
      execute_within_oj do |node|
        node.move(name)
        MyJSON.parse(@json, node.where?).fetch
      end
    end

    def key?(key)
      respond_to_missing?(key)
    end

    def type
      execute_within_oj(&:type).to_s
    end

    private

    def execute_within_oj
      Oj::Doc.open(@json) do |doc|
        doc.move(@position) if @position
        yield(doc)
      end
    end

    def method_missing(method_name, *arguments, &block)
      self[method_name.to_s]
    rescue ArgumentError
      super
    end

    def respond_to_missing?(method_name, _include_private = false)
      execute_within_oj do |node|
        method_name ? !node.type(method_name.to_s).nil? : super
      end
    end
  end

  class Array < Any
    include Enumerable

    def each
      execute_within_oj do |node|
        node.each_child { |child| yield(self[child.where?]) }
      end
    end

    def fetch
      self
    end
  end

  class Hash < Array
    def each
      execute_within_oj do |node|
        node.each_child { |child| yield(child.local_key, self[child.where?]) }
      end
    end
  end
end
