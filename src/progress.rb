# frozen_string_literal: true

class Progress
  PROGRESS_CHARS = ['▏', '▎', '▍', '▌', '▋', '▊', '▉', '█'].freeze
  EMPTY_CHAR = ' '

  def initialize(width: 10)
    @width = width
    @bar_width = width - 2
  end

  def update(percentage)
    full_chars_length = (percentage * @bar_width).floor
    empty_chars_length = ((1 - percentage) * @bar_width).floor
    partial_char = if full_chars_length + empty_chars_length == @bar_width
                     ''
                   else
                     slots = @bar_width * PROGRESS_CHARS.length
                     index = (slots * percentage).floor % PROGRESS_CHARS.length
                     PROGRESS_CHARS[index]
                   end
    "[#{PROGRESS_CHARS[-1] * full_chars_length}#{partial_char}#{EMPTY_CHAR * empty_chars_length}]"
  end
end
