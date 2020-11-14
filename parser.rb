require 'csv'
require 'curb'
require 'nokogiri'
require 'pry'

# запуск скрипта
#ruby parser.rb https://www.petsonic.com/snacks-huesos-para-perros/ csv

url = ARGV[0]
csv = ARGV[1]

# парсим товары по категориям их 8
all_product_page = Nokogiri::HTML(Curl.get(url).body).xpath('//ul[contains(@class, "subcate_grid_view")]/li/a').map { |a| a['href'] }

# создаем массив в который будем ложить все собранные данные
all_products = []

# парсим каждую категорию
all_product_page.each do |product_url|

  product_page_url = Nokogiri::HTML(Curl.get(product_url).body)

  # получаем урл каждого товара из категории
  product_names = product_page_url.xpath('.//a[@class="product-name"]/@href')

  # парсим каждый урл товара
  product_names.each do |every_product_url|

    every_product_name = Nokogiri::HTML(Curl.get(every_product_url).body)

    # название продукта
    product_name = every_product_name.xpath('//h1[@class="product_main_name"]/text()')
    all_products << product_name
    puts product_name

    # цена продукта
    product_price = every_product_name.xpath('//span[@class="price_comb"]/text()')
    all_products << product_price
    puts product_price

    # изображение продукта
    product_img = every_product_name.xpath('//span[@id="view_full_size"]/img[@id="bigpic"]/@src')
    all_products << product_img
    puts product_img

  end
end
#binding.pry

CSV.open(csv, "wb") do |note_line|
  all_products.each do |product|
    note_line << product
  end
end





