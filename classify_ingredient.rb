def classify_ingredient(ing)

  # Ingredient names. 
  ing_birds = "chicken|turkey|quail|hen|pigeon|squab|partridge"
  # Create Regexp. 'true' for case-insensitive
  ing_birdsRe = Regexp.new("\s*("+ing_birds+")(\s+|$)", true); 
  ing_shellfish = "shrimps?|prawns?|squid|calamari|lobster|octopus|crabs?|"
  ing_shellfish += "langostine|abalone"
  ing_shellfishRe = Regexp.new("\s*("+ing_shellfish+")(\s+|$)", true)
  ing_fish = "tuna|salmon|halibut|trout|swordfish|shark|sardines?|"
  ing_fish += "anchovy|anchovies|mackerel"
  ing_fishRe = Regexp.new("\s*("+ing_fish+")(\s+|$)", true)
  ing_meat = "beef|lamb|goat|pork|veal|venison|boar|steaks?|"
  ing_meat += "bacon|lard|prosciutto|mutton"
  ing_meatRe = Regexp.new("\s*("+ing_meat+")(\s+|$)", true)
  ing_dairy = "milk|yogurt|curds?|cream|butter|cheese|ghee|buttermilk|eggs?"
  ing_dairyRe = Regexp.new("\s*("+ing_dairy+")(\s+|$)", true)
  ing_veg = "onions?|tomato(:?es)?|potato(:?es)?|squash|zucchini|"
  ing_veg += "broccoli|eggplant|beans|cabbage|cauliflower|chickpea|"
  ing_veg += "peas|carrot|beetroot|spinach|"
  ing_veg += "scallions?|pumpkin|celery|mushroom|bell(:?(-|\s))?peppers?"
  ing_vegRe = Regexp.new("\s*("+ing_veg+")(\s+|$)", true)

  ing_grain = "rice|basmati|wheat|flour|couscous|quinoa"
  ing_grainRe = Regexp.new("\s*("+ing_grain+")(\s+|$)", true)

  ing_pasta   = "pasta|fettucine|ziti|spaphetti|gnocchi|fusilli|"
  ing_pasta  += "lasagna|bucatini|lingune|tagliatelle|penne|macheroni|"
  ing_pasta  += "macaroni|farfalle|ravioli|tortellini|capellini|gemelli|"
  ing_pasta  += "orecchiette|rotelle|spiralini|strozzapreti|cannelloni|"
  ing_pasta  += "rigatoni|manicotti"
  ing_pastaRe = Regexp.new("\s*("+ing_pasta+")(\s+|$)", true)

  ing_fruit = "apples?|oranges?|grapes?|bananas?|limes?|lemons?|pears?"
  ing_fruitRe = Regexp.new("\s*("+ing_fruit+"s?)(\s+|$)", true)
  ing_basics = "sugar|salt|pepper(:?corns)?|(:?(black|cayenne))?\s*pepper(:?corns)?|"
  ing_basics += "(:?olive)?\s*oil|"
  ing_basics += "molasses|vinegar|mayonnaise|mustard|flour|cornstarch|water"
  ing_basicsRe = Regexp.new("\s*("+ing_basics+")(\s+|$)", true)
  ing_herbs = "parsley|sage|rosemary|thyme|oregano|dill|cilantro|marjoram|chives|"
  ing_herbs += "tarragon|basil|mint|bay leaf|bay leaves|lavender|ginger|garlic|"
  ing_herbs += "jalapeno(:?(-|\s))?(:?peppers?)?|"
  ing_herbs += "serrano(:?(-|\s))?(:?peppers?)?|"
  ing_herbs += "chilly(:?(-|\s))?(:?peppers?)?|"
  ing_herbs += "chile(:?(-|\s))?(:?peppers?)?|"
  ing_herbs += "habanero(:?(-|\s))?(:?peppers?)?|"
  ing_herbs += "lemongrass"
  ing_spices = "cinnamon|cloves|cardamom|nutmeg|allspice|anise|fennel|cumin|"
  ing_spices += "coriander|paprika|turmeric|saffron|"
  # Common typos.
  ing_spices += "cardomo(:?m|n)|cinn?amm?o(:?n|m)|safron"
  ing_spicesRe = Regexp.new("\s*("+ing_spices+")(\s+|$)", true)
  ing_herbsSpicesRe = 
    Regexp.new("\s*(" + ing_herbs+"|" + ing_spices +")(\s+|$)", true)
  ing_nuts = "almonds?|cashews?|cashew(:?(\s|-))?(:?nuts?)?|pecans?|walnuts?|"
  ing_nuts += "hazelnuts?|macadamia(:?(\s|-))?nuts?|brazil(:?(\s|-))?nuts?"
  ing_driedfruits = "raisins?|currants?"
  ing_nutsDryfruitsRe = 
    Regexp.new("\s*("+ing_nuts+"|"+ing_driedfruits+")(\s+|$)", true)
  ing_optionalRe = Regexp.new("(\s+optional(:?\s+|$))", true)
  ing_otherRe  = Regexp.new(""); # dummy.

  ingClassified = {
    # Each category stores the RegExp and an array of matched ingredients.
    'meat'      =>  { 're' => ing_meatRe, 'ingredients' => [], 'descr' => 'Meat' }, 
    'birds'     =>  { 're' => ing_birdsRe, 'ingredients' => [], 'descr' => "Meat(birds)"},
    'shellfish' =>  { 're' => ing_shellfishRe, 'ingredients' => [], 'descr' => "Shellfish"}, 
    'fish'      =>  { 're' => ing_fishRe, 'ingredients' => [], 'descr' => "Fish"}, 
    'dairy'     =>  { 're' => ing_dairyRe, 'ingredients' => [], 'descr' => "Eggs & Dairy"}, 
    'veg'       =>  { 're' => ing_vegRe, 'ingredients' => [], 'descr' => "Vegetables"}, 
    'grain'     =>  { 're' => ing_grainRe, 'ingredients' => [], 'descr' => "Grains"}, 
    'pasta'     =>  { 're' => ing_pastaRe, 'ingredients' => [], 'descr' => "Pasta"}, 
    'fruit'     =>  { 're' => ing_fruitRe, 'ingredients' => [], 'descr' => "Fruits"}, 
    'herbs_spices' =>  { 're' => ing_herbsSpicesRe, 'ingredients' => [], 'descr' => "Herbs & Spices"}, 
    'basics'    =>  { 're' => ing_basicsRe, 'ingredients' => [], 'descr' => "Salt, pepper, sugar, oils"}, 
    'nuts_dryfruits' =>  { 're' => ing_nutsDryfruitsRe, 'ingredients' => [], 'descr' => "Nuts & Dried fruits"},
    'other'     =>  { 're' => ing_otherRe,   'ingredients' => [], 'descr' => "Other"},
    'optional'  =>  { 're' => ing_optionalRe, 'ingredients' => [], 'descr' => "Optional"}
  }	

  ing = ing.gsub(/,/, '')
  ing = ing.gsub(/\./, '')
  ing_type = ''
  ing_match = ''
  ingClassified.each do |k,v|
    regexp = v['re']
    if ing =~ regexp
      ing_type = v['descr']
      ing_match = Regexp.last_match(0)
      break
    end
  end
  return ing_type, ing_match

end

