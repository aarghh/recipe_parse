#! /usr/bin/env ruby

require_relative 'parse'
require_relative 'classify_ingredient'

#url = 'http://www.epicurious.com/articlesguides/bestof/toprecipes/bestpastarecipes/recipes/food/views/Lemon-Gnocchi-with-Spinach-and-Peas-240959'

puts 'Food Network recipe'
url = 'test/foodnetwork_sample.html'
r = Recipe.new(url, 'foodnetwork')
puts r.ingredients

puts
puts 'Bonappetit recipe'
url = 'test/bonappetit_sample.html'
r = Recipe.new(url, 'bonappetit')
puts r.ingredients

#puts "Printing ingredients"
#
#r.ingredients.each do |ing|
#    ing_type, ing_match = classify_ingredient(ing)
#    puts ing + " - " + ing_type + ' - ' + ing_match
#end


