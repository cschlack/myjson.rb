require 'oj'

class MyJSON
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

  def method_missing(name = nil)
    Oj::Doc.open(@json) do |doc|
      begin
        # move to the starting JSON element
        doc.move(@position) if @position
        doc.move(name.to_s) if name

        if doc.type == Array
          array = []
          doc.each_child { |doc| array << self[doc.where?] }
          array
        elsif doc.type == Hash
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

  # returns an array of values in case the current value is an array
  # returns nil otherwise
  def to_a
     value = self[]
     value.kind_of?(Array) ? value : nil
  end

  alias_method :[], :method_missing
  alias_method :get_value, :method_missing
end