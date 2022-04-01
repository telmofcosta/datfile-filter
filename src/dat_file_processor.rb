# frozen_string_literal: true

require "ox"

# Xml Ox::Sax parser.
# prints what it reads
class DatFileProcessor < Ox::Sax
  GAME_PATH = %i[datafile game].freeze
  attr_accessor :path, :target_type

  def initialize
    super
    @roms = []
    @path = []
    @ignore_game = false
    @target_type = Target.new
  end

  def set_roms(roms)
    @roms = roms
    self
  end

  def ignore_game?
    @ignore_game
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
    $stdout.print "<?#{target}"
    target_type.set_instruct
  end

  def end_instruct(_target)
    $stdout.print "?>"
    target_type.set_element
  end

  def doctype(str)
    $stdout.print "\n#{indent}<!DOCTYPE#{str}>"
  end

  # don't know what this is
  def attr(name, str)
    $stdout.print %( #{name}="#{str}") unless ignore_game?
  end

  # ignoring
  def attrs_done; end

  # ignoring
  def comment(str); end

  def cdata(str)
    element_context.add_cdata(str)
  end

  def text(str)
    element_context.add_text(str)
  end

  def start_element(name)
    element_context&.flush(close: false) unless ignore_game?
    $stdout.print "\n#{indent}<#{name}" unless ignore_game?
    path.push(ElementContext.new(name, depth:))
    @ignore_game = true if path == GAME_PATH && !roms.include?(name)
  end

  def end_element(_name)
    element_context.flush(close: true) unless ignore_game?
    @ignore_game = false if path == GAME_PATH
    path.pop
  end

  def error(message, line, column)
    warn "[ERROR] error at #{line}:#{column} #{message}"
  end

  def abort(name)
    warn "[ABORT] #{name}"
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
