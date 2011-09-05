require 'uri'
require 'nokogiri'
require 'open-uri'
require 'yaml'
require_relative 'classify_ingredient'

class Recipe
  
  attr_accessor :assoc

  @@hosts = {
    'www.epicurious.com' => 'epicurious',
    'www.bonappetit.com' => 'bonappetit',
  }
  def initialize(url, host=nil)
    @assoc = [:title, :ingredients, :preparation]
    
    # find rule file for host
    u = URI::parse(url)
    if u.scheme == 'http' || u.scheme == 'https'
      host = @@hosts[u.host]
    elsif u.scheme == nil 
      # Input uri looks like a file path
      if host == nil
        abort "Please specify a hostname to identify the parsing rules for the file"
      end
    else
      abort "Scheme #{u.scheme} is not supported"
    end
    yml = YAML::load(File.open('rules/' + host + '.yml'))
    doc = Nokogiri::HTML(open(url))
    
    # create associated objects and accessor methods for them
    @assoc.each do |name|
      klass_name = name.to_s.camelize
      obj = Object::const_get(klass_name).new(doc, yml)
      self.class.send(:define_method, name) { obj }
    end

  end

  def to_s
    s = ""
    @assoc.each do |name|
      obj = self.send(name)
      s << obj.to_s << "\n"
    end
    s << "\n"
  end

end

class RecipeSection
  def initialize(doc, yml)
    @rule_name = self.class.to_s.underscore
    @rule = yml[@rule_name]
  end
end


class Title < RecipeSection
  attr_reader :content
  def initialize(doc, yml)
    super(doc, yml)
    if @rule 
      @content = doc.css(@rule)[0].content
    end
  end
  def to_s
    @content << "\n"
  end
end

class Author < RecipeSection
end

class Image < RecipeSection
end

class Ingredients < RecipeSection
  
  attr_reader :ing_list
  
  def initialize(doc, yml)
    super(doc, yml)
    @ing_list = []
    if @rule
        doc.css(@rule).each do |ing| 
            @ing_list.push ing.content.strip
        end
    end
  end
  
  def to_s
    s = ""
    @ing_list.each {|ing| s << ing << "\n" }
    s
  end
  
  def each(&blk)
    @ing_list.each(&blk)
  end

end

class Preparation < RecipeSection
  
  attr_reader :steps
  
  def initialize(doc, yml)
    super(doc, yml)
    @steps = []
    if @rule
        doc.css(@rule).each do |step| 
            @steps.push step.content.strip 
        end
    end
  end

  def to_s
    s = ""
    @steps.each_with_index {|step,i| s << (i+1).to_s << ". " << step << "\n" }
    s
  end

end

class String
  
  def underscore
    self.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end
  
  def camelize(first_letter_in_uppercase = true)
    if first_letter_in_uppercase
      self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    else
      self.first.downcase + camelize(lower_case_and_underscored_word)[1..-1]
    end
  end

end




