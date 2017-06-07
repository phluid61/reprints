
class DataObj

  def initialize repo, type, id
    @repo = repo
    @type = type
    @id = id

    @fields = Configuration.new path, 'metadata'
  end

  def field name
    @fields[k]
  end

  def load!
    path = path()
    raise "data object #{@type}:#{@id} does not exist" unless File.directory? path
    @fields = Configuration.new path, 'metadata'
    @fields.dup.each do |k,v|
      if cfg = @type[k]
        @fields[k] = Field.from(@repo, @type[k]).set(v)
      else
        $stderr.puts "unrecognised metadata #{k} = #{v.inspect}"
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

end

#vim: set ts=2 sts=2 sw=2 expandtab
