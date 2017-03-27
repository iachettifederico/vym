require "yaml"

module Vym
  class OrgParser
    def initialize(org_text)
      @org_text = org_text
    end

    def main_concept
      org_text[/\#\+TITLE:\s+(.+)$/, 1]
    end

    def branches
      org_text.scan(/^(\*+)\s+(.+)$/).map { |asterisks, title|
        Branch[title, asterisks.size]
      }
    end

    def to_h
      return {} if !org_text || org_text =~ /\A\s*\Z/

      yaml_arr = []

      yaml_arr << "---"
      yaml_arr << "- #{main_concept}:"

      branches.map { |branch|
        yaml_arr << "  " * branch.level + "- " + branch.title + ":"
      }

      yaml = yaml_arr.join("\n")
      sanitize_hash(YAML.load(yaml).first)
    end

    private

    attr_reader :org_text

    def sanitize_hash(h)
      h.each_with_object({}) { |(k,v), result|
        result[k] = Array(v).map { |hash| sanitize_hash(hash) }
      }
    end

    Branch = Struct.new(:title, :level) do
      def inspect
        "<Branch[#{level}] #{title}>"
      end
    end

  end


end
