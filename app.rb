require "faraday"
require "json"
require "mandrill"
require "sinatra"

get "/ok" do
  "OK"
end

get "/boom" do
  raise RuntimeError.new("boom")
end

post "/webhook" do
  event = JSON.parse(request.body.read, object_class: OpenStruct)

  if event.description == "tracker.created"
    conn = Faraday.new(url: "https://api.easypost.com/fulfillment/vendor/v1")
    conn.basic_auth(ENV["EASYPOST_APIKEY"], "")

    response = conn.get "orders?query=#{event.result.tracking_code}"
    order = JSON.parse(response.body, object_class: OpenStruct).orders.first

    text = open("email.txt").read
    html = open("email.html").read

    text.gsub!("%CUSTOMERNAME%", order.destination.name || order.destination.company)
    text.gsub!("%TRACKINGNUMBER%", event.result.tracking_code)
    text.gsub!("%SHIPPINGDATE%", DateTime.parse(event.result.created_at).strftime("%Y-%d-%m"))
    text.gsub!("%CARRIER%", event.result.carrier)
    text.gsub!("%SHIPPING_METHOD%", event.result.carrier_detail.service || "")
    text.gsub!("%CUSTOMER_ADDRESS%", pretty_address(order.destination))

    html.gsub!("%CUSTOMERNAME%", order.destination.name || order.destination.company)
    html.gsub!("%TRACKINGNUMBER%", event.result.tracking_code)
    html.gsub!("%TRACKINGURL%", event.result.public_url)
    html.gsub!("%SHIPPINGDATE%", DateTime.parse(event.result.created_at).strftime("%Y-%d-%m"))
    html.gsub!("%CARRIER%", event.result.carrier)
    html.gsub!("%SHIPPING_METHOD%", event.result.carrier_detail.service || "")
    html.gsub!("%CUSTOMER_ADDRESS%", pretty_address(order.destination))

    message = {
      subject: "Order Confirmation",
      from_name: "Alitura",
      from_email: "andy@alituranaturals.com",
      text: text,
      html: html,
      to: [
        {
          email: order.destination.email,
          name: order.destination.name || order.destination.company,
        }
      ]
    }

    p message
    Mandrill::API.new(ENV["MANDRILL_APIKEY"]).messages.send message
  end

  "OK"
end

def pretty_address(address)
  text = address.street1

  if address.street2
    text = "#{text} #{address.street2}"
  end

  "#{text}, #{address.city}, #{address.state} #{address.zip}"
end
