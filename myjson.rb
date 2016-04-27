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
    if @position
      Oj::Doc.open(@json) { |doc| doc.dump(@position) }
    else
      @json
    end
  end

  def each
    Oj::Doc.open(@json) do |doc|
      doc.move(@position) if @position
      if doc.type == Array
        doc.each_child { |child| yield(self[child.where?]) }
      elsif doc.type == Hash
        doc.each_child { |child| yield(child.local_key, self[child.where?]) }
      end
    end
  end

  def method_missing(name = nil)
    Oj::Doc.open(@json) do |doc|
      begin
        # move to the starting JSON element
        doc.move(@position) if @position
        doc.move(name.to_s) if name

        if [Array, Hash].include? doc.type
          self.class.new(@json, doc.where?)
        else
          doc.fetch
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
  alias_method :get_value, :method_missing
end