# frozen_string_literal: true

require "ox"

# Xml Ox::Sax parser.
# prints what it reads
class DatFileProxy < Ox::Sax
  attr_accessor :path, :target_type

  def initialize
    super
    @path = []
    @target_type = Target.new
  end

  def indent
    "  " * depth
  end

  def element_context
    path.last
  end

  def depth
    path.length
  end

  def instruct(target)
    warn "[SI] #{indent}#{target}"
    $stdout.print "<?#{target}"
    target_type.set_instruct
  end

  def end_instruct(target)
    warn "[EI] #{indent}#{target}"
    $stdout.print "?>"
    target_type.set_element
  end

  def attr(name, str)
    warn "[AT] #{indent}#{name}=#{str}"
    $stdout.print %( #{name}="#{str}")
  end

  # Either attr or attr_value is called.
  # If attr_value is defined, attr will not be called.
  # def attr_value(name, value)
  #   warn "[AV] #{indent}#{name}=#{value.as_s}"
  #   $stdout.print %( #{name}="#{value.as_s}")
  # end

  def attrs_done
    warn "[AD] #{indent}>"
    # $stdout.print(target_type.instruct? ? "?>" : ">")
  end

  def doctype(str)
    warn "[DT] #{indent}#{str}"
    $stdout.print "\n#{indent}<!DOCTYPE#{str}>"
  end

  # ignoring
  def comment(str)
    warn "[CO] #{indent}#{str}"
  end

  def cdata(str)
    warn "[CD] #{indent}#{str}"
    # $stdout.print("<![CDATA[#{str}]]>")
    element_context.add_cdata(str)
  end

  def text(str)
    warn "[TX] #{indent}#{str}"
    # $stdout.print str
    element_context.add_text(str)
  end

  # Either text or value is called.
  # If value is defined, text will not be called.
  # def value(value)
  #   warn "[VL] #{indent}#{value.as_s}"
  #   # $stdout.print value.as_s
  #   element_context.add_text(value.as_s)
  # end

  def start_element(name)
    warn "[SE] #{indent}<#{name}"
    element_context&.flush(close: false)
    $stdout.print "\n#{indent}<#{name}"
    path.push(ElementContext.new(name, depth:))
  end

  def end_element(name)
    warn "[EE] #{indent}</#{name}>"
    # $stdout.print "\n#{indent}</#{name}>"
    element_context.flush(close: true)
    path.pop
  end

  def error(message, line, column)
    warn "[ER] error at #{line}:#{column} #{message}"
  end

  def abort(name)
    warn "[AB] #{name}"
  end

  # ContextText
  class ContextText
    def initialize(content)
      @content = content
    end

    def flush
      $stdout.print(@content)
    end
  end

  # ContextCData
  class ContextCData
    def initialize(content)
      @content = content
    end

    def flush
      $stdout.print("<![CDATA[#{@content}]]>")
    end
  end

  # Target
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

  # ElementContext
  class ElementContext
    def initialize(name, depth:)
      @name = name
      @depth = depth
      @context_stack = []
      @is_start_closed = false
    end

    def indent(depth)
      "  " * depth
    end

    def add_text(text)
      @context_stack.push(ContextText.new(text))
    end

    def add_cdata(cdata)
      @context_stack.push(ContextCData.new(cdata))
    end

    def content?
      @context_stack.length.positive?
    end

    def flush(close:)
      if close && !@is_start_closed && !content?
        print_auto_close_tag
        return
      end

      is_one_liner = !@is_start_closed && close

      print_on_finish_attributes unless @is_start_closed

      print_attributes(is_one_liner)

      print_end_element(is_one_liner) if close
    end

    private

    def print_auto_close_tag
      $stdout.print " />"
      @is_start_closed = true
    end

    def print_on_finish_attributes
      $stdout.print ">"
      @is_start_closed = true
    end

    def print_attributes(is_one_liner)
      @context_stack.length.tap do
        @context_stack.each do |content|
          $stdout.print "\n#{'  ' * (@depth + 1)}" unless is_one_liner
          content.flush
        end
        @context_stack.clear
      end
    end

    def print_end_element(is_one_liner)
      $stdout.print "\n#{'  ' * @depth}" unless is_one_liner
      $stdout.print "</#{@name}>"
    end
  end
end
