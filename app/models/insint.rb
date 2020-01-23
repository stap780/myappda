class Insint < ApplicationRecord

belongs_to :user
validates :subdomen, uniqueness: true
validates :subdomen, presence: true


def self.setup_ins_shop(insint_id)
  insint = Insint.find(insint_id)
  if insint.inskey.present?
    saved_subdomain = insint.user.subdomain
    # puts saved_subdomain
    Apartment::Tenant.switch!(saved_subdomain)

    uri = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes.json"
    response = RestClient.get(uri)
    data = JSON.parse(response)
    data.each do |d|
      if d['is_published'] == true
        @theme_id = d['id']
      end
    end

    Insint.add_snippet(insint.id, @theme_id)
    Insint.add_snippet_to_layout(insint.id, @theme_id)
    Insint.add_page_izb(insint.id, @theme_id)
  else
    saved_subdomain = "insales"+insint.insalesid.to_s
    Apartment::Tenant.switch!(saved_subdomain)

    uri = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes.json"
    response = RestClient.get(uri)
    data = JSON.parse(response)
    data.each do |d|
      if d['is_published'] == true
        @theme_id = d['id']
      end
    end

    Insint.add_snippet(insint.id, @theme_id)
    Insint.add_snippet_to_layout(insint.id, @theme_id)
    Insint.add_page_izb(insint.id, @theme_id)
  end
  insint.update_attributes(:status => true)
end

def self.add_snippet(insint_id, theme_id)
  insint = Insint.find(insint_id)
  if insint.inskey.present?
    saved_subdomain = insint.user.subdomain
    Apartment::Tenant.switch!(saved_subdomain)
    uri = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets.xml"
  else
    saved_subdomain = "insales"+insint.insalesid.to_s
    Apartment::Tenant.switch!(saved_subdomain)
    uri = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets.xml"
  end
  data = '<?xml version="1.0" encoding="UTF-8"?><asset><name>k-comment-product.liquid</name>
  <content><![CDATA[
    <style>
    .izb-icon {
       display: inline-block;
      }
  </style>
{% if client %}
<script type="text/javascript">
  $(document).ready(function(){
    $(".js-izb-add").click(function(e){
      e.preventDefault();
      var _this = $(this);
      var clientId;
      var productId = _this.data("izb-add");
      var host = "{{account.subdomain}}.myinsales.ru";
      $.ajax({
        "async": false,
        "url": "/client_account/contacts.json",
        "dataType": "json",
        "success": function (data) {
          clientId = data.client.id;
        }
      });
      var url = "https://k-comment.ru/insints/addizb"
      $.ajax({
        "url": url,
        "data": { host: host, client_id: clientId, product_id: productId },
        "dataType": "json"
      }).done(function( data ) {
        console.log("дата", data );
        alert(data.message);
 		_this.hide();
        _this.next().show();

      }).fail(function( jqxhr, textStatus, error ) {
        var err = textStatus + ", " + error;
      //  console.log( "Request Failed: " + err );
      }).error(function(data ) {
          alert(data.message);
        });
    });
  });

  $(document).ready(function(){
  		var clientId;
        var host = "{{account.subdomain}}.myinsales.ru";
        $.ajax({
          "async": false,
          "url": "/client_account/contacts.json",
          "dataType": "json",
          "success": function (data) {
            clientId = data.client.id;
          }
        });
    	var url = "https://k-comment.ru/insints/getizb"
        var products;
        $.ajax({
          "url": url,
          "async": false,
          "data": { host: host, client_id: clientId },
          "dataType": "json"
        }).done(function( data ) {
        //  console.log("что такое",data)
          products = data.products;
          var products_url = "/products_by_id/"+products+".json";

      if(products && products != " ") {
         var arrProd =  products.split(",");
         $.each(arrProd, function(key, value) {
           console.log("товар", value)
           $("[data-izb-add="+value+"]").hide();
           $("[data-izb-delete="+value+"]").show();
            var products_url = "/product_by_id/"+value+"";
              $.ajax({
                  url: products_url,
                  dataType: "html"
                }).done(function(_dom) {
                    var $dom = $(_dom);
                    $dom.find(".js-izb-add").hide();
                    $dom.find(".js-izb-delete").show();
                  });
          });
        }
        }).fail(function( jqxhr, textStatus, error ) {
          var err = textStatus + ", " + error;
        // console.log( "Request Failed: " + err );
        });

     $("body").on("click",".deleteizb", function(e) {
         var _this = $(this);
         e.preventDefault();
         var prodId = $(this).data("favorites-trigger");
          $.ajax({
          "url": "https://k-comment.ru/insints/deleteizb",
          "async": false,
          "data": { host: host, client_id: clientId, product_id: prodId },
          "dataType": "json"
        }).done(function( data ) {
          $(".products-favorite form[data-product-id="+prodId+"]").parent().remove();
		   _this.prev().show();
           _this.hide();
            if($(".products-favorite .row").children().length) {
            } else {
               $(".js-favorite").html("<div style=&quot;text-align: center;&quot; class=&quot;notice&quot;>В избранном нет товаров</div>");
            }
        }).fail(function( jqxhr, textStatus, error ) {
          var err = textStatus + ", " + error;
        //  console.log( "Request Failed: " + err );
        }).error(function(data ) {
          alert(data.message);
        });
       return false;
       });
  });
</script>
{% else %}
<script type="text/javascript">
  $(document).ready(function(){
    $(".js-izb-add").click(function(e){
       alert("Пожалуйста, зарегистрируйтесь, чтобы добавить товар в избранное!");
       return false;
      });
    });
</script>
{% endif %}

  ]]></content><type>Asset::Snippet</type></asset>'

  # response = RestClient.post uri, data, :accept => :xml, :content_type => "application/xml"

  RestClient.post( uri, data, {:content_type => 'application/xml', accept: :xml}) { |response, request, result, &block|
					puts response.code
								case response.code
								when 200
									puts 'Файл с именем k-comment-product.liquid - сохранили'
									puts response
								when 422
									puts '422'
                  puts response
								else
									response.return!(&block)
								end
								}
