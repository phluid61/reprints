require 'yaml'

class DataType
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

  def field key
    @fields.get key
  end
  alias [] field

  def each_field &block
    @fields.each(&block)
  end

  def create objid
    DataObj.new @repo, self, objid, true
  end

  def load objid
    DataObj.new @repo, self, objid
  end

  def object_ids
    #FIXME
    base = @datapath
    Dir.glob("#{base}/[0-9][0-9]/[0-9][0-9]/[0-9][0-9]/[0-9][0-9]").map do |dir|
      dir[base.length..-1].delete('/').to_i
    end
  end

  ###

  def datapath
    @datapath.dup
  end

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
