describe MyJSON do
  it 'creates an instance' do
    expect(MyJSON.new('')).to be_a_kind_of MyJSON
  end

  it 'parses a JSON string' do
    json = MyJSON.new('[{"a":1, "b":2}]')
    expect(json).to be_a_kind_of MyJSON
  end

  it 'accesses properties by name' do
    json = MyJSON.new('{ "id":1000, "owner":{ "id":9999, "login":"superman" }}')

    expect(json.id).to eq 1000
    expect(json.owner.id).to eq 9999
    expect(json.owner.login).to eq 'superman'
  end

  it 'accesses properties by name inside an array' do
    array = MyJSON.new('[{ "owner":{ "login":"jekyll" }}, { "owner":{ "login":"hyde" }}]').to_a

    expect(array.first.owner.login).to eq 'jekyll'
    expect(array.last.owner.login).to eq 'hyde'
  end

  describe '.dump' do
    it 'returns the original string' do
      json_string = '[{"a":1, "b":2}]'
      expect(MyJSON.new(json_string).dump).to be json_string
    end

    it 'returns a substring' do
      json = MyJSON.new('{"a":{"b":2}}')
      expect(json.a.dump).to eq '{"b":2}'
    end
  end

  describe '.key?' do
    it 'finds an existing key' do
      json = MyJSON.new('{ "id":1000, "owner":{ "id":9999, "login":"superman" }}')
      expect(json.key?('owner')).to be true
    end

    it "doesn't find a non-existing key" do
      json = MyJSON.new('{ "id":1000, "owner":{ "id":9999, "login":"superman" }}')
      expect(json.key?('organizations')).to be false
    end
  end

  describe '.to_a' do
    it 'returns an array' do
      array = MyJSON.new('[1, 2, 3, 4]').to_a
      expect(array).to be_a_kind_of Array
      expect(array.size).to eq 4
    end

    it 'returns nil if it is not an array' do
      not_an_array = MyJSON.new('{"a":1, "b":2}').to_a
      expect(not_an_array).to be nil
    end
  end

  describe '.get_value' do
    it 'returns a number' do
      expect(MyJSON.new('1').get_value).to be_a_kind_of Fixnum
    end

    it 'returns a string' do
      expect(MyJSON.new('"string"').get_value).to be_a_kind_of String
    end

    it 'returns an array' do
      expect(MyJSON.new('[]').get_value).to be_a_kind_of Array
    end

    it 'returns true' do
      expect(MyJSON.new('true').get_value).to be true
    end

    it 'returns false' do
      expect(MyJSON.new('false').get_value).to be false
    end

    it 'returns nil' do
      expect(MyJSON.new('null').get_value).to be nil
    end

    it 'returns a MyJSON instance' do
      expect(MyJSON.new('{}').get_value).to be_a_kind_of MyJSON
    end
  end
end