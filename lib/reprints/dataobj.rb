
class DataObj
  def initialize repo, type, id
    @repo = repo
    @type = type
    @id = id

    @fields = Configuration.new path, 'metadata'
  end
  attr_reader :repo
  attr_reader :type
  attr_reader :id

  def field_ids
    @fields.keys
  end

  def field name
    @fields[name]
  end
  alias [] field

  def _data_path id
    raise "illegal data id #{id.inspect}" unless id =~ /\A\w+(\.\w+)*\z/
    path = path()
    "#{path}/data/#{id}"
  end

  def data? id
    File.exist? _data_path(id)
  end

  def read id, &block
    fn = _data_path(id)
    if block_given?
      File.open(fn, 'r', &block)
    else
      File.read(fn)
    end
  end

  def load!
    path = path()
    raise "data object #{@type}:#{@id} does not exist" unless File.directory? path
    @fields = Configuration.new path, 'metadata'
    @fields.dup.each do |k, v|
      if (cfg = @type[k])
        @fields[k] = Field.from(@repo, cfg).set(v)
      else
        warn "unrecognised metadata #{k} = #{v.inspect}"
        @fields[k] = v
      end
    end
    #TODO: required/missing
    self
  end

  def save!
    @fields.save
    self
  end

  def path
    @type.pathto @id
  end

  def inspect
    inner = @fields.each.map do |k, v|
      "#{k}=#{v.value.inspect}"
    end
    "\#<#{self.class.name}:#{@type.id} @id=#{@id.inspect} #{inner.join ' '}>"
  end
end

#vim: set ts=2 sts=2 sw=2 expandtab