end

def self.add_snippet_to_layout(insint_id, theme_id)
  insint = Insint.find(insint_id)
  if insint.inskey.present?
    saved_subdomain = insint.user.subdomain
    Apartment::Tenant.switch!(saved_subdomain)
    url = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets.json"
    # puts url
    response = RestClient.get(url)
    data = JSON.parse(response)
    data.each do |d|
      if d['inner_file_name'] == "footer.liquid"
        @footer_id = d['id']
      end
    end

    uri = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets/"+"#{@footer_id}"+".json"
    resp_get_footer_content = RestClient.get(uri)
    data = JSON.parse(resp_get_footer_content)
    footer_content = data['content']
    new_footer_content = footer_content+' <span class="k-comment-product">{% include "k-comment-product" %}</span>'
    data = '<asset><content><![CDATA[ '+new_footer_content+' ]]></content></asset>'
    uri_new_footer = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets/"+"#{@footer_id}"+".xml"
    resp_change_footer_content = RestClient.put uri_new_footer, data, :accept => :xml, :content_type => "application/xml"
  else
    saved_subdomain = "insales"+insint.insalesid.to_s
    Apartment::Tenant.switch!(saved_subdomain)
    url = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets.json"
    # puts url
    response = RestClient.get(url)
    data = JSON.parse(response)
    data.each do |d|
      if d['inner_file_name'] == "footer.liquid"
        @footer_id = d['id']
      end
    end

    uri = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets/"+"#{@footer_id}"+".json"
    resp_get_footer_content = RestClient.get(uri)
    data = JSON.parse(resp_get_footer_content)
    footer_content = data['content']
    new_footer_content = footer_content+' <span class="k-comment-product">{% include "k-comment-product" %}</span>'
    data = '<asset><content><![CDATA[ '+new_footer_content+' ]]></content></asset>'
    uri_new_footer = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets/"+"#{@footer_id}"+".xml"
    resp_change_footer_content = RestClient.put uri_new_footer, data, :accept => :xml, :content_type => "application/xml"
  end
end

