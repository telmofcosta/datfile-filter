# frozen_string_literal: true

# Parse a configuration ini file
# A configuration ini files is as follows:
# ````
# [FOLDER_SETTINGS]
# ....
# [ROOT_FOLDER]
#
# [SOME_CATEGORY]
# machine_name_1
# machine_name_2
# ...
# [OTHER_CATEGORY]
# machine_name_x
# machine_name_y
# ...
class IniParser
  LINE_TYPE_PARSER = {
    empty: ->(_instance, _line) {},
    comment: ->(_instance, _line) {},
    new_section: ->(instance, line) { instance.parse_new_section(line) },
    rom: ->(instance, line) { instance.parse_new_rom(line) },
    unknown: ->(_instance, _line) {}
  }.freeze

  def initialize(file_name)
    @file_name = file_name
    @root_folder_reached = false
    @current_section_data = nil
    @data = {}
  end

  def parse
    File.readlines(@file_name).each do |text_line|
      line = Line.new(text_line)
      # puts format("%<kind>12s %<line>s", kind: line.kind, line: text_line)
      parser = LINE_TYPE_PARSER[line.kind]
      parser.call(self, line)
    end
    @data
  end

  def parse_new_rom(line)
    return if @current_section_data.nil?
    return unless line.rom?

    @current_section_data.push(line.rom) if line.rom?
  end

  def parse_new_section(line)
    return unless line.new_section?

    @root_folder_reached = true if !@root_folder_reached && line.new_section == "ROOT_FOLDER"

    return unless @root_folder_reached

    @current_section_data = []
    @data[line.new_section] = @current_section_data
  end

  # Represents a line from the ini file
  class Line
    def initialize(text_line)
      @text_line = text_line
      @content = text_line.strip
    end

    def kind
      return :empty if empty?
      return :comment if comment?
      return :new_section if new_section?
      return :rom if rom?

      :unknown
    end

    def ignore?
      empty? || comment?
    end

    def empty?
      @content == ""
    end

    def comment?
      @content.start_with?(";;")
    end

    def rom
      return if ignore? || new_section?

      @content
    end

    def rom?
      !rom.nil?
    end

    def new_section
      @content[1...-1] if @content[0] == "[" && @content[-1] == "]"
    end

    def new_section?
      !new_section.nil?
    end
  end
end
