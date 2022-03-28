require 'ox'

class DatFileProxy < Ox::Sax
  attr_accessor :path, :target_type

  def initialize
    super
    @path = []
    @target_type = Target.new
  end

  def indent
    '  ' * depth
  end

  def element_context
    path.last
  end

  def depth
    path.length
  end

  def instruct(target)
    $stderr.puts "[SI] #{indent}#{target}"
    $stdout.print "<?#{target}"
    target_type.set_instruct
  end

  def end_instruct(target)
    $stderr.puts "[EI] #{indent}#{target}"
    target_type.set_element
  end

  # don't know what this is
  def attr(name, str)
    $stderr.puts "[AT] #{indent}#{name}=#{str}"
  end

  def attr_value(name, value)
    $stderr.puts "[AV] #{indent}#{name}=#{value.as_s}"
    $stdout.print %Q( #{name}="#{value.as_s}")
  end

  def attrs_done
    $stderr.puts "[AD] #{indent}>"
    # $stdout.print(target_type.instruct? ? "?>" : ">")
  end

  # ignoring
  def doctype(str)
    $stderr.puts "[DT] #{indent}#{str}"
  end

  # ignoring
  def comment(str)
    $stderr.puts "[CO] #{indent}#{str}"
  end

  def cdata(str)
    $stderr.puts "[CD] #{indent}#{str}"
    # $stdout.print("<![CDATA[#{str}]]>")
    element_context.add_cdata(str)
  end

  def text(str)
    $stderr.puts "[TX] #{indent}#{str}"
    # $stdout.print str
    element_context.add_text(str)
  end

  def value(value)
    $stderr.puts "[VL] #{indent}#{value.as_s}"
    # $stdout.print value.as_s
    element_context.add_text(value.as_s)
  end

  def start_element(name)
    $stderr.puts "[SE] #{indent}<#{name}"
    element_context&.flush(close: false)
    $stdout.print "\n#{indent}<#{name}"
    path.push(ElementContext.new(name, depth: depth))
  end

  def end_element(name)
    $stderr.puts "[EE] #{indent}</#{name}>"
    # $stdout.print "\n#{indent}</#{name}>"
    element_context.flush(close: true)
    path.pop
  end

  def error(message, line, column)
    $stderr.puts "[ER] error at #{line}:#{column} #{message}"
  end

  def abort(name)
    $stderr.puts "[AB] #{name}"
  end

  private

  class ContextText
    def initialize(content)
      @content = content
    end

    def flush
      $stdout.print(@content)
    end
  end

  class ContextCData
    def initialize(content)
      @content = content
    end

    def flush
      $stdout.print("<![CDATA[#{@content}]]>")
    end
  end

  class Target
    def set_instruct
      @target = :instruct
    end

    def set_element
      @target = :element
    end

    def instruct?
      @target == :instruct
    end

    def element?
      @target == :element
    end
  end

  class ElementContext
    def initialize(name, depth:)
      @name = name
      @depth = depth
      @context_stack = []
      @is_start_closed = false
    end

    def indent(depth)
      '  ' * depth
    end


    def add_text(text)
      @context_stack.push(ContextText.new(text))
    end

    def add_cdata(cdata)
      @context_stack.push(ContextCData.new(cdata))
    end

    def content?
      @context_stack.length > 0
    end

    def flush(close:)
      if close && !@is_start_closed && !content?
        $stdout.print " />"
        @is_start_closed = true
        return
      end

      is_one_liner = !@is_start_closed && close

      if !@is_start_closed
        $stdout.print ">"
        @is_start_closed = true
      end

      @context_stack.length.tap do
        @context_stack.each do |content|
          $stdout.print "\n#{'  ' * (@depth + 1)}" if !is_one_liner
          content.flush
        end
        @context_stack.clear
      end

      if close
        $stdout.print "\n#{'  ' * @depth}" if !is_one_liner
        $stdout.print "</#{@name}>"
      end
    end
  end
end
