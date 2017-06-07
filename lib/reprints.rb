
require 'json'

require_relative 'reprints/configuration'
require_relative 'reprints/repository'
require_relative 'reprints/datatype'
require_relative 'reprints/dataobj'
require_relative 'reprints/field'

class Reprints

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
        puts ex
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

end

#vim: set ts=2 sts=2 sw=2 expandtab
