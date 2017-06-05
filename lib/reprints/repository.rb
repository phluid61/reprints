
class Repository
  include Configurable

  def new id, dir
    raise "repo #{id} not found at #{dir}" unless File.directory? dir
    @id = id
    @dir = dir

    @config = Configuration.new @dir
  end

  def config key
    @config.get key
  end
  alias :[] :config

  def data_path type
    type = type.to_s
    raise "illegal data type #{type.inspect}" unless type =~ /\A\w+\z/

    typedir = "#{@dir}/#{type}"
    raise "unknown data type #{type.inspect}" unless File.directory? typedir
    typedir
  end

end

#vim: set ts=2 sts=2 sw=2 expandtab
