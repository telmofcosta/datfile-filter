# frozen_string_literal: true

require "ox"

# Initial Ox::Sax xml machines parser
# After using, data is available on the {data} attribute of the instance
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

  def instruct(_target)
    @instruct = true
  end

  # don't know what this is
  def attr(name, str); end

  def attr_value(name, value)
    return unless @element

    @element[name] = value.as_s if DATA_ATTRS.include?(name)
    $stderr.print("\r#{value.as_s[0]}") if name == :name
  end

  def attrs_done
    @data[@element.name] = @element if @element
    @element = nil
  end

  def start_element(name)
    @path.push(name)
    @element = Element.new if @path == MACHINE_PATH
  end

  def end_element(_name)
    @path.pop
  end

  Element = Struct.new(:name, :cloneof, :romof, keyword_init: true)
end
