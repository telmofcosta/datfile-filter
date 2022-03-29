# frozen_string_literal: true

require "ox"

# Ox:Sax xml parser debugger
# Useful to understand what events Ox:Sax emits when parsing an XML file
class XmlDebugger < Ox::Sax
  attr_accessor :path

  def initialize
    super
    @path = []
  end

  def indent
    "  " * path.length
  end

  def instruct(target)
    warn "[INSTRUCT]      #{indent}#{target}"
  end

  def end_instruct(target)
    warn "[END_INSTRUCT]  #{indent}#{target}"
  end

  # don't know what this is
  def attr(name, str)
    warn "[ATTR]          #{indent}#{name}=#{str}"
  end

  def attr_value(name, value)
    warn "[ATTR_VALUE]    #{indent}#{name}=#{value.as_s}"
  end

  def attrs_done
    warn "[ATTRS_DONE]    #{indent}>"
  end

  # ignoring
  def doctype(str)
    warn "[DOCTYPE]       #{indent}#{str}"
  end

  # ignoring
  def comment(str)
    warn "[COMMENT]       #{indent}#{str}"
  end

  def cdata(str)
    warn "[CDATA]         #{indent}#{str}"
  end

  def text(str)
    warn "[TEXT]          #{indent}#{str}"
  end

  def value(value)
    warn "[VALUE]         #{indent}#{value.as_s}"
  end

  def start_element(name)
    warn "[START_ELEMENT] #{indent}<#{name}"
    path.push(name)
  end

  def end_element(name)
    warn "[END_ELEMENT]   #{indent}</#{name}>"
    path.pop
  end

  def error(message, line, column)
    warn "[ERROR] error at #{line}:#{column} #{message}"
  end

  def abort(name)
    warn "[ABORT] #{name}"
  end
end
