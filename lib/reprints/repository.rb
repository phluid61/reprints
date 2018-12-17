
##
# A Repository is a self-contained collection of data and metadata.
#
# Base configuration is stored as a hash/map in the file 'config.yaml'
# in the base directory of the repository (see #dir)
#
# Configuration must at least include a key "datatypes" whose value is
# an array of identifiers.
#
# Each datatype identifier corresponds with a subdirectory under the
# base directory of the repository.
#
# @see DataType
#
class Repository
  ##
  # Create a new repository.
  #
  # @param id 
  # @param dir the absolute path to the repository
  #
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
  attr_reader :id

  ##
  # Gets a datum of configuration.
  #
  def config key
    @config.get key
  end

  ##
  # Retrieve the list of DataType identifiers configured for this repository.
  #
  def datatype_ids
    @datatypes.keys
  end

  ##
  # Retrieve a DataType by its identifier.
  #
  def datatype type
    type = type.to_s
    @datatypes[type] or raise "unknown data type #{type.inspect}"
  end

  ##
  # Retrieve the absolute path to the data store for a DataType,
  # by its identifier.
  #
  # @return String
  #
  def data_path type
    _path 'data', type
  end

  ##
  # Retrieve the absolute path to the index store for a DataType,
  # by its identifier.
  #
  # @return String
  #
  def index_path type
    _path 'index', type
  end

private

  def _path key, type
    type = type.to_s
    raise "illegal data type #{type.inspect}" unless type =~ /\A\w+\z/

    typedir = "#{@dir}/#{key}/#{type}"
    raise "unknown data type #{type.inspect}" unless File.directory? typedir
    typedir
  end
end

#vim: set ts=2 sts=2 sw=2 expandtab
