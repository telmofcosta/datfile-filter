require_relative 'src/dat_file_parser'

def preprocess_dat_file
  parser = DatFileParser.new
  File.open("assets/listxml.micro.xml") do |file|
    Ox.sax_parse(parser, file)
  end
end

def run
  preprocess_dat_file
end

run
