# We require the uri gem to parse URIs
require 'uri'
# Use [nokogiri][no] to parse html
require 'nokogiri'
# Use open-uri to fetch the document specified by the URI
require 'open-uri'
require_relative 'fnparser'

class Recipe
  attr_accessor :title, :authors, :ingredients, :preparation
  
  def initialize(url)
    @title = nil
    @authors = []
    @ingredients = Ingredients.new
    @preparation = Preparation.new
    parser = FNParser.new(url, self)
    parser.parse
  end

  def set_title(title)
    @title = title
  end
  
  def add_author(author)
    @authors.push author
  end

  def add_ingredient(quantity, unit, name, text)
    @ingredients.add(quantity, unit, name, text) 
  end

  def add_step(step_text)
    @preparation.add(step_text)
  end

end

class RecipeSection
end

class Ingredients < RecipeSection
  attr_accessor :ingredients

  def initialize
    @ingredients = []
  end
  
  def add(quantity, unit, name, text=nil)
    ing = Ingredient.new(text=text)
    @ingredients.push ing
  end
  
  def to_s
    s = ""
    @ingredients.each { |ing| s << ing.to_s << "\n" }
    s
  end
  
  def each(&blk)
    @ingredients.each(&blk)
  end

end

class Ingredient
  attr_accessor :quantity, :unit, :name, :text
  def initialize(quantity=nil, unit=nil, name=nil, text=nil)
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
  attr_accessor :steps
  def initialize
    @steps = []
  end
  def add(text)
    step = Step.new(text)
    @steps.push step
  end
  
  def to_s
    s = ""
    @steps.each { |step| s << step.to_s << "\n" }
    s
  end
  
  def each(&blk)
    @steps.each(&blk)
  end

end

class Step
  attr_accessor :text
  def initialize(text)
    @text = text
  end
  def to_s
    @text
  end
end

url = 'test/foodnetwork_sample.html'
recipe = Recipe.new(url)
puts recipe.title
puts recipe.authors
puts recipe.ingredients
puts recipe.preparation

