
class Field

  def initialize repo, schema
    @repo = repo
    @schema = schema
  end

  def set_new v
    self.class.new(@repo, @schema).set(v)
  end

  #
  # Does this field have multiple values? (Like an array)
  #
  # @return true|false
  #
  def multiple?
    @schema['multiple']
  end

  #
  # Set this field's value.
  #
  def set v
    if multiple?
      @value = v.map {|w| single_value w }
    else
      @value = single_value v
    end
    self
  end
  alias :value= :set

  #
  # Get this field's value.
  #
  def value
    @value
  end

  #
  # Iterate through each value in this field.
  # Works even if not #multiple?
  #
  def each &block
    return enum_for(:each) unless block_given?
    if multiple?
      @value.each &block
    else
      yield @value
    end
  end
  include Enumerable

  #
  # Get this field's value, suitable for indexing.
  #
  def indexvalue
    if multiple?
      @value.map {|v| single_indexvalue v }
    else
      single_indexvalue @value
    end
  end

  #
  # Iterate through each indexable value in this field.
  # Works even if not #multiple?
  #
  def each_indexvalue &block
    return enum_for(:each_indexvalue) unless block_given?
    if multiple?
      @value.each {|v| yield single_indexvalue(v) }
    else
      yield single_indexvalue(@value)
    end
  end

  #
  # Convert a stored value to its indexable form.
  #
  def single_indexvalue v
    # TODO: allow custom function in config
    v.to_s
  end

  def to_s
    @value.to_s
  end
  def inspect
    "\#<#{self.class.name} #{@value.inspect}>"
  end

  class <<self

    def from repo, schema
      #FIXME
      case (type = schema['type'])
      when 'integer', nil
        Field::Integer.new repo, schema
      when 'string'
        Field::String.new repo, schema
      when 'dataobj'
        Field::DataObj.new repo, schema
      when 'compound'
        Field::Compound.new repo, schema
      when 'set'
        Field::Set.new repo, schema
      else
        raise "unknown metafield type #{type.inspect}"
      end
    end

  end

  class Integer < ::Field
    def single_value v
      v.to_i
    end
  end

  class String < ::Field
    def single_value v
      v.to_s
    end
    def =~ other
      @value =~ other
    end
  end

  class DataObj < ::Field
    def initialize repo, schema
      raise "metafield:dataobj schema missing required 'dataset'" unless schema['dataset']
      @type = DataType.new repo, schema['dataset']
      super
    end
    def single_value v
      @type.load v
    end
    def single_indexvalue v
      v.id
    end
    def to_s
      @value.inspect
    end
  end

  class Compound < ::Field
    def initialize repo, schema
      raise "metafield:compound schema missing required 'subfields'" unless schema['subfields']
      @subfields = schema['subfields'].each_pair.inject({}) do |hash, sf|
        hash[sf[0]] = ::Field.from repo, sf[1]
        hash
      end
      super
    end
    def field_ids
      @subfields.keys
    end
    def subfield fid
      @subfields[fid]
    end
    alias :[] :subfield
    def single_value v
      hash = {}
      v.each_pair do |vkey, vval|
        sf = @subfields[vkey]
        if sf
          hash[vkey] = sf.set(vval)
        else
          $stderr.puts "unrecognised metadata #{vkey} = #{vval.inspect}"
          hash[vkey] = vval
        end
      end
      hash
    end
    def single_indexvalue v
      ary = []
      @subfields.each_pair do |sf_key,field|
        field = field.set_new(v[sf_key])
        if field.multiple?
          sf_idx = '[' + field.indexvalue.join(',') + ']'
        else
          sf_idx = field.indexvalue
        end
        ary << "#{sf_key}=#{sf_idx}"
      end
      ary.join '|'
    end
    def to_s
      @subfields.each.map do |k,v|
        "#{k}=#{v.to_s}"
      end.inspect
    end
    def inspect
      inner = @subfields.each.map do |k,v|
        "#{k}=#{v.inspect}"
      end
      "\#<#{self.class.name} #{inner.join ' '}>"
    end
  end

  class Set < ::Field
    def initialize repo, schema
      raise "metafield:set missing required 'values'" unless schema['values']
      @values = schema['values'].map(&:to_s)
      super
    end
    def single_value v
      v = v.to_s
      raise "item #{v.inspect} not in set #{@values.inspect}" unless @values.include?(v)
      v
    end
    def inspect
      "\#<#{self.class.name} values=#{@values.inspect} #{@value.inspect}>"
    end
  end

end

#vim: set ts=2 sts=2 sw=2 expandtab
