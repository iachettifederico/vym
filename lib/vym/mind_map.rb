# require "./xml_generator"
require "./lib/vym/org_parser"

module Vym
  class MindMap
    def initialize(args)

    end

    def self.from(org_text: nil)
      new(OrgParser.new(org_text).to_h)
    end

    def xml

    end
  end
end
