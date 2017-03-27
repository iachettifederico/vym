require "builder"
require "zip"
require "pathname"

file_name = "/tmp/map.vym"

Branch = Struct.new(:title, :level)

class MindMap2
  def initialize(concept, &block)
    @map = Builder::XmlMarkup.new(indent: 2)

    @map.instruct! :xml, version: "1.0", encoding: "UTF-8"
    @map.declare! :DOCTYPE, :vymmap
    @map.vymmap(version: "2.5.0") do |b|
      @builder = b
      @builder.mapcenter do
        @builder.heading(concept)
        instance_eval(&block)
      end
    end
  end

  def branch(title)
    @builder.branch do
      @builder.heading(title)
      yield if block_given?
    end
  end

  def render
    @map.target!
  end

  def render_to_file(file_name)
    file_path = Pathname(file_name).expand_path

    Zip::File.open(file_path.to_s, Zip::File::CREATE) do |zipfile|
      zipfile.get_output_stream(file_path.basename(".vym").to_s + ".xml") { |os|
        os.write @map.target!
      }
    end
    puts "Created #{file_path}"
  end
end

class MindMap
  attr_reader :concept
  attr_reader :branches

  def initialize(concept, &block)
    @concept = concept
    @branches = []
  end

  def set_concept(concept)
    @concept = concept
  end

  def map
    @map = Builder::XmlMarkup.new(indent: 2)

    @map.instruct! :xml, version: "1.0", encoding: "UTF-8"
    @map.declare! :DOCTYPE, :vymmap
    @map.vymmap(version: "2.5.0") do |b|
      b.mapcenter do
        b.heading(concept)
        # branches.each_cons(2) do |curr, nxt|
        #   if curr[:level] >= nxt[:level]
        #     b.branch(curr[:title])
        #   end
        # end
        render_branch(branches.to_enum, b)
      end
    end
    @map
  end

  def render_branch(branch, builder)
    curr = branch.next
    nxt  = branch.peek # ~> StopIteration: iteration reached an end

    if curr.level >= nxt.level
      builder.branch(curr.title)
      render_branch(branch, builder)
    else
      builder.branch do
        builder.header(curr.title)
        render_branch(branch, builder)
      end
    end
  end

  def branch(title, level)
    branches << Branch.new(title, level)
  end

  def render
    map.target!
  end

  def render_to_file(file_name)
    file_path = Pathname(file_name).expand_path

    Zip::File.open(file_path.to_s, Zip::File::CREATE) do |zipfile|
      zipfile.get_output_stream(file_path.basename(".vym").to_s + ".xml") { |os|
        os.write @map.target!
      }
    end
    puts "Created #{file_path}"
  end
end

my_map = MindMap.new("Main concept")
my_map.branch("Branch 1", 1)
my_map.branch("Branch 2", 1)
my_map.branch("Branch 1.1", 2)
my_map.branch("Branch 1.1", 2)
my_map.branch("Branch 3", 1)

#   branch("Branch 2") do
#     branch("Branch 2.1")
#     branch("Branch 2.1")
#   end
# end


puts my_map.render
# my_map.render_to_file("/tmp/pepe.vym")

# ~> StopIteration
# ~> iteration reached an end
# ~>
# ~> xmptmp-in2772pEK.rb:81:in `peek'
# ~> xmptmp-in2772pEK.rb:81:in `render_branch'
# ~> xmptmp-in2772pEK.rb:85:in `render_branch'
# ~> xmptmp-in2772pEK.rb:85:in `render_branch'
# ~> xmptmp-in2772pEK.rb:89:in `block in render_branch'
# ~> /home/fedex/.rvm/gems/ruby-2.4.0/gems/builder-3.2.3/lib/builder/xmlbase.rb:175:in `_nested_structures'
# ~> /home/fedex/.rvm/gems/ruby-2.4.0/gems/builder-3.2.3/lib/builder/xmlbase.rb:68:in `tag!'
# ~> /home/fedex/.rvm/gems/ruby-2.4.0/gems/builder-3.2.3/lib/builder/xmlbase.rb:190:in `block (2 levels) in cache_method_call'
# ~> xmptmp-in2772pEK.rb:87:in `render_branch'
# ~> xmptmp-in2772pEK.rb:85:in `render_branch'
# ~> xmptmp-in2772pEK.rb:73:in `block (2 levels) in map'
# ~> /home/fedex/.rvm/gems/ruby-2.4.0/gems/builder-3.2.3/lib/builder/xmlbase.rb:175:in `_nested_structures'
# ~> /home/fedex/.rvm/gems/ruby-2.4.0/gems/builder-3.2.3/lib/builder/xmlbase.rb:68:in `tag!'
# ~> /home/fedex/.rvm/gems/ruby-2.4.0/gems/builder-3.2.3/lib/builder/xmlbase.rb:93:in `method_missing'
# ~> xmptmp-in2772pEK.rb:66:in `block in map'
# ~> /home/fedex/.rvm/gems/ruby-2.4.0/gems/builder-3.2.3/lib/builder/xmlbase.rb:175:in `_nested_structures'
# ~> /home/fedex/.rvm/gems/ruby-2.4.0/gems/builder-3.2.3/lib/builder/xmlbase.rb:68:in `tag!'
# ~> /home/fedex/.rvm/gems/ruby-2.4.0/gems/builder-3.2.3/lib/builder/xmlbase.rb:93:in `method_missing'
# ~> xmptmp-in2772pEK.rb:65:in `map'
# ~> xmptmp-in2772pEK.rb:99:in `render'
# ~> xmptmp-in2772pEK.rb:128:in `<main>'
