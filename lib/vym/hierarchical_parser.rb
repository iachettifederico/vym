module Vym
  class HierarchicalParser
    def initialize(input_text)
      @input_text = input_text
    end

    def main_concept
      input_text[main_concept_regex, 1].gsub(suffix_regex, "")
    end

    def branches
      input_text.scan(branch_regex).map { |asterisks, text|
        if asterisks.size > 0
          title = text.gsub(suffix_regex, "")
          level = get_level_from_size(asterisks.size)
          Branch[title, level]
        end
      }.compact
    end

    def to_h
      return {} if !input_text || input_text =~ /\A\s*\Z/

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

    attr_reader :input_text

    def sanitize_hash(h)
      h.each_with_object({}) { |(k,v), result|
        result[k] = Array(v).map { |hash| sanitize_hash(hash) }
      }
    end

    def get_level_from_size(size)
      size
    end

    Branch = Struct.new(:title, :level) do
      def inspect
        "<Branch[#{level}] #{title}>"
      end
    end

  end
end
