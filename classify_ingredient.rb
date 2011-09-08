require 'yaml'


def classify_ingredient(ing)

 # Load the strings to match the various ingredient types
 ing_strings = YAML::load( File.read('ingredients.yml') )

  # Run through the loaded hash, and construct regular expressions based 
  # the ingredient names

  ing_strings.each do |key, value|

    re_string = value['strings'].join('|')
    value['re'] = Regexp.new("\s*("+re_string+")(\s+|$)", true)
  end

  # Other is a catch-all
  ing_strings['other']['re'] = Regexp.new("")

  # Optional gets special treatment
  ing_strings['optional']['re'] = Regexp.new("(\s+optional(:?\s+|$))", true)


  # This is done per ingredient - so it needs to be separated from the previous 
  # loop - which should be run only once on initialization
  ing = ing.gsub(/,/, '')
  ing = ing.gsub(/\./, '')
  ing_type = ''
  ing_match = ''
  ing_strings.each do |k,v|
    regexp = v['re']
    if ing =~ regexp
      ing_type = v['description']
      ing_match = Regexp.last_match(0)
      break
    end
  end
  return ing_type, ing_match

end

