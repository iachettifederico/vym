require "yaml"
require "./lib/vym/hierarchical_parser"

module Vym
  class YamlParser < HierarchicalParser
    def main_concept_regex
      /\s*---\s*\n-\s+(.+):?\s*$/
    end

    def suffix_regex
      /\s*:\s*$/
    end

    def branch_regex
      /^(\s*)-\s+(.+):?\s*$/
    end

    def get_level_from_size(size)
      size/2
    end
  end
end
