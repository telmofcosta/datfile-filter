require 'ox'

class XmlDebugger < Ox::Sax
  attr_accessor :path

  def initialize
    super
    @path = []
  end

  def indent
    '  ' * path.length
  end

  def instruct(target)
    $stderr.puts "[INSTRUCT]      #{indent}#{target}"
  end

  def end_instruct(target)
    $stderr.puts "[END_INSTRUCT]  #{indent}#{target}"
  end

  # don't know what this is
  def attr(name, str)
    $stderr.puts "[ATTR]          #{indent}#{name}=#{str}"
  end

  def attr_value(name, value)
    $stderr.puts "[ATTR_VALUE]    #{indent}#{name}=#{value.as_s}"
  end

  def attrs_done
    $stderr.puts "[ATTRS_DONE]    #{indent}>"
  end

  # ignoring
  def doctype(str)
    $stderr.puts "[DOCTYPE]       #{indent}#{str}"
  end

  # ignoring
  def comment(str)
    $stderr.puts "[COMMENT]       #{indent}#{str}"
  end

  def cdata(str)
    $stderr.puts "[CDATA]         #{indent}#{str}"
  end

  def text(str)
    $stderr.puts "[TEXT]          #{indent}#{str}"
  end

  def value(value)
    $stderr.puts "[VALUE]         #{indent}#{value.as_s}"
  end

  def start_element(name)
    $stderr.puts "[START_ELEMENT] #{indent}<#{name}"
    path.push(name)
  end

  def end_element(name)
    $stderr.puts "[END_ELEMENT]   #{indent}</#{name}>"
    path.pop
  end

  def error(message, line, column)
    $stderr.puts "[ERROR] error at #{line}:#{column} #{message}"
  end

  def abort(name)
    $stderr.puts "[ABORT] #{name}"
  end
end
