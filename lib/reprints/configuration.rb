
class Configuration

  def initialize path, name='config'
    raise "illegal configuration name #{name.inspect}" unless name =~ /\A\w+\z/
    @path = path
    @name = name
    @data = nil
  end

  def get key
    @data = _load unless @data
    @data[key]
  end
  alias :[] :get

  def set key, value
    @data[key] = value
  end
  alias :[]= :set

  def each &block
    @data = _load unless @data
    @data.each_pair do |k,v|
      yield k, v
    end
  end

  def save
    # mkdir -p
    @path.split('/').inject do |p, dir|
      dir = "#{p}/#{dir}"
      Dir.mkdir dir, 0700 unless File.directory? dir
      dir
    end

    filename = "#{@path}/#{@name}.json"
    File.write filename, JSON.dump(@data)
  end

  def dup
    cfg = Configuration.new @path, @name
    if @data
      JSON.load(JSON.dump @data).each_pair do |k,v|
        cfg[k] = v
      end
    end
    cfg
  end

private

  def _load
    filename = "#{@path}/#{@name}.json"
    return {} unless File.exist? filename
    JSON.load(File.read filename)
  end

end

#vim: set ts=2 sts=2 sw=2 expandtab
