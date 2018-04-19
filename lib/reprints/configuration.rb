
require 'yaml'

class Configuration
  def initialize path, name='config'
    raise "illegal configuration name #{name.inspect}" unless name =~ /\A\w+\z/
    @path = path
    @name = name
    @data = nil
  end

  def keys
    @data = _load unless @data
    @data.keys
  end

  def values
    @data = _load unless @data
    @data.values
  end

  def get key
    @data = _load unless @data
    @data[key]
  end
  alias [] get

  def set key, value
    @data = {} unless @data
    @data[key] = value
  end
  alias []= set

  def each &_block
    @data = _load unless @data
    return enum_for(:each) unless block_given?
    @data.each_pair do |k, v|
      yield k, v
    end
  end

  def each_key &_block
    @data = _load unless @data
    return enum_for(:each_key) unless block_given?
    @data.each_key do |k|
      yield k
    end
  end

  def save
    REPrints::Utils.mkdir_p @path
    filename = "#{@path}/#{@name}.yaml"
    File.write filename, YAML.dump(@data)
  end

  def dup
    cfg = Configuration.new @path, @name
    if @data
      YAML.load(YAML.dump @data).each_pair do |k, v|
        cfg[k] = v
      end
    end
    cfg
  end

private

  def _load
    filename = "#{@path}/#{@name}.yaml"
    return {} unless File.exist? filename
    YAML.load(File.read filename)
  end
end

#vim: set ts=2 sts=2 sw=2 expandtab
