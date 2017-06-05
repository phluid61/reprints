
class DataObj

  def initialize repo, type, id
    @repo = repo
    @type = type
    @id = id

    @metadata = Configuration.new path, 'metadata'
  end

  def load!
    path = path
    raise "data object #{@type}:#{@id} does not exist" unless File.directory? path
    @metadata = Configuration.new path, 'metadata'
    @metadata.dup.each do |k,v|
      if cfg = @type[k]
        @metadata[k] = MetaField.from(@repo, @type[k]).set(v)
      else
        $stderr.puts "unrecognised metadata #{k} = #{v.inspect}"
        @metadata[k] = v
      end
    end
    #TODO: required/missing
    self
  end

  def save!
    @metadata.save
    self
  end

  def path
    @type.pathto @id
  end

end

#vim: set ts=2 sts=2 sw=2 expandtab
