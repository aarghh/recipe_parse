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

#### Public interface to FNParser class
# This is where we define the food network recipe parser
class FNParser
 
  def initialize(url, recipe)
    @doc = Nokogiri::HTML(open(url))
    @recipe = recipe
  end

  def parse
    set_title
    set_authors
    set_ingredients
    set_preparation
  end
  
  def set_title
    rule = 'div.rcp-head h1.fn'
    title = @doc.css(rule)[0].content.strip
    @recipe.set_title(title)
  end

  def set_authors
    rule = 'p.author a'
    @doc.css(rule).each do |a|
      @recipe.add_author(a.content.strip)
    end
  end

  def set_ingredients
    rule = 'ul.kv-ingred-list1 li.ingredient' 
    @doc.css(rule).each do |ing_html| 
      ing_text = ing_html.content.strip 
      @recipe.add_ingredient(nil, nil, nil, text=ing_text)
    end
  end

  def set_preparation
    rule = 'div.instructions p.instruction'
    @doc.css(rule).each do |step_html| 
      @recipe.add_step step_html.content.strip
    end
  end

end

