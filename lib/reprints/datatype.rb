
class DataType

  def initialize repo, id
    @repo = repo
    @id = id

    @path = @repo.data_path id

    raise "data type #{@id} does not exist" unless File.directory? @path
    @config = Configuration.new @path
  end

  def config key
    @config.get key
  end
  alias :[] :config

  def create objid
    DataObj.new @repo, self, objid
  end

  def load objid
    obj = DataObj.new @repo, self, objid
    obj.load!
  end

  def path
    @path.dup
  end

  def pathto id
    str = '%08d' % id
    str = '0' + str if str.length % 2 == 1
    @path + '/' + str.scan(/../).join('/')
  end

end

#vim: set ts=2 sts=2 sw=2 expandtab
