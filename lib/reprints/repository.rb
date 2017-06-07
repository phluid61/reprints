
class Repository

  def initialize id, dir
    raise "repo #{id} not found at #{dir}" unless File.directory? dir
    @id = id
    @dir = dir

    @config = Configuration.new @dir

    @datatypes = {}
    @config['datatypes'].each do |dtid|
      @datatypes[dtid] = DataType.new self, dtid
    end
  end

  def config key
    @config.get key
  end

  def datatype_ids
    @datatypes.keys
  end
  def datatype type
    type = type.to_s
    @datatypes[type] or raise "unknown data type #{type.inspect}"
  end

  def data_path type
    type = type.to_s
    raise "illegal data type #{type.inspect}" unless type =~ /\A\w+\z/

    typedir = "#{@dir}/data/#{type}"
    raise "unknown data type #{type.inspect}" unless File.directory? typedir
    typedir
  end

end

#vim: set ts=2 sts=2 sw=2 expandtab
