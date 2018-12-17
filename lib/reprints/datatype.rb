require 'yaml'

##
# A DataType describes the fields common to all data objects of
# that type.
#
# Each DataType lives in a subdirectory under the base directory of
# a Repository.  The structure of a DataType is stored in a hash/map
# in the file 'fields.yaml' in the base directory of the DataType.
#
# Each field has at least an identifier (the key in the hash/map) and
# a type (an identifier).
#
# @see Field
#
class DataType
  ##
  # Creates a new DataType object, attached to the +repo+ Repository
  # by the +id+
  #
  def initialize repo, id
    @repo = repo
    @id = id

    @datapath = @repo.data_path id
    @indexpath = @repo.index_path id

    raise "data type #{@id} does not exist" unless File.directory? @datapath
    @fields = Configuration.new @datapath, 'fields'
  end
  attr_reader :repo
  attr_reader :id

  ##
  # Retrives the Field object identified by +key+
  #
  def field key
    @fields.get key
  end
  alias [] field

  ##
  # Iterates over the fields.
  #
  # @yield identifier, schema
  #
  def each_field &block
    @fields.each(&block)
  end

  ##
  # Creates a new lazy DataObj with this DataType and the given +objid+.
  #
  def create objid
    DataObj.new @repo, self, objid, true
  end

  ##
  # Loads an existing DataObj with this DataType and the given +objid+.
  #
  # Raises an exception if there is no such object in the data store.
  #
  def load objid
    DataObj.new @repo, self, objid
  end

  ##
  # Retrieve the list of object ids from the data store.
  #
  def object_ids
    #FIXME
    base = @datapath
    Dir.glob("#{base}/[0-9][0-9]/[0-9][0-9]/[0-9][0-9]/[0-9][0-9]").map do |dir|
      dir[base.length..-1].delete('/').to_i
    end
  end

  ###

  ##
  # The absolute path to this DataType's base directory.
  #
  def datapath
    @datapath.dup
  end

  ##
  # The theoretical absolute path to a DataObj of this DataType with
  # the given +id+.
  #
  def pathto id
    str = '%08d' % id
    str = '0' + str if str.length % 2 == 1
    @datapath + '/' + str.scan(/../).join('/')
  end

  ###

  def reindex! objids=nil
    index = {}
    @fields.each_key do |fieldname|
      index[fieldname] = {}
    end

    objids ||= object_ids
    objids.each do |objid|
      obj = self.load objid
      @fields.each_key do |fieldname|
        field = obj[fieldname]
        field.each_indexvalue do |value|
          index[fieldname][value] ||= []
          index[fieldname][value] << objid
        end
      end
    end

    sorted = {}
    index.each_pair do |fieldname, values|
      sorted[fieldname] = {}
      values.keys.sort.each do |k|
        sorted[fieldname][k] = values[k]
      end
    end

    REPrints::Utils.mkdir_p @indexpath
    sorted.each_pair do |fieldname, values|
      filename = "#{@indexpath}/#{fieldname}.yaml"
      File.write filename, YAML.dump(values)
    end
  end
end

#vim: set ts=2 sts=2 sw=2 expandtab
