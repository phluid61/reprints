
require 'json'

require_relative 'reprints/configuration'
require_relative 'reprints/repository'
require_relative 'reprints/datatype'
require_relative 'reprints/dataobj'
require_relative 'reprints/field'

class REPrints

  BASEDIR = File.dirname(File.dirname(__FILE__))

  # TODO
  def initialize
    @repos = {}
    Dir["#{BASEDIR}/repository/*"].find_all{|d| File.directory? d }.each do |repodir|
      begin
        repoid = repodir.sub %r(.*/), ''
        repo = Repository.new repoid, repodir
        @repos[repoid] = repo
      rescue Exception => ex
        puts ex, *ex.backtrace
      end
    end
  end

  # returns an array
  def repository_ids
    @repos.keys
  end

  # returns a Repository object
  # raises if no such repo
  def repository repoid
    @repos[repoid] or raise "unknown repository #{repoid.inspect}"
  end
  alias :[] :repository

  module Utils
    def mkdir_p path
      path.split('/').inject do |p, dir|
        dir = "#{p}/#{dir}"
        Dir.mkdir dir, 0700 unless File.directory? dir
        dir
      end
    end
    extend self
  end

end

#vim: set ts=2 sts=2 sw=2 expandtab
