
require_relative 'lib/reprints'

reprints = Reprints.new

repoids = reprints.repository_ids
#p repoids

repo = reprints.repository 'test'

#p repo.datatype_ids
t_record = repo.datatype('record')
t_record.object_ids.each do |oid|
  p t_record.load(oid)
end

