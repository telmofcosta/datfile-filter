# frozen_string_literal: true

require "ox"

# Initial Ox::Sax xml datfile parser
# After using, data is available on the {data} attribute of the instance
class DatFilePreprocessor < Ox::Sax
  GAME_PATH = %i[datafile game].freeze
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

  ##
  # Events: start
  ##
  def instruct(_target)
    @instruct = true
  end

  # def end_instruct(target)
  #   warn "[EI] #{indent}#{target}"
  #   target_type.set_element
  # end

  def attr_value(name, value)
    return unless @element

    @element[name] = value.as_s if DATA_ATTRS.include?(name)
  end

  def attrs_done
    @data[@element.name] = @element if @element
    @element = nil
  end

  def start_element(name)
    @path.push(name)
    @element = Element.new if @path == GAME_PATH
  end

  def end_element(_name)
    @path.pop
  end

  ##
  # Events: end
  ##

  Element = Struct.new(:name, :cloneof, :romof, keyword_init: true)
end
