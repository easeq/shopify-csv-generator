require 'faker'
require 'csv'
require_relative 'product'
require_relative 'simple_product'

def get_options (n)
  keys = [
    'color',
    'material',
    'coin',
    'currency',
    'adjective',
    'god',
    'hero',
    'primordial',
    'titan',
    'model',
    'emotion',
    'superhero',
  ].shuffle

  return keys.slice(0, n)
end 

def get_option_value (type)
   case type
   when 'color'
     return Faker::Commerce.unique.color
   when 'material'
     return Faker::Commerce.unique.material
    when 'coin'
      return Faker::Coin.unique.name
    when 'currency'
      return Faker::Currency.unique.name
    when 'adjective'
      return Faker::Adjective.unique.positive
    when 'god'
      return Faker::Ancient.unique.god
    when 'hero'
      return Faker::Ancient.unique.hero
    when 'primordial'
      return Faker::Ancient.unique.primordial
    when 'titan'
      return Faker::Ancient.unique.titan
    when 'model'
      return Faker::Camera.unique.model
    when 'emotion'
      return Faker::Emotion.unique.noun
    when 'superhero'
      return Faker::Superhero.unique.name
    end
end

def clear_unique (type)
   case type
   when 'color'
     return Faker::Commerce.unique.clear
   when 'material'
     return Faker::Commerce.unique.clear
    when 'coin'
      return Faker::Coin.unique.clear
    when 'currency'
      return Faker::Currency.unique.clear
    when 'adjective'
      return Faker::Adjective.unique.clear
    when 'god'
      return Faker::Ancient.unique.clear
    when 'hero'
      return Faker::Ancient.unique.clear
    when 'primordial'
      return Faker::Ancient.unique.clear
    when 'titan'
      return Faker::Ancient.unique.clear
    when 'model'
      return Faker::Camera.unique.clear
    when 'emotion'
      return Faker::Emotion.unique.clear
    when 'superhero'
      return Faker::Superhero.unique.clear
    end
end

def get_option_values (type, n)
  values = []
  i = 0

  while i < n 
    values.push(get_option_value(type))
    i += 1
  end 

  clear_unique(type)

  return values
end

if ARGV.empty?
	puts "Usage: ruby faker_script.rb [n]"
	puts "n: number of products to genetate"
elsif ARGV[0].to_i == 0
	puts "Usage: ruby faker_script.rb [n]"
	puts "where n = number of products to genetate"
else
	count = ARGV[0].to_i

    # puts available_options.keys.shuffle
	CSV.open('shopify_data.csv', 'wb') do |csv|
		product = Product.new({})
		csv << product.headers
		count.times do 
            options_count = rand(1..3)
            options = get_options(options_count)

            i = 0 
            variations = []
            while i < options_count
              values_count = rand(1..5)
              values = get_option_values(options[i], values_count)

              variations.push(values)

              i += 1
            end

            opts = { }
            combinations = []
            if options_count >= 1 
              combinations = variations[0] 
              opts["option1_name"] = options[0].capitalize
            end

            if options_count >= 2 
              combinations = combinations.product(variations[1])
              opts["option2_name"] = options[1].capitalize
            end 

            if options_count >= 3 
              combinations = combinations.product(variations[2]) 
              opts["option3_name"] = options[2].capitalize
            end 

            defaultCombi = combinations.pop()
            if defaultCombi.kind_of?(Array) 
              i = 1
              defaultCombi.flatten.each do |value| 
                opts["option" + i.to_s + "_value"] = value
                i += 1
              end
            else 
              opts["option1_value"] = defaultCombi
            end
              
			product = Product.new(opts)
			csv << product.attributes
          
            combinations.each do |combination|
              if combination.kind_of?(Array)
                csv << product.simple_product_attributes(combination.flatten)
              else
                csv << product.simple_product_attributes([combination])
              end
            end
		end
		puts 'done'
	end
end

