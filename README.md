To see the tutorial for how to set up the publisher, go [here](https://github.com/americk0/PuSH_publisher "PuSH publisher")

# Set up the Subscriber
Most of the time, a subscriber will only be a subscriber and a publisher will only be a publisher. This example shows how to implement only the subscriber, but in class each group’s website will be both a publisher and a subscriber. Refer to the link at the top to see how to implement the publisher. Details on how to implement a subscriber are as follows:

* A subscriber will need two models to store info for the rss feeds (feeds and entries) that you will need to create with the following rails commands:

```bash
rails generate scaffold feed title:string feed_url:string

rails generate model entry title:string author:string body:text feed_id:integer entry_id:integer
```

* The feeds model should have a `has_many :entries, dependent: :destroy` line and the entries modal should have a `belongs_to :feed` line. You can call them whatever you want but the RSS that will be sent by the hub to your subscriber will be a little different from the RSS that the publisher sent to the hub and will look something like this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <status feed="http://benjamin-watson-push-src.herokuapp.com/feed.rss" xmlns="http://superfeedr.com/xmpp-pubsub-ext">
    <http code="200">Fetched (ping) 200 86400 and parsed 1/11 entries</http>
    <next_fetch>2016-03-03T21:40:00.948Z</next_fetch>
    <entries_count_since_last_maintenance>21</entries_count_since_last_maintenance>
    <velocity>1.8</velocity>
    <generated_ids>true</generated_ids>
    <period>86400</period>
    <last_fetch>2016-03-02T21:40:00.730Z</last_fetch>
    <last_parse>2016-03-02T21:40:00.755Z</last_parse>
    <last_maintenance_at>2016-03-02T19:48:17.000Z</last_maintenance_at>
  </status>
  <link href="https://benjamin-watson-push-src.herokuapp.com" rel="alternate" title="TestBlog" type="text/html"/><link href="https://benjamin-watson-senior-seminar.superfeedr.com/" rel="hub" title="" type="text/html"/><link href="http://benjamin-watson-push-src.herokuapp.com/feed.rss" rel="self" title="TestBlog" type="application/rss+xml"/>
  <title>TestBlog</title>
  <updated>2016-03-02T21:39:38.000Z</updated>
  <id>testblog-2016-3-2-21</id>
  <entry xml:lang="en" xmlns:as="http://activitystrea.ms/spec/1.0/" xmlns:geo="http://www.georss.org/georss" xmlns:sf="http://superfeedr.com/xmpp-pubsub-ext" xmlns="http://www.w3.org/2005/Atom">
    <id>46</id>
    <published>2016-03-02T21:39:38.000Z</published>
    <updated>2016-03-02T21:39:38.000Z</updated>
    <title>fun</title>
    <summary type="html">&lt;p&gt;fun&lt;/p&gt;</summary><link href="https://benjamin-watson-push-src.herokuapp.com/blog_articles/46" rel="alternate" title="fun" type="text/html"/>
    <author>
      <name>fun</name>
      <uri></uri>
      <email></email>
      <id>fun</id>
    </author>
  </entry>
</feed>
```

* In order to receive feed entries, you will need to set up a webhook (pretty much just a url that acts as a callback function) that the hub will send HTTP POST requests to once you have subscribed to a publisher’s feed, which you will do in a later step. In the feeds controller controller, add a method called “webhook” that will be implemented in later steps. Then go into your config/routes.rb file and add these two lines which will set up your webhook for both GET and POST requests:

```ruby
# for responding to and returning the hub's challenge
get 'webhook' => 'feeds#webhook'

# for receiving RSS from the hub
post 'webhook' => 'feeds#webhook'
```

* To parse the xml that will be received from the hub, we will use a gem called “nokogiri” which will need to be added to your Gemfile, after which you will need to do “bundle install”. The documentation for Nokogiri can be found [here](http://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/Node "Nokogiri documentation")

* In your webhook method, put the following code

```ruby
def webhook
  @challenge = params['hub.challenge']

  # setup doc to be a usable Nokogiri object
  xml = request.body.read
  xml.gsub!(/\n */, '')
  doc = Nokogiri::XML(xml)
  doc.remove_namespaces!

  # ensure doc is a Nokogiri object before continuing
  unless doc.xpath('.//title')[0].nil?

    # find a feed or create a new one
    feed_url = doc.xpath('.//feed/status')[0].attribute('feed').value
    @feed = Feed.find_or_create_by(feed_url: feed_url)
    @feed.title = doc.xpath('.//feed/title')[0].inner_text
    @feed.save!

    doc.xpath('.//feed/entry').each do |entry|
      entry_id = entry.xpath('./id')[0].inner_text
      @entry = Entry.find_or_create_by(feed_id: @feed.id, entry_id: entry_id)
      @entry.title = entry.xpath('./title')[0].inner_text
      @entry.body = entry.xpath('./summary')[0].inner_text
      @entry.author = entry.xpath('./author/name')[0].inner_text
      @entry.save!
    end

  else
    puts 'PROBLEM: rss message empty'
  end

  respond_to do |format|
    format.html { render plain: @challenge, status: 200 }
  end
end
```

* This is a lot of code, but it should work right out of the box if you made the models using the rails commands above. To understand this code, think about what the webhook needs to do:
  1. It needs to respond to the hub’s initial request with a response containing a 200 OK status and a response body containing the hub challenge as plain text. This part is accomplished by the first line inside the webhook method and the last three lines before the final “end” line (note: the “plain: @challenge” tells rails not to encapsulate the challenge in any html tags).
  2. The webhook needs to parse the xml and store data in the Feed and Entry models. The first four lines under the “setup doc to be a usable Nokogiri object” comment just keep you from running into a series of errors that are difficult to debug, so keep those lines as-is to save yourself some trouble. The remaining lines use Nokogiri to parse xml and grab the data from specific xml tags. Nokogiri allows for searching an xml document using either xpath or css. I used xpath but you can use CSS if it feels more comfortable. If you want to know more about how xpath works, it is very simple and can be learned from [this page](http://www.w3schools.com/xsl/xpath_syntax.asp "Xpath Tutorial")

* Another feature that PuSH uses for security is token authentication, which lets the subscriber give the hub a token which the hub will then attach to every message containing RSS so that the subscriber can verify that the RSS it is receiving was sent by the hub and not a different source. This step is important, but I have not implemented it yet. For now, just add the following line to the top of your feeds controller and everything should work fine until I update this tutorial to include token authentication.

```ruby
skip_before_filter  :verify_authenticity_token
```

* Finally, all you need to do is send a POST request to the hub telling it which feed you want to subscribe to. This POST request needs to contain the following four pieces of data: a hub mode, a hub topic, a callback(webhook), and a hub verify. For example, if you were to use the linux command line tool “cURL” then the message would look like this:

```bash
curl -v -X POST https://benjamin-watson-senior-seminar.superfeedr.com/
-d'hub.mode=subscribe'
-d'hub.topic=http://benjamin-watson-push-src.herokuapp.com/feed.rss'
-d'hub.callback=http://benjamin-watson-push-client.herokuapp.com/webhook'
-d'hub.verify=sync'
```

* This is one way to subscribe, but more than likely you will want to make it easier for a user or group to subscribe to a feed. To do this, I will show you how to set up a subscribe button in rails. First, create a method in your feeds controller called “subscribe” and add a route for it in config/routes.rb

```ruby
# in config/routes.rb
get “subscribe” => “feeds#subscribe”
```
```ruby
# in feeds_controller.rb
def subscribe
end
```

* Now create a form partial in your app/views/feeds folder called “\_subscribe.html.erb” and put the following code in it. This will create a form that you can use to subscribe to a feed when you input the hub and feed urls for an RSS feed.

```html
<%= form_tag subscribe_path, method: :get do %>
  <fieldset>
    <legend>
      Subscribe
    </legend>
    <div class="field">
      <%= label_tag :hub, "Hub: " %><br>
      <%= text_field_tag :hub, params[:hub] %>
    </div>
    <div class="field">
      <%= label_tag :topic, "Topic: " %><br>
      <%= text_field_tag :topic, params[:topic] %>
    </div>
    <div class="actions">
      <%= submit_tag "Subscribe" %>
    </div>
  </fieldset>
<% end %>
```

* Now you can put this form wherever you want using an erb tag like <%= render ‘subscribe’ %>. The last step is to implement the subscribe method in the feeds controller. This can be done with the following code (Note: The end of this method redirects to the “feeds” page but you can change this to whatever you like):

```ruby
uri = URI.parse params[:hub]
post_params = {
  'hub.mode' => 'subscribe',
  'hub.topic' => params[:topic],
  'hub.callback' => 'http://benjamin-watson-push-client.herokuapp.com/webhook',
}
Net::HTTP.post_form uri, post_params

respond_to do |format|
  format.html { redirect_to :feeds, notice: 'subscription added' }
end
```

* Note also that unlike the cURL command above, this post request doesn't use the "hub.verify" => "sync". This is because for some reason, superfeedr complains when that part is specified when the post request is sent from this button. I don't know why but leaving it out has fixed the issue in many cases

* Now all you will need to do is change any urls in this tutorial to the urls for your app and you should be finished.
