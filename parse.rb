#### Pre-requisites

# We require the uri gem to parse URIs
require 'uri'
# Use [nokogiri][no] to parse html
require 'nokogiri'
# Use open-uri to fetch the document specified by the URI
require 'open-uri'
# Use yaml to specify template files
require 'yaml'

# [no]: http://nokogiri.org/

#### Public interface to Recipe class
# This is where we define the Recipe class
class Recipe
  
  attr_accessor :assoc

  @@hosts = {
    'www.epicurious.com' => 'epicurious',
    'www.bonappetit.com' => 'bonappetit',
    'www.foodnetwork.com' => 'foodnetwork'
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
      @content = doc.css(@rule)[0].content.strip
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
        doc.css(@rule['ingredient']).each do |ing_html| 
          quantity = unit = name = ing_text = nil
          quantity = ing_html.css(@rule['quantity'])[0].content.strip if @rule['quantity']
          unit = ing_html.css(@rule['unit'])[0].content.strip if @rule['unit']
          name = ing_html.css(@rule['name'])[0].content.strip if @rule['name']
          ing_text = ing_html.content.strip if !(quantity || unit || name)
          ing = Ingredient.new(quantity, unit, name, ing_text)
          @ing_list.push ing
        end
    end
  end
  
  def to_s
    s = ""
    @ing_list.each do |ing| 
      s << ing.to_s << "\n"
    end
    s
  end
  
  def each(&blk)
    @ing_list.each(&blk)
  end

end

class Ingredient
  attr_accessor :quantity, :unit, :name, :text
  def initialize(quantity, unit, name, text)
    @quantity = quantity
    @unit = unit
    @name = name
    @text = text
  end
  def to_s
    s = ''
    s += @quantity.to_s + ' ' if @quantity
    s += @unit.to_s + ' ' if @unit
    s += @name.to_s + ' ' if @name
    s += @text.to_s + ' ' if @text
    s
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



