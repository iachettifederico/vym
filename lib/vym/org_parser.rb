require "yaml"
require "./lib/vym/hierarchical_parser"

module Vym
  class OrgParser < HierarchicalParser
    def main_concept_regex
      /\#\+TITLE:\s+(.+)$/
    end

    def suffix_regex
      /$/
    end

    def branch_regex
      /^(\*+)\s+(.+)$/
    end
  end
end
