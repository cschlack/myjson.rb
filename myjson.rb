require 'oj'

class MyJSON
  include Enumerable

  # json: JSON String
  # position: starting element in the json string (eg '/3/user/login')
  def initialize(json, position=nil)
    @json = json
    @position = position
  end

  # dumps the original json string
  def dump
    with_json do |node|
      @position ? node.dump(@position) : @json
    end
  end

  def each
    with_json do |node|
      if node.type == Array
        node.each_child { |child| yield(self[child.where?]) }
      elsif node.type == Hash
        node.each_child { |child| yield(child.local_key, self[child.where?]) }
      end
    end
  end

  def method_missing(name = nil)
    with_json do |node|
      begin
        # move to the starting JSON element
        node.move(name.to_s) if name

        if [Array, Hash].include? node.type
          self.class.new(@json, node.where?)
        else
          node.fetch
        end
      rescue ArgumentError
        nil
      end
    end
  end

  def key?(key)
    ! self[key].nil?
  end

  alias_method :[], :method_missing

  private

  def with_json
    Oj::Doc.open(@json) do |doc|
      doc.move(@position) if @position
      yield(doc)
    end
  end
end