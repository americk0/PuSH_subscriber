json.array!(@feeds) do |feed|
  json.extract! feed, :id, :title, :text, :author
  json.url feed_url(feed, format: :json)
end
