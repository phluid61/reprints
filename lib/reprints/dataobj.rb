
class DataObj
  ##
  # Creates a new DataObj with the given +type+ and +id+.
  #
  # If +lazy+ is given and true, doesn't load any values from
  # the datastore, allowing the construction of a new DataObj.
  #
  def initialize repo, type, id, lazy=false
    @repo = repo
    @type = type
    @id = id

    if lazy
      @fields = Configuration.new path, 'metadata'
    else
      load!
    end
  end
  attr_reader :repo
  attr_reader :type
  attr_reader :id

  ##
  # Retrieve the list of field identifiers.
  #
  def field_ids
    @fields.keys
  end

  ##
  # Retrieve the value of the given field.
  #
  def field name
    @fields[name]
  end
  alias [] field

  # path to file data (i.e. fulltext data)
  def _data_path id
    raise "illegal data id #{id.inspect}" unless id =~ /\A\w+(\.\w+)*\z/
    path = path()
    "#{path}/data/#{id}"
  end

  ##
  # Tests whether there is file data for this DataObj, identified by +id+.
  #
  def data? id
    File.exist? _data_path(id)
  end

  ##
  # Read file data associated with this DataObj, identified by +id+.
  #
  def read id, &block
    fn = _data_path(id)
    if block_given?
      File.open(fn, 'r', &block)
    else
      File.read(fn)
    end
  end

  ##
  # (Re-)load metadata. Mostly used for lazy-loaded data objects.
  #
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
    @type.each_field do |k, cfg|
      next if @fields[k]
      fieldobj = Field.from(@repo, cfg)
      if (dflt = fieldobj.default)
        @fields[k] = fieldobj.tap{|f| f.default! }
      elsif fieldobj.required?
        raise "data object #{@type}:#{@id} missing required field #{k}"
      end
    end
    self
  end

  ##
  # Save this DataObj's metadata to the data store.
  #
  def save!
    @fields.save
    self
  end

  ##
  # Retrieve the absolute path to this DataObj in the data store.
  #
  # @return String
  #
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
