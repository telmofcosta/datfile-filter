# frozen_string_literal: true

require "set"
# require "amazing_print"

require_relative "src/cli_args_parser"
require_relative "src/dat_file_preprocessor"
require_relative "src/dat_file_processor"
require_relative "src/dat_file_proxy"
require_relative "src/xml_debugger"
require_relative "src/ini_parser"

# Filters a list of rom names based on a set of filters
class RomFilter
  def initialize(dat_file_name)
    @data = preprocess_dat_file(dat_file_name)
    @data_keys = @data.keys.to_set
    @filters = []
  end

  def add_ini_filter(ini_filter, only: [], except: [])
    ini_data = IniParser.new("assets/filters/#{ini_filter}.ini").parse
    only.each do |filter_expression|
      @filters.push([:only, :ini, section_filtered_roms(ini_data, filter_expression),
                     "#{ini_filter} only /#{filter_expression}/"])
    end
    except.each do |filter_expression|
      @filters.push([:except, :ini, section_filtered_roms(ini_data, filter_expression),
                     "#{ini_filter} except /#{filter_expression}/"])
    end
    self
  end

  def add_rom_filter(except: [], include: [])
    except.each do |filter|
      @filters.push([:except, :clones, nil, "except clones"]) if filter == :clone
    end
    include.each do |filter|
      @filters.push([:include, :romofs, nil, "include romofs"]) if filter == :romof
    end
    self
  end

  def filter
    warn @data_keys.length
    @filters.each do |(filter_selection, filter_type, roms, description)|
      roms = data_key_clones if filter_type == :clones
      roms = data_key_romofs if filter_type == :romofs

      warn "- filtering #{filter_type} #{roms.length} roms: #{description}"
      @data_keys = @data_keys.intersection(roms) if filter_selection == :only
      @data_keys = @data_keys.difference(roms) if filter_selection == :except
      @data_keys = @data_keys.union(roms) if filter_selection == :include
      warn @data_keys.length
    end
  end

  private

  def data_key_clones
    @data_keys.each_with_object([]) { |rom, clones| clones.push(rom) if @data[rom].cloneof }
  end

  def data_key_romofs
    @data_keys.each_with_object([]) do |rom, romofs|
      romof = @data[rom].romof
      romofs.push(romof) if romof
    end
  end

  def preprocess_dat_file(file_name)
    parser = DatFilePreprocessor.new
    File.open(file_name) do |file|
      Ox.sax_parse(parser, file, { symbolize: true })
    end
    parser.data
  end

  def section_filtered_roms(data, filter_expression)
    data.map { |(section, roms)| roms if section.match(filter_expression) }.compact.flatten.to_set
  end
end

def proxy_dat_file(file_name)
  parser = DatFileProxy.new
  File.open(file_name) do |file|
    Ox.sax_parse(parser, file, {})
  end
end

def debug_dat_file(file_name)
  parser = XmlDebugger.new
  File.open(file_name) do |file|
    Ox.sax_parse(parser, file, {})
  end
end

# Creates a new dat file based ona list of roms
class ProcessDatFile
  def initialize(dat_file_name)
    @dat_file_name = dat_file_name
  end

  def process(roms)
    parser = DatFileProcessor.new.set_roms(roms)
    File.open(@dat_file_name) do |file|
      Ox.sax_parse(parser, file, { symbolize: true })
    end
  end
end

def args
  @_args ||= CliArgsParser.parse
end

def run
  # debug_dat_file(args[:dat_file])
  # proxy_dat_file(args[:dat_file])
  # exit
  roms = RomFilter
         .new(args[:dat_file])
         .add_ini_filter(:catlist,
                         only: ["Arcade:"],
                         except: ["Mature",
                                  "Arcade: System",
                                  "Arcade: Casino",
                                  "Arcade: Electromechanical",
                                  "Arcade: Medal Game",
                                  "Arcade: Misc",
                                  "Arcade: MultiGame",
                                  "Arcade: TTL",
                                  "Arcade: Touchscreen",
                                  "Arcade: Tabletop",
                                  "Arcade: Utilities",
                                  "Arcade: Slot Machine",
                                  "Arcade: Simulation",
                                  "Arcade: Quiz",
                                  "Arcade: Puzzle",
                                  "Arcade: Music",
                                  "Arcade: Whac-A-Mole"])
         .add_ini_filter(:languages, only: ["English"])
         .add_ini_filter(:screenless, except: ["ROOT_FOLDER"])
         .add_rom_filter(except: [:clone], include: [:romof])
         .filter

  ProcessDatFile.new(args[:dat_file]).process(roms)
end

run
