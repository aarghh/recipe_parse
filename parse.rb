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
  }
  def initialize(url, host=nil)
    @assoc = [:title, :ingredients, :preparation]
    
    # find rule file for host
    u = URI::parse(url)
    host = @@hosts[u.host]
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
  end
end

class Title < RecipeSection
  attr_reader :content
  def initialize(doc, yml)
    super(doc, yml)
    @content = doc.css(yml[@rule_name])[0].content
  end
  def to_s
    content << "\n"
  end
end

class Ingredients < RecipeSection
  
  attr_reader :ing_list
  
  def initialize(doc, yml)
    super(doc, yml)
    @ing_list = []
    doc.css(yml[@rule_name]).each do |ing| 
      @ing_list.push ing.content.strip
    end
  end
  
  def to_s
    s = ""
    @ing_list.each {|ing| s << ing << "\n" }
    s
  end

end

class Preparation < RecipeSection
  
  attr_reader :steps
  
  def initialize(doc, yml)
    super(doc, yml)
    @steps = []
    doc.css(yml[@rule_name]).each do |step| 
      @steps.push step.content.strip 
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

url = 'http://www.epicurious.com/articlesguides/bestof/toprecipes/bestpastarecipes/recipes/food/views/Lemon-Gnocchi-with-Spinach-and-Peas-240959'
#url = '/Users/sujeet/Dropbox/code/recipe_parse/test/epicurious_sample.html'
r = Recipe.new(url)
puts "Recipe from epicurious"
puts r.to_s

url = 'http://www.bonappetit.com/recipes/quick-recipes/2010/08/curried_red_lentil_kohlrabi_and_couscous_salad'
r = Recipe.new(url)
puts "Recipe from bonappetit"
puts r.to_s

