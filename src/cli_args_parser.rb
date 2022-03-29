# frozen_string_literal: true

require "slop"
# Command line arguments definition
class CliArgsParser
  def self.parse
    Slop.parse do |o|
      o.string "-d", "--dat-file", "The roms dat file"
    end
  end
end
