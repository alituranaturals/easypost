# Fulfillment Order Emails via Webhooks

Fulfillment `Order`s emit three types of webhooks: `fulfillment.order.created`,
`fulfillment.order.updated` and `fulfillment.order.refunded`. These can be
consumed via EasyPost's normal Webhook infrastructure. Full documentation is
availabe through our website: https://www.easypost.com/docs/api.html#events and
https://www.easypost.com/webhooks-guide.html.

When an `Order` is shipped a `Tracker` is also created on your EasyPost
account. The tracking webhooks are used in this example to provide customers
with EasyPost's tracking page that is brandable via your EasyPost
[dashboard](http://www.easypost.com/account/brand).

The server in `app.rb` implements everything necessary for consuming
`tracker.created` events (which are created once an order is shipped) and
sending an email. The example uses Mandrill (MailChimps transactional email
service) to send emails, however the line that sends the email is commented
out. The example requires that the email address is populated in the `Order`s
destination. If it is not you will need to retrieve the email address from your
own database.

In order to communicate with the EasyPost api, you will need to add the
`EASYPOST_APIKEY` environment variable before running the server.

If you are using Mandrill you will also need to add the `MANDRILL_APIKEY`
environment variable and un-comment the following line:

```ruby
Mandrill::API.new(ENV["MANDRILL_APIKEY"]).messages.send message
```

Ensure you have changed the name of the `from_name` and `from_email` within
`text`, `html` and `message` before sending any emails.


# Fulfillment Order Emails via CSV Report

The script `send-emails.rb` uses EasyPost and Mandrill to send transaction
emails to your customers. You can run the script using the following commands
within your Terminal application:

```sh
cd /path/to/fulfillment-emails
bundle exec ruby send-emails.rb <your-company-name> <your-company-email> <your-easypost-apikey> <your-mandrill-apikey>
```

Replase the items in `<>` with the appropriate details.

The copy of the emails within `send-emails.rb` is quite bare so you may want to
update that. Be sure to change the copy in both `html` and `text`. Once you have
tested the messages you can uncomment the following line by removing the `#`:

```ruby
mandrill.message.send message
```
