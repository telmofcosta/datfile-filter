# frozen_string_literal: true

# Knows how to return a string with a progress indicator, representing the supplied values
class Progress
  PROGRESS_CHARS = ["▏", "▎", "▍", "▌", "▋", "▊", "▉", "█"].freeze
  EMPTY_CHAR = " "

  def initialize(width: 10)
    @width = width
    @bar_width = width - 2
  end

  def update(percentage)
    full_chars_length = (percentage * @bar_width).floor
    empty_chars_length = ((1 - percentage) * @bar_width).floor
    has_partial_char = full_chars_length + empty_chars_length == @bar_width
    "[#{PROGRESS_CHARS[-1] * full_chars_length}#{partial_char if has_partial_char}#{EMPTY_CHAR * empty_chars_length}]"
  end

  private

  def partial_char
    slots = @bar_width * PROGRESS_CHARS.length
    index = (slots * percentage).floor % PROGRESS_CHARS.length
    PROGRESS_CHARS[index]
  end
end
