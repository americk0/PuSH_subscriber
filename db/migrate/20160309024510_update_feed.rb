class UpdateFeed < ActiveRecord::Migration
  def change
    add_column :feeds, :feed_url, :string
    add_index  :feeds, :feed_url
  end
end
