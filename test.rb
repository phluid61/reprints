
require_relative 'lib/reprints'

reprints = Reprints.new

repoids = reprints.repository_ids
p repoids

repo = reprints.repository 'test'

p repo['datatypes']

