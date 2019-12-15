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

      var url = "http://k-comment.ru:3000/insints/addizb"
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

end
