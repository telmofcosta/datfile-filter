require_relative 'src/cli_args_parser'
require_relative 'src/dat_file_parser'
require_relative 'src/dat_file_proxy'
require_relative 'src/xml_debugger'

def preprocess_dat_file(file_name)
  parser = DatFileParser.new
  File.open(file_name) do |file|
    Ox.sax_parse(parser, file, {symbolize: true })
  end
  puts parser.data
end

def proxy_dat_file(file_name)
  parser = DatFileProxy.new
  File.open(file_name) do |file|
    Ox.sax_parse(parser, file, {})
  end
end

def args
  @args ||= CliArgsParser.parse
end

def run
  # File.open(args[:dat_file]) { |file| Ox.sax_parse(XmlDebugger.new, file, {}) }

  # proxy_dat_file(args[:dat_file])

  preprocess_dat_file(args[:dat_file])
end

run
