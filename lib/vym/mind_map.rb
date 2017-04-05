# require "./xml_generator"
require "./lib/vym/org_parser"
require "./lib/vym/hash_to_xml_map"
require "securerandom"
require "zip"
require "pathname"

module Vym
  class MindMap
    def initialize(hash_content)
      @hash_content = hash_content
    end

    def self.from(org_text: nil, **options)
      new(OrgParser.new(org_text).to_h)
    end

    def self.from_org_file(file_name)
      new(OrgParser.new(File.read(file_name)).to_h)
    end

    def xml
      HashToXmlMap.new(hash_content).render
    end

    def to_file(file_name)
      file_path = Pathname(file_name).expand_path
      Zip::File.open(file_path.to_s, Zip::File::CREATE) do |zipfile|
        zipfile.get_output_stream(file_path.basename(".vym").to_s + ".xml") { |os|
          os.write xml
        }
      end
      puts "Created #{file_path}"
    end
    private

    attr_reader :hash_content
  end
end
