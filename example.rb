require_relative 'parse'

#url = 'http://www.epicurious.com/articlesguides/bestof/toprecipes/bestpastarecipes/recipes/food/views/Lemon-Gnocchi-with-Spinach-and-Peas-240959'
url = 'test/epicurious_sample.html'
r = Recipe.new(url, 'epicurious')
puts "Printing ingredients"
r.ingredients.each do |ing|
  ing_type, ing_match = classify_ingredient(ing)
  puts ing + " - " + ing_type + ' - ' + ing_match
end

