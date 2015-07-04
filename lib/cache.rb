class Cache
  def self.fetch(key, &block)
    new(key).fetch(&block)
  end
  def initialize(key)
    @key = key
  end
  def fetch
    if File.exist?(@key)
      File.read(@key)
    else
      write yield
    end
  end

  private
  def write(content)
    File.open @key, 'w' do |f|
      f.write content
    end
    content
  end
end
