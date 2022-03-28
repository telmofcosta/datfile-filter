require 'ox'

class DatFileParser < Ox::Sax
  MACHINE_PATH = %i[mame machine].freeze
  DATA_ATTRS = %i[name cloneof romof].freeze

  attr_reader :data

  def initialize
    super
    @element = nil
    @path = []
    @data = {}
  end

  def depth
    @path.length
  end

  def instruct(target)
    @instruct = true
  end

  # don't know what this is
  def attr(name, str)
  end

  def attr_value(name, value)
    if @element
      if DATA_ATTRS.include?(name)
        @element[name] = value.as_s
      end
    end
  end

  def attrs_done
    @data[@element.name] = @element if @element
    @element = nil
  end

  def start_element(name)
    @path.push(name)
    if @path == MACHINE_PATH
      @element = Element.new
    end
  end

  def end_element(name)
    @path.pop
  end

  private

  Element = Struct.new(:name, :cloneof, :romof, keyword_init: true)
end
