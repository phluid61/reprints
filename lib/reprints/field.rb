
class Field

  def initialize repo, schema
    @repo = repo
    @schema = schema
  end

  def multiple?
    @schema['multiple']
  end

  def set v
    if multiple?
      @value = v.map {|w| single_value w }
    else
      @value = single_value v
    end
    self
  end

  def value
    @value
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
  end

  class Compound < ::Field
    def initialize repo, schema
      raise "metafield:compound schema missing required 'subfields'" unless schema['subfields']
      @subfields = schema['subfields'].map do |sf|
        ::Field.from repo, sf
      end
      super
    end
    def single_value v
      @subfields.zip(v).map do |sf, w|
        sf.set w
      end
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
  end

end

#vim: set ts=2 sts=2 sw=2 expandtab
