json.array!(@feeds) do |feed|
  json.extract! feed, :id, :title, :feed_url
  json.url feed_url(feed, format: :json)
end
