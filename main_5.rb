require 'csv'
require 'curb'
require 'open-uri'
require 'nokogiri'
require 'pry'

url = ARGV.first
#url = 'https://www.petsonic.com/snacks-huesos-para-perros/'
result = ARGV.last

# парсим по категориям их 8
all_product_page = Nokogiri::HTML(Curl.get(url).body).xpath('//ul[contains(@class, "subcate_grid_view")]/li/a').map { |a| a['href'] }
#puts all_product_page
#puts all_product_page.count

# открываем файл csv и указываем обозначения столбцов

CSV.open(result, "wb") do |note_line|
  note_line << ['Название товара', 'Цена товара', 'Изображение товара']

  # парсим каждую категорию

  all_product_page.each do |product_url|

    product_page_url = Nokogiri::HTML(Curl.get(product_url).body)

    # получаем урл каждого товара из категории
    product_name = product_page_url.xpath('.//a[@class="product-name"]/@href')
    #puts product_name
    #puts product_name.count

    # парсим каждый урл товара
    product_name.each do |every_product_url|

      every_product_name = Nokogiri::HTML(Curl.get(every_product_url).body)

      # название продукта

      product_name_1 = every_product_name.css('div.product_main_name').css('h1 > text()').to_s
      #puts product_name_1

      # изображение продукта

      product_img_1 = every_product_name.css('span#view_full_size').css('img#bigpic').at('img')['src']
      puts product_img_1


      #  парсим вариации веса товара
      attribute_product_list = every_product_name.css('fieldset.attribute_fieldset').css('ul.attribute_lists')

      # проходим по каждому весу
      attribute_product_list.each do |attr|
        # весовка продукта
        product_pre_packing = attr.xpath('//span[@class="radio_label"]').text

        # цена продукта для данной весовки
        product_price = attr.xpath('//span[@class="price_comb"]')

        # собираем все
        full_info = ["#{product_name} - #{product_pre_packing}", product_price, product_img_1]

        # пишем собранные данные в наш файл
        note_line << full_info

      end
    end
  end
end


