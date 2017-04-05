require "builder"

class HashToXmlMap
  def initialize(hash_content)
    @hash_content = hash_content
  end

  def render
    map = Builder::XmlMarkup.new(indent: 2)

    map.instruct! :xml, version: "1.0", encoding: "utf-8"
    map.declare! :DOCTYPE, :vymmap
    map.vymmap(version: "2.5.0") do |builder|
      builder.mapcenter do
        if hash_content && !hash_content.empty?
          generate_branch(hash_content, builder)
        end
      end
    end
  end

  private

  def generate_branch(branch, builder)
    branch.each do |title, subbranches|
      builder.heading(title)
      subbranches.each do |subbranch|
        builder.branch do
          generate_branch(subbranch, builder)
        end
      end
    end

  end
  attr_reader :hash_content
end