def self.add_page_izb(insint_id, theme_id)
  insint = Insint.find(insint_id)
  if insint.inskey.present?
    saved_subdomain = insint.user.subdomain
    Apartment::Tenant.switch!(saved_subdomain)
    url = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets.xml"
  else
    saved_subdomain = "insales"+insint.insalesid.to_s
    Apartment::Tenant.switch!(saved_subdomain)
    url = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets.xml"
  end
  data = '<?xml version="1.0" encoding="UTF-8"?><asset><name>page.izb.liquid</name>
  <content><![CDATA[

    {% if client %}
 <style>
   .products-favorite {
     text-align: center;
   }
   .products-favorite .card-image {
     margin-bottom: 20px;
   }
   .products-favorite .card-price {
     margin-bottom: 10px;
     font-weight: bold;
   }
   .products-favorite .card-old_price {
     text-decoration: line-through;
   }
   .products-favorite .card-title {
     font-weight: bold;
     margin-bottom: 20px;
   }
   .products-favorite .card-action {
     margin-top: 20px;
   }
   .products-favorite .row {
     display: -webkit-box;
     display: -webkit-flex;
     display: -ms-flexbox;
     display: flex;
     -webkit-box-flex: 1;
     -webkit-flex: 1 1 auto;
     -ms-flex: 1 1 auto;
     flex: 1 1 auto;
     -webkit-box-orient: horizontal;
     -webkit-box-direction: normal;
     -webkit-flex-direction: row;
     -ms-flex-direction: row;
     flex-direction: row;
     -webkit-flex-wrap: wrap;
     -ms-flex-wrap: wrap;
     flex-wrap: wrap;
     margin-left: 0px;
     margin-right: 0px;
   }
   .products-favorite [class*="cell-"] {
     padding-left: 0px;
     padding-right: 0px;
   }
   .products-favorite .cell-1 {
     max-width: 8.33333%;
     -webkit-flex-basis: 8.33333%;
     -ms-flex-preferred-size: 8.33333%;
     flex-basis: 8.33333%;
   }
   .products-favorite .cell-2 {
     max-width: 16.66667%;
     -webkit-flex-basis: 16.66667%;
     -ms-flex-preferred-size: 16.66667%;
     flex-basis: 16.66667%;
   }
   .products-favorite .cell-3 {
     max-width: 25%;
     -webkit-flex-basis: 25%;
     -ms-flex-preferred-size: 25%;
     flex-basis: 25%;
   }
   .products-favorite .cell-4 {
     max-width: 33.33333%;
     -webkit-flex-basis: 33.33333%;
     -ms-flex-preferred-size: 33.33333%;
     flex-basis: 33.33333%;
   }
   .products-favorite .cell-5 {
     max-width: 41.66667%;
     -webkit-flex-basis: 41.66667%;
     -ms-flex-preferred-size: 41.66667%;
     flex-basis: 41.66667%;
   }
   .products-favorite .cell-6 {
     max-width: 50%;
     -webkit-flex-basis: 50%;
     -ms-flex-preferred-size: 50%;
     flex-basis: 50%;
   }
   .products-favorite .cell-7 {
     max-width: 58.33333%;
     -webkit-flex-basis: 58.33333%;
     -ms-flex-preferred-size: 58.33333%;
     flex-basis: 58.33333%;
   }
   .products-favorite .cell-8 {
     max-width: 66.66667%;
     -webkit-flex-basis: 66.66667%;
     -ms-flex-preferred-size: 66.66667%;
     flex-basis: 66.66667%;
   }
   .products-favorite .cell-9 {
     max-width: 75%;
     -webkit-flex-basis: 75%;
     -ms-flex-preferred-size: 75%;
     flex-basis: 75%;
   }
   .products-favorite .cell-10 {
     max-width: 83.33333%;
     -webkit-flex-basis: 83.33333%;
     -ms-flex-preferred-size: 83.33333%;
     flex-basis: 83.33333%;
   }
   .products-favorite .cell-11 {
     max-width: 91.66667%;
     -webkit-flex-basis: 91.66667%;
     -ms-flex-preferred-size: 91.66667%;
     flex-basis: 91.66667%;
   }
   .products-favorite .cell-12 {
     max-width: 100%;
     -webkit-flex-basis: 100%;
     -ms-flex-preferred-size: 100%;
     flex-basis: 100%;
   }
   .products-favorite .cell-fifth {
     max-width: 20%;
     -webkit-flex-basis: 20%;
     -ms-flex-preferred-size: 20%;
     flex-basis: 20%;
   }
   .products-favorite .flex-center {
     -webkit-box-pack: center;
     -webkit-justify-content: center;
     -ms-flex-pack: center;
     justify-content: center;
     text-align: center;
   }

   @media screen and (max-width: 768px) {
     .products-favorite .cell-6-sm {
       max-width: 50%;
       -webkit-flex-basis: 50%;
       -ms-flex-preferred-size: 50%;
       flex-basis: 50%;
     }
   }
   @media screen and (max-width: 480px) {
     .products-favorite .cell-12-xs {
       max-width: 100%;
       -webkit-flex-basis: 100%;
       -ms-flex-preferred-size: 100%;
       flex-basis: 100%;
     }
   }
</style>
    <div class="page-headding-wrapper">
      <h1 class="page-headding">Избранные товары</h1>
      </div>
    <script type="text/javascript">
      function getDiscount(price, old_price) {
      var sale = "";
      var _merge = Math.round(
        ((parseInt(old_price) - parseInt(price)) / parseInt(old_price)) * 100,
        0
      );
      if (_merge < 100) {
        sale =
          "<div class=&quot;stiker stiker-sale&quot;>" +
          "<span>" +
          "скидка " +
          _merge +
          "%" +
          "</span>" +
          "</div>";
      }

      return sale;
    }
      $(document).ready(function(){
        var clientId;
        var host = "{{account.subdomain}}.myinsales.ru";
        $.ajax({
          "async": false,
          "url": "/client_account/contacts.json",
          "dataType": "json",
          "success": function (data) {
            clientId = data.client.id;
          }
        });
        var url = "https://k-comment.ru/insints/getizb"
        var products;
        $.ajax({
          "url": url,
          "async": false,
          "data": { host: host, client_id: clientId },
          "dataType": "json"
        }).done(function( data ) {
          products = data.products;
          var products_url = "/products_by_id/"+products+".json";
          $.getJSON(products_url).done(function (product) {
                var productsHtml = "";
                productsHtml += "<div class=&quot;products-favorite&quot;><div class=&quot;row is-grid&quot;>";
                $.each(product.products, function(i,product){
                    productsHtml += "<div class="cell-4 cell-6-sm cell-12-xs">";
                          productsHtml += "<form class="card cards-col" action="{{ cart_url }}" method="post" data-product-id="\'+product.id+\'">"
                          productsHtml += "<div class="card-info"><div class="card-image">";
                          productsHtml += "<a href="\'+product.url+\'" class="image-inner"><div class="image-wraps"><span class="image-container"><span class="image-flex-center"><img src="\'+product.images[0].medium_url+\'"></span></span></div></a></div>";
                          productsHtml += "<div class="card-title"><a href="\'+product.url+\'">\'+product.title+\'</a></div></div>";
                          productsHtml += "<div class="card-prices"><div class="row flex-center"><div class="cell- card-price">\'+InSales.formatMoney(product.variants[0].price)+\'</div>";
                          productsHtml += "<div class="cell-  card-old_price">\'+InSales.formatMoney(product.variants[0].old_price)+\'</div></div></div>";
                          productsHtml += "<div class="card-action show-flex"><div class="hide"><input type="hidden" name="variant_id" value="\'+product.variants[0].id+\'" ><div data-quantity class="hide"><input type="text" name="quantity" value="1" /></div></div></div>";
                          productsHtml += "<div class="card-action-inner">";
                          productsHtml += "<button class="bttn-favorite is-added deleteizb" data-favorites-trigger="\'+product.id+\'">Удалить</button>";
                          if (product.variants.size > 1){
                            productsHtml +="<a href="\'+product.url+\'" class="bttn-prim">Подробнее</a>"
                           }else{
                           productsHtml +="<button data-item-add class="bttn-prim" type="button">В корзину</button>"
                          }
                          productsHtml += "</div></form></div>";

                });
                productsHtml += "</div></div>";

                $(".js-favorite").html(productsHtml);
          });
      });
        if($(".products-favorite").length) {
           } else {
               $(".js-favorite").html("<div style=&quot;text-align: center;&quot; class=&quot;notice&quot;>В избранном нет товаров</div>");
           }

        });
    </script>

   <div class="js-favorite"></div>

{% else %}
 <div class="page-headding-wrapper">
      <h1 class="page-headding">Избранные товары</h1>
   	   <div class="editor">
         <div class="notice">Чтобы просматривать избранные товары необходима регистрация на сайте.</div>
 	   </div>
</div>
{% endif %}



  ]]></content><type>Asset::Template</type></asset>'

  # response = RestClient.post url, data, :accept => :xml, :content_type => "application/xml"
  RestClient.post( url, data, {:content_type => 'application/xml', accept: :xml}) { |response, request, result, &block|
					puts response.code
								case response.code
								when 200
									puts 'Файл с именем page.izb.liquid - сохранили'
									puts response
								when 422
									puts '422'
                  puts response
								else
									response.return!(&block)
								end
								}
