require './myjson'

describe MyJSON do
  it 'creates an instance' do
    expect(MyJSON.parse('')).to be_a_kind_of MyJSON::Any
  end

  it 'parses a JSON string' do
    json = MyJSON.parse('[{"a":1, "b":2}]')
    expect(json).to be_a_kind_of MyJSON::Any
  end

  it 'accesses properties by name' do
    json = MyJSON.parse('{ "id":1000, "owner":{ "id":9999, "login":"superman" }}')

    expect(json.id).to eq 1000
    expect(json.owner.id).to eq 9999
    expect(json.owner.login).to eq 'superman'
  end

  it 'accesses properties by name inside an array' do
    array = MyJSON.parse('[{ "owner":{ "login":"jekyll" }}, { "owner":{ "login":"hyde" }}]').to_a

    expect(array.first.owner.login).to eq 'jekyll'
    expect(array.last.owner.login).to eq 'hyde'
  end

  describe '.dump' do
    it 'returns the original string' do
      json_string = '[{"a":1,"b":2}]'
      expect(MyJSON.parse(json_string).dump).to eq json_string
    end

    it 'returns a substring' do
      json = MyJSON.parse('{"a":{"b":2}}')
      expect(json.a.dump).to eq '{"b":2}'
    end
  end

  describe '.key?' do
    it 'finds an existing key' do
      json = MyJSON.parse('{ "id":1000, "owner":{ "id":9999, "login":"superman" }}')
      expect(json.key?('owner')).to be true
    end

    it "doesn't find a non-existing key" do
      json = MyJSON.parse('{ "id":1000, "owner":{ "id":9999, "login":"superman" }}')
      expect(json.key?('organizations')).to be false
    end
  end

  describe '.to_a' do
    it 'returns an array' do
      array = MyJSON.parse('[1, 2, 3, 4]').to_a
      expect(array).to be_an_instance_of Array
      expect(array.size).to eq 4
    end
  end

  describe '.fetch' do
    it 'returns an array' do
      expect(MyJSON.parse('[]').fetch).to be_an_instance_of MyJSON::Array
    end

    it 'returns a hash' do
      expect(MyJSON.parse('{}').fetch).to be_an_instance_of MyJSON::Hash
    end
  end

  describe '.get_value' do
    it 'returns a number' do
      expect(MyJSON.parse('[1]').first).to be_an_instance_of Integer
    end

    it 'returns a string' do
      expect(MyJSON.parse('["string"]').first).to be_an_instance_of String
    end

    it 'returns true' do
      expect(MyJSON.parse('[true]').first).to be true
    end

    it 'returns false' do
      expect(MyJSON.parse('[false]').first).to be false
    end

    it 'returns nil' do
      expect(MyJSON.parse('[null]').first).to be nil
    end

    it 'returns a MyJSON instance for an array' do
      expect(MyJSON.parse('[[]]').first).to be_a_kind_of MyJSON::Any
    end

    it 'returns a MyJSON instance for a hash' do
      expect(MyJSON.parse('[{}]').first).to be_a_kind_of MyJSON::Any
    end
  end
end