class FavoriteService

  def initialize(insint)
    puts "Favorite initialize"
    @uri = "http://#{insint.inskey.to_s}:#{insint.password.to_s}@#{insint.subdomen.to_s}"
    get_theme_id
    get_asset_id
  end

  def get_theme_id
    response = RestClient.get("#{@uri}/admin/themes.json")
    data = JSON.parse(response)
    data.each do |d|
        @theme_id = d['id'] if d['is_published'] == true
    end
    # puts @theme_id
  end

  def get_asset_id
    response = RestClient.get("#{@uri}/admin/themes/#{@theme_id}/assets.json")
    data = JSON.parse(response)
    data.each do |d|
      @asset_id = d['id'] if d['inner_file_name'] == "layouts.layout.liquid"
    end
    # puts @asset_id
  end

  def load_script
    add_snippet
    add_snippet_to_layout
    add_page_izb
  end

  def add_snippet
    data = '<?xml version="1.0" encoding="UTF-8"?><asset><name>k-comment-product.liquid</name>
    <content><![CDATA[
      <style>
      .izb-icon { display: inline-block; }
      .favorits-icon { position: relative;margin-right: 12px; }
      .favorits-icon i { font-size: 16px; }
      .favorits-icon svg {
        max-width: 21px;
        height: auto;
        vertical-align: middle;
      }
      .favorits-icon span {
        display: block;
        position: absolute;
        width: 14px;
        height: 14px;
        text-align: center;
        right: -5px;
        border-radius: 50%;
        font-size: 8px;
        background:red;
        top: -5px;
        color:#fff;
        box-sizing: border-box;
        letter-spacing: 0;
        line-height: 14px;
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
              $(".js-favorts-count").text(data.totalcount);
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
      		   $(".js-favorts-count").text(data.totalcount);
            if(products && products != " ") {
               var arrProd =  products.split(",");
               $.each(arrProd, function(key, value) {
                 console.log("товар", value)
                 $("[data-izb-add="+value+"]").hide();
                 $("[data-izb-delete="+value+"]").show();
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
                $(".js-favorts-count").text(data.totalcount);
      		   _this.prev().show();
                 _this.hide();
                  if($(".products-favorite .row").children().length) {
                     $(".izb-send-email-wrapper").show();
                  } else {
                     $(".izb-send-email-wrapper").hide();
                     $(".js-favorite-wrapper").html("<div style=&quot;text-align: center;&quot; class=&quot;notice&quot;>В избранном нет товаров</div>");
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
             alert("Пожалуйста, зарегистрируйтесь, чтобы добавить товар в избранное! А также сможете сохранить свой список избранного для просмотра на любом устройстве или отправить себе на почту");
             return false;
            });
          });
      </script>

      {% endif %}

      {% comment %}
        <div class="favorits-icon">
           <a href="/page/favorites">
             <svg version="1.1" xmlns="https://www.w3.org/2000/svg" width="64px" height="60.833px" viewBox="0 0 64 60.833">
                 <path stroke="#000" stroke-width="5" stroke-miterlimit="10" fill-opacity="0" d="M45.684,2.654c-6.057,0-11.27,4.927-13.684,10.073 c-2.417-5.145-7.63-10.073-13.687-10.073c-8.349,0-15.125,6.776-15.125,15.127c0,16.983,17.134,21.438,28.812,38.231 c11.038-16.688,28.811-21.787,28.811-38.231C60.811,9.431,54.033,2.654,45.684,2.654z"/>
             </svg>
            <span class="js-favorts-count"></span>
          </a>
        </div>
      {% endcomment %}

    ]]></content><type>Asset::Snippet</type></asset>'

    # response = RestClient.post uri, data, :accept => :xml, :content_type => "application/xml"
    url = "#{@uri}/admin/themes/#{@theme_id}/assets.xml"
    # puts url
    RestClient.post( url, data, {:content_type => 'application/xml', accept: :xml}) { |response, request, result, &block|
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

  def add_snippet_to_layout
    resp_get_footer_content = RestClient.get("#{@uri}/admin/themes/#{@theme_id}/assets/#{@asset_id}.json")
    data = JSON.parse(resp_get_footer_content)
    footer_content = data['content']
    new_footer_content = footer_content.gsub('</html>',' <span class="k-comment-product">{% include "k-comment-product" %}</span></html>')
    data = '<asset><content><![CDATA[ '+new_footer_content+' ]]></content></asset>'
    uri_new_footer = "#{@uri}/admin/themes/#{@theme_id}/assets/#{@asset_id}.xml"
    resp_change_footer_content = RestClient.put uri_new_footer, data, :accept => :xml, :content_type => "application/xml"
  end

  def add_page_izb
    url = "#{@uri}/admin/themes/#{@theme_id}/assets.xml"

    data = '<?xml version="1.0" encoding="UTF-8"?><asset><name>page.izb.liquid</name>
    <content><![CDATA[

    {% if client %}
    <style>
    .products-favorite {text-align: center; margin-bottom: 60px;}
    .products-favorite .hide{ display: none; }
    .products-favorite .card-image { margin-bottom: 20px;}
    .products-favorite .card-price {margin-bottom: 10px; font-weight: bold;}
    .products-favorite .card-old_price {text-decoration: line-through;}
    .products-favorite .card-title {font-weight: bold; margin-bottom: 20px;}
    .products-favorite .card-action { margin-top: 20px; }
    .izb-send-email-title {margin: 10px 0;font-weight: bold;}
    .izb-send-notice { margin: 10px 0;font-weight: bold;}
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
    .products-favorite [class*="cell-"] {padding-left: 0px;padding-right: 0px;}
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
    <div class="container page-headding-wrapper">
      <h1 class="page-headding">Избранные товары</h1>
      <div class="izb-send-email-wrapper">
        <div class="izb-send-email-title">Вы можете отправить избранные товары себе на почту:</div>
        <div class="izb-send-email"><button class="js-emailizb">Отправить</button></div>
    </div>
      <div class="izb-send-notice"></div>
    </div>
    <script type="text/javascript">
        function getDiscount(price, old_price) {
          var sale = "";
          var _merge = Math.round(
            ((parseInt(old_price) - parseInt(price)) / parseInt(old_price)) * 100,
            0
          );
          if (_merge < 100) {
            sale ="<div class=&quot;stiker stiker-sale&quot;>" +"<span>" +"скидка " +
              _merge +
              "%" + "</span>" +"</div>";
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
              "success": function (data) { clientId = data.client.id;}
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
              $.getJSON(products_url).done(function (data) {
                  var productsHtml = " ";
                  var image;
                  productsHtml += \'<div class="products-favorite"><div class="row is-grid">\';
                  $.each(data.products, function(i,product){
                      if (typeof product.images !== "undefined"){
                        image = product.images[0].medium_url;
                      } else { image = ""; }
                      productsHtml += \'<div class="cell-4 cell-6-sm cell-12-xs">\'; //двойные кавычки оставил стандартно, а экранировал одинарные и так в каждой строке дальше
                      productsHtml += \'<form class="card cards-col" action="{{ cart_url }}" method="post" data-product-id="\'+product.id+\'">\';
                      productsHtml += \'<div class="card-info"><div class="card-image">\';
                      productsHtml += \'<a href="\'+product.url+\'" class="image-inner"><div class="image-wraps"><span class="image-container"><span class="image-flex-center\"><img src="\'+image+\'"></span></span></div></a></div>\';
                      productsHtml += \'<div class="card-title"><a href=\"\'+product.url+\'\">\'+product.title+\'</a></div></div>\';
                      productsHtml += \'<div class="card-prices"><div class="row flex-center"><div class="cell- card-price">\'+Shop.money.format(product.variants[0].price)+\'</div>\';
                      productsHtml += \'<div class="cell-  card-old_price">\'+Shop.money.format(product.variants[0].old_price)+\'</div></div></div>\';
                      productsHtml += \'<div class="card-action show-flex"><div class="hide"><input type="hidden" name="variant_id" value="\'+product.variants[0].id+\'" ><div data-quantity class="hide"><input type="text" name="quantity" value="1" /></div></div></div>\';
                      productsHtml += \'<div class="card-action-inner">\';
                      productsHtml += \'<button class="bttn-favorite is-added deleteizb" data-favorites-trigger="\'+product.id+\'">Удалить</button>\';
                      if (product.variants.size > 1){
                        productsHtml +=\'<a href="\'+product.url+\'" class="bttn-prim">Подробнее</a>\'
                      } else {
                      productsHtml +=\'<button data-item-add class="bttn-prim" type="button">В корзину</button>\'
                      }
                      productsHtml += \'</div></form></div>\';
                  });
                  productsHtml += \'</div></div>\';
                  $(".js-favorite-wrapper").html(productsHtml);
              });
          });
            if ( $(".products-favorite .row").children().length ) {
              } else { $(".js-favorite-wrapper").html(\'<div style="text-align: center" class="notice">В избранном нет товаров</div>\'); }

              $(".js-emailizb").click(function() {
                  $.ajax({
                  "url": "https://k-comment.ru/insints/emailizb",
                  "async": false,
                  "data": { host: host, client_id: clientId },
                  "dataType": "json"
                }).done(function( data ) {
                    console.log(data)
                    $(".izb-send-notice").text(data.message).show();
                      $(".izb-send-email-wrapper").hide();
                  });
              });
          });
        </script>

      <div class="js-favorite-wrapper"></div>

    {% else %}

    <div class="container page-headding-wrapper">
          <h1 class="page-headding">Избранные товары</h1>
          <div class="editor"><div class="notice">Чтобы просматривать избранные товары необходима регистрация на сайте.</div>
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

  def delete_ins_file #(insint_id, theme_id)
    url = "#{@uri}/admin/themes/#{@theme_id}"
    response_delete = RestClient.get("#{@uri}/admin/themes/#{@theme_id}/assets.json")
    data_delete = JSON.parse(response_delete)
    data_delete.each do |d|
      if d['inner_file_name'] == "page.izb.liquid"
        page_izb_id = d['id']
        # puts "page_izb_id - "+page_izb_id.to_s
        url_page = "#{url}/assets/#{page_izb_id}.json"
        resp_get_footer_content = RestClient.delete(url_page)
      end
      if d['inner_file_name'] == "k-comment-product.liquid"
        snippet_product_id = d['id']
        # puts "snippet_product_id - "+snippet_product_id.to_s
        url_snip = "#{url}/assets/#{snippet_product_id}.json"
        resp_get_footer_content = RestClient.delete(url_snip)
      end
      #ниже удаляем запись в футере
      if d['inner_file_name'] == "layouts.layout.liquid"
        asset_id = d['id']
        # puts "asset_id - "+asset_id.to_s
        url_footer = "#{url}/assets/#{asset_id}.json"
        # puts url_footer
        resp = RestClient.get(url_footer)
        data = JSON.parse(resp)
        # puts data['content']
        new_footer_content = data['content'].gsub('<span class="k-comment-product">{% include "k-comment-product" %}</span>','')
        new_data = '<asset><content><![CDATA[ '+new_footer_content+' ]]></content></asset>'
        url_footer_xml = "#{url}/assets/#{asset_id}.xml"
        remove_our_include = RestClient.put url_footer_xml, new_data, :accept => :xml, :content_type => "application/xml"
      end
    end

    # insint.update_attributes(:status => false)
  end

end
