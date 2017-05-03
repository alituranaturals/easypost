require "csv"
require "easypost"
require "mandrill"

content = File.open(ARGV[0]).read
input = CSV.new(content, headers: true, header_converters: :symbol, skip_blanks: true)

EasyPost.api_key = ARGV[3]
mandrill = Mandrill::API.new(ARGV[4])

input.to_a.each do |row|
  next unless row[:tracking_codes].size > 0

  tracker = EasyPost::Tracker.retrieve(row[:tracking_codes])

  text = <<-TEXT
Hello #{row[:to_name] || row[:to_company]},

Your order has shipped.

Tracking number: #{tracker.tracking_code}

Thank you for your order!

#{ARGV[1]}
TEXT
  html = <<-HTML
<p>Hello #{row[:to_name] || row[:to_company]},</p>
<p>Your order has shipped.</p>
<p>Tracking number: <a href="#{tracker.public_url}">#{tracker.tracking_code}</a></p>
<p>Thank you for your order!</p>
<p>#{ARGV[2]}</p>
HTML

  message = {
    subject: "Order Confirmation",
    from_name: ARGV[1],
    from_email: ARGV[2],
    text: text,
    html: html,
    to: [
      {
        email: row[:to_email],
        name: row[:to_name] || row[:to_company]
      }
    ]
  }

  #mandrill.messages.send message
  p message
end
