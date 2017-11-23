
require_relative 'lib/reprints'

def dataobj_to_text obj, indent=0
  str = ''
  prefix = '  ' * indent
  obj.field_ids.each do |f|
    str << "#{prefix}#{f} = "
    v = obj[f]
    if v.multiple?
      str << "[\n"
      v.each do |w|
        str << field_to_text(v, w, indent+1)
      end
      str << "#{prefix}]\n"
    else
      str << field_to_text(v, v.value, indent, true)
    end
  end
  str
end

def field_to_text field, value, indent, outdent=false
  str = ''
  prefix = '  ' * indent
  lead = outdent ? '' : prefix
  if field.is_a?(Field::DataObj) || field.is_a?(Field::Compound)
    thing = (field.is_a?(Field::DataObj) ? value : field)
    str << "#{lead}{\n"
    str << dataobj_to_text(thing, indent+1)
    str << "#{prefix}}\n"
  else
    str << "#{lead}#{value}\n"
  end
  str
end

reprints = REPrints.new

repo = reprints.repository 'test'

repo.datatype_ids.each do |dtid|
  repo.datatype(dtid).reindex!
end

t_record = repo.datatype('record')
t_record.object_ids.each do |rid|
  puts "record \##{rid}:"
  record = t_record.load(rid)
  puts dataobj_to_text(record, 1)
  puts '='*10
  record['documents'].each_with_index do |doc, i|
    puts "document #{i}:"
    #doc['files'].each_with_index do |file, j|
    doc['files'].each do |file|
      puts "  file #{i}:"
      fn = file['filename']
      if fn
        puts "  = #{fn}"
        puts '-'*10
        puts file.read(fn)
        puts '-'*10
      else
        puts '  *** file with no filename?'
      end
    end
  end
end

