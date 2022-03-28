require 'slop'

class CliArgsParser
  def self.parse
    Slop.parse do |o|
      o.string '-d', '--dat-file', 'The roms dat file'
    end
  end
end