end

def self.delete_ins_file(insint_id)
  insint = Insint.find(insint_id)
  if insint.inskey.present?
    saved_subdomain = insint.user.subdomain
    Apartment::Tenant.switch!(saved_subdomain)
    puts "удаляем файлы из магазина"
    uri = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes.json"
    response_theme_id = RestClient.get(uri)
    data_theme_id = JSON.parse(response_theme_id)
    data_theme_id.each do |d|
      if d['is_published'] == true
        @theme_id = d['id']
      end
    end

    theme_id = @theme_id
    uri_delete = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets.json"
    response_delete = RestClient.get(uri_delete)
    data_delete = JSON.parse(response_delete)
    data_delete.each do |d|
      if d['inner_file_name'] == "page.izb.liquid"
        page_izb_id = d['id']
        puts "page_izb_id - "+page_izb_id.to_s
        url_page = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets/"+"#{page_izb_id}"+".json"
        resp_get_footer_content = RestClient.delete(url_page)
      end
      if d['inner_file_name'] == "k-comment-product.liquid"
        snippet_product_id = d['id']
        puts "snippet_product_id - "+snippet_product_id.to_s
        url_snip = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets/"+"#{snippet_product_id}"+".json"
        resp_get_footer_content = RestClient.delete(url_snip)
      end
      #ниже отключил так как в doc.inner_html меняются символы на код html что трудно искать и заменять. проще руками строчку в файле удалить
      # if d['inner_file_name'] == "footer.liquid"
      #   footer_id = d['id']
      #   puts "footer_id - "+footer_id.to_s
      #   url_footer = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets/"+"#{footer_id}"+".json"
      #   resp = RestClient.get(url_footer)
      #   data = JSON.parse(resp)
      #   doc = Nokogiri::HTML(data['content'])
      #   doc.css('.k-comment-product').remove
      #
      #   new_footer_content = doc.inner_html.gsub("<html><body>","").gsub("</body></html>","").gsub("%7B%7B%20","{{").gsub("%20%7D%7D","}}")
      #   new_data = '<asset><content><![CDATA[ '+new_footer_content+' ]]></content></asset>'
      #   url_footer_xml = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets/"+"#{footer_id}"+".xml"
      #   remove_our_include = RestClient.put url_footer_xml, new_data, :accept => :xml, :content_type => "application/xml"
      # end
    end
  else
    saved_subdomain = "insales"+insint.insalesid.to_s
    Apartment::Tenant.switch!(saved_subdomain)
    puts "удаляем файлы из магазина"
    uri = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes.json"
    response_theme_id = RestClient.get(uri)
    data_theme_id = JSON.parse(response_theme_id)
    data_theme_id.each do |d|
      if d['is_published'] == true
        @theme_id = d['id']
      end
    end

    theme_id = @theme_id
    uri_delete = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets.json"
    response_delete = RestClient.get(uri_delete)
    data_delete = JSON.parse(response_delete)
    data_delete.each do |d|
      if d['inner_file_name'] == "page.izb.liquid"
        page_izb_id = d['id']
        puts "page_izb_id - "+page_izb_id.to_s
        url_page = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets/"+"#{page_izb_id}"+".json"
        resp_get_footer_content = RestClient.delete(url_page)
      end
      if d['inner_file_name'] == "k-comment-product.liquid"
        snippet_product_id = d['id']
        puts "snippet_product_id - "+snippet_product_id.to_s
        url_snip = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets/"+"#{snippet_product_id}"+".json"
        resp_get_footer_content = RestClient.delete(url_snip)
      end
      #ниже отключил так как в doc.inner_html меняются символы на код html что трудно искать и заменять. проще руками строчку в файле удалить
      # if d['inner_file_name'] == "footer.liquid"
      #   footer_id = d['id']
      #   puts "footer_id - "+footer_id.to_s
      #   url_footer = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets/"+"#{footer_id}"+".json"
      #   resp = RestClient.get(url_footer)
      #   data = JSON.parse(resp)
      #   doc = Nokogiri::HTML(data['content'])
      #   doc.css('.k-comment-product').remove
      #
      #   new_footer_content = doc.inner_html.gsub("<html><body>","").gsub("</body></html>","").gsub("%7B%7B%20","{{").gsub("%20%7D%7D","}}")
      #   new_data = '<asset><content><![CDATA[ '+new_footer_content+' ]]></content></asset>'
      #   url_footer_xml = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets/"+"#{footer_id}"+".xml"
      #   remove_our_include = RestClient.put url_footer_xml, new_data, :accept => :xml, :content_type => "application/xml"
      # end
    end
  end
  insint.update_attributes(:status => false)
end

end
