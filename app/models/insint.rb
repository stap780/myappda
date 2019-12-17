class Insint < ApplicationRecord

belongs_to :user

def self.setup_ins_shop(insint_id)
  insint = Insint.find(insint_id)
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

def self.add_snippet(insint_id, theme_id)
  insint = Insint.find(insint_id)
  saved_subdomain = "insales"+insint.insalesid.to_s
  Apartment::Tenant.switch!(saved_subdomain)

  uri = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets.xml"
  data = '<?xml version="1.0" encoding="UTF-8"?><asset><name>k-comment-product.liquid</name>
  <content><![CDATA[
    {% if client %}
{% if template contains "product" %}
<script type="text/javascript">
  $(document).ready(function(){

    $(".js-izb-add").click(function(){
      var clientId;
      var productId = $(".js-izb-add").data("izb-add");
      var host = "{{account.subdomain}}.myinsales.ru";
      $.ajax({
        "async": false,
        "url": "/client_account/contacts.json",
        "dataType": "json",
        "success": function (data) {
          clientId = data.client.id;
        }
      });

      var url = "http://k-comment.ru/insints/addizb"
      $.ajax({
        "url": url,
        "data": { host: host, client_id: clientId, product_id: productId },
        "dataType": "json"
      }).done(function( data ) {
        console.log( data );
        alert(data.message);
      }).fail(function( jqxhr, textStatus, error ) {
        var err = textStatus + ", " + error;
        console.log( "Request Failed: " + err );
      }).error(function(data ) {
          alert(data.message);
        });
    });

  });
</script>
{% endif %}
{% endif %}

  ]]></content><type>Asset::Snippet</type></asset>'

  response = RestClient.post uri, data, :accept => :xml, :content_type => "application/xml"

end

def self.add_snippet_to_layout(insint_id, theme_id)
  insint = Insint.find(insint_id)
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
  new_footer_content = footer_content+' {%include "k-comment-product" %}'
  data = '<asset><content><![CDATA[ '+new_footer_content+' ]]></content></asset>'
  uri_new_footer = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets/"+"#{@footer_id}"+".xml"
  resp_change_footer_content = RestClient.put uri_new_footer, data, :accept => :xml, :content_type => "application/xml"
end

def self.add_page_izb(insint_id, theme_id)
  insint = Insint.find(insint_id)
  saved_subdomain = "insales"+insint.insalesid.to_s
  Apartment::Tenant.switch!(saved_subdomain)
  url = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/themes/"+"#{theme_id}"+"/assets.xml"
  data = '<?xml version="1.0" encoding="UTF-8"?><asset><name>page.izb.liquid</name>
  <content><![CDATA[

    {% if client %}
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

        var url = "http://k-comment.ru/insints/getizb"
        var products;
        $.ajax({
          "url": url,
          "async": false,
          "data": { host: host, client_id: clientId },
          "dataType": "json"
        }).done(function( data ) {
          console.log("что такое",data)
          products = data.products;
          var products_url = "/products_by_id/"+products+".json";
          $.getJSON(products_url).done(function (product) {
              //console.log(product);
              $(".js-favorite").html(Template.render(product, "favorite"));
              Products.getList(_.map(product, "id"));
          });

      var arrProd =  products.split(",");

       $.each(arrProd, function(key, value) {
         console.log("товар", value)
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

        }).fail(function( jqxhr, textStatus, error ) {
          var err = textStatus + ", " + error;
          //console.log( "Request Failed: " + err );
        });



       $("body").on("click",".deleteizb", function(e) {
         e.preventDefault();
         var prodId = $(this).data("favorites-trigger");
          $.ajax({
          "url": "http://k-comment.ru/insints/deleteizb",
          "async": false,
          "data": { host: host, client_id: clientId, product_id: prodId },
          "dataType": "json"
        }).done(function( data ) {
        //  console.log( "удаляем" );
        //  console.log( data );
        //   console.log( "удаляем" );
          $(".products-favorite form[data-product-id="+prodId+"]").parent().remove();

        }).fail(function( jqxhr, textStatus, error ) {
          var err = textStatus + ", " + error;
        //  console.log( "Request Failed: " + err );
        });

       });
      });
    </script>
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

    <div class="js-favorite"></div>
    <script type="text/template" data-template-id="favorite">
    <div class="products-favorite">
      <div class="row is-grid">
    	<% _.forEach(products, function (product){  %>
    	<div class="cell-4 cell-6-sm cell-12-xs">
    	 <form class="card cards-col" action="{{ cart_url }}" method="post" data-product-id="<%= product.id %>">
    		<div class="card-info">
    		  <div class="card-image">
    			<a href="<%= product.url %>" class="image-inner">
    			  <div class="image-wraps">
    				<span class="image-container">
    				  <span class="image-flex-center">
    					<img src="<%= product.first_image.medium_url %>">
    				  </span>
    				</span>
    			  </div>
    			</a>
    		  </div>

    		  <div class="card-title">
    			<a href="<%= product.url %>">
    			  <%= product.title %>
    			</a>
    		  </div>

    		</div>

    		<div class="card-prices">
    		<div class="row flex-center">
    		  <div class="cell- card-price">
    			<%= Shop.money.format(product.variants[0].price) %>
    		  </div>
    		  <% if (product.variants[0].old_price){ %>
    			<div class="cell-  card-old_price">
    			  <%= Shop.money.format(product.variants[0].old_price) %>
    			</div>
    			<% } %>
    		  </div>
    		</div>
            <%= getDiscount(product.variants[0].price, product.variants[0].old_price) %>
    		<div class="card-action show-flex">
              <div class="hide">
                <input type="hidden" name="variant_id" value="<%= product.variants[0].id %>" >
                <div data-quantity class="hide">
                  <input type="text" name="quantity" value="1" />
                  <span data-quantity-change="-1">-</span>
                  <span data-quantity-change="1">+</span>
                </div>
              </div>
    		</div>
    		<div class="card-action-inner">
    		<button class="bttn-favorite is-added deleteizb" data-favorites-trigger="<%= product.id %>">Удалить</button>
    		<% if (product.variants.size > 1){ %>
    		  <a href="<%= product.url %>" class="bttn-prim">Подробнее</a>
    		<% }else{ %>
    		  <button data-item-add class="bttn-prim" type="button">В корзину</button>
    		<% } %>
    		</div>
    </form>

    </div>
    <% }) %>
    </div>

    </div>
    </script>

    {% endif %}

  ]]></content><type>Asset::Template</type></asset>'

  response = RestClient.post url, data, :accept => :xml, :content_type => "application/xml"

end

end
