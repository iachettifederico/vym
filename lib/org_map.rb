require "./vym_script"

file_name = Pathname("~/Dropbox/things_to_learn/romrb/map.org").expand_path
vym_file = file_name.to_s.gsub(/\.org$/, ".vym")
# => "/home/fedex/Dropbox/things_to_learn/romrb/map.vym"

content = File.read(file_name)


class OrgMap
  attr_reader :content
  attr_reader :vym_file
  attr_reader :concept
  attr_reader :branch_candidates

  def initialize(file_name)
    file_name = Pathname("~/Dropbox/things_to_learn/romrb/map.org").expand_path
    @vym_file = file_name.to_s.gsub(/\.org$/, ".vym")

    @content = File.read(file_name)

    @concept = get_concept
    @branch_candidates = get_branch_candidates
  end

  def get_concept
    content.match(/\#\+TITLE:\s*(.+)$/)[1]
  end

  def get_branch_candidates
    content.scan(/^\*.+/)
  end

  def generate_map
    MindMap.new(concept) do
      prev_indent = 0
      branch_candidates.each do |candidate| # ~> NameError: undefined local variable or method `branch_candidates' for #<MindMap:0x0000000156f648>
        _, asterisks, title =  candidate.match(/^(\*+)\s*(.+)/).to_a
        current_indent = asterisks.size

        generate_branch(title, current_indent, prev_indent)
      end
    end
  end

  def generate_branch(*)
    branch(hola)
  end

  def render
    generate_map.render
  end
end

map = OrgMap.new(file_name)
# puts map.get_concept
# puts map.get_branch_candidates

puts map.render

# ~> NameError
# ~> undefined local variable or method `branch_candidates' for #<MindMap:0x0000000156f648>
# ~>
# ~> xmptmp-in2766Irc.rb:37:in `block in generate_map'
# ~> /home/fedex/code/gems/vym/lib/vym_script.rb:17:in `instance_eval'
# ~> /home/fedex/code/gems/vym/lib/vym_script.rb:17:in `block (2 levels) in initialize'
# ~> /home/fedex/.rvm/gems/ruby-2.4.0/gems/builder-3.2.3/lib/builder/xmlbase.rb:175:in `_nested_structures'
# ~> /home/fedex/.rvm/gems/ruby-2.4.0/gems/builder-3.2.3/lib/builder/xmlbase.rb:68:in `tag!'
# ~> /home/fedex/.rvm/gems/ruby-2.4.0/gems/builder-3.2.3/lib/builder/xmlbase.rb:93:in `method_missing'
# ~> /home/fedex/code/gems/vym/lib/vym_script.rb:15:in `block in initialize'
# ~> /home/fedex/.rvm/gems/ruby-2.4.0/gems/builder-3.2.3/lib/builder/xmlbase.rb:175:in `_nested_structures'
# ~> /home/fedex/.rvm/gems/ruby-2.4.0/gems/builder-3.2.3/lib/builder/xmlbase.rb:68:in `tag!'
# ~> /home/fedex/.rvm/gems/ruby-2.4.0/gems/builder-3.2.3/lib/builder/xmlbase.rb:93:in `method_missing'
# ~> /home/fedex/code/gems/vym/lib/vym_script.rb:13:in `initialize'
# ~> xmptmp-in2766Irc.rb:35:in `new'
# ~> xmptmp-in2766Irc.rb:35:in `generate_map'
# ~> xmptmp-in2766Irc.rb:51:in `render'
# ~> xmptmp-in2766Irc.rb:59:in `<main>'
